; Imports & aliases {{{

(local api vim.api)

; }}}
; Fennel utils {{{

(fn inc [x] (+ x 1))
(fn dec [x] (- x 1))

(fn clamp [val min max]
  (if (< val min) min
      (> val max) max
      :else val))

(fn last [tbl] (. tbl (length tbl)))

(local empty? vim.tbl_isempty)

(fn reverse-lookup [tbl]
  (collect [k v (ipairs tbl)] (values v k)))

(macro ++ [x] `(set ,x (+ ,x 1)))

(macro one-of? [x ...]
  "Expands to an `or` form, like (or (= x y1) (= x y2) ...)"
  `(or ,(unpack
          (icollect [_ y (ipairs [...])]
            `(= ,x ,y)))))

(macro when-not [condition ...]
  `(when (not ,condition) ,...))

; }}}
; Nvim utils {{{

(fn getchar-as-str []
  (local (ok? ch) (pcall vim.fn.getchar))  ; handling <C-c>
  (values ok? (if (= (type ch) :number) (vim.fn.nr2char ch) ch)))

(fn replace-keycodes [s]
  (api.nvim_replace_termcodes s true false true))

(fn echo [msg]
  (vim.cmd :redraw) (api.nvim_echo [[msg]] false []))

(fn operator-pending-mode? []
  (-> (. (api.nvim_get_mode) :mode) (string.match "o")))

(fn yank-operation? [] (and (operator-pending-mode?) (= vim.v.operator :y)))
(fn change-operation? [] (and (operator-pending-mode?) (= vim.v.operator :c)))
(fn delete-operation? [] (and (operator-pending-mode?) (= vim.v.operator :d)))
(fn dot-repeatable-operation? [] (and (operator-pending-mode?) (not= vim.v.operator :y)))

(fn get-cursor-pos []
  [(vim.fn.line ".") (vim.fn.col ".")])


(fn char-at-pos [[line byte-col] {: char-offset}]  ; expects (1,1)-indexed input
  "Get character at the given position in a multibyte-aware manner.
An optional offset argument can be given to get the nth-next screen
character instead."
  (let [line-str (vim.fn.getline line)
        char-idx (vim.fn.charidx line-str (dec byte-col))  ; charidx expects 0-indexed col
        char-nr (vim.fn.strgetchar line-str (+ char-idx (or char-offset 0)))]
    (when (not= char-nr -1) (vim.fn.nr2char char-nr))))


(fn leftmost-editable-wincol []
  ; Note: This will not have a visible effect if not forcing a redraw.
  (local view (vim.fn.winsaveview))
  (vim.cmd "norm! 0")
  (local wincol (vim.fn.wincol))
  (vim.fn.winrestview view)
  wincol)

; }}}
; Glossary {{{

; Instant-repeat (1-char search)
; While Lightspeed is active, repeatedly pressing f/F/t/T goes to (or
; right before/after) the next/previous match (effectively repeats the
; last 1-character search with a count of 1). Pressing any other key
; exits from this "standby" mode; subsequent calls will behave as new
; invocations.

; Beacon (2-char search)
; An extmark positioned over an on-screen matching pair, giving
; information about how it can be reached. It can take on many forms; in
; the common case, the first field shows the 2nd character of the
; original pair, as a reminder (that is, it is shown on top of the
; _first_ character), while the second field shows a "target label"
; (that is possibly a "shortcut"). If there is only one match, the
; extmark shows the pair as it is, with a different highlighting (we
; will jump there automatically then).
; Beacons can also overlap each other - in that case, the invariant to
; be maintained is that the target label (i.e., the second/right field)
; should remain visible in all circumstances.

; Label (2-char search)
; The character needed to be pressed to jump to the match position,
; after the whole search pattern has been given. It is always shown on
; top of the second character of the pair.

; Shortcut (2-char search)
; A position where the assigned label itself is enough to determine the
; target you want to jump to (for example when a character is always
; followed by a certain other character in the search area). Those you
; can reach via typing the label character right after the first input,
; bypassing the second one. The label gets a different highlight in
; these cases.

; }}}
; Setup {{{

(var opts {:jump_to_first_match true
           :jump_on_partial_input_safety_timeout 400
           :highlight_unique_chars false
           :grey_out_search_area true
           :match_only_the_start_of_same_char_seqs true
           :limit_ft_matches 5
           :x_mode_prefix_key "<c-x>"
           :substitute_chars {"\r" "¬"}  ; 0x00AC
           :instant_repeat_fwd_key nil
           :instant_repeat_bwd_key nil
           :cycle_group_fwd_key nil
           :cycle_group_bwd_key nil
           :labels nil

           ; deprecated (still valid)
           ; :full_incusive_prefix_key "<c-x>"
           })

(fn setup [user-opts]
  (set opts (setmetatable user-opts {:__index opts})))

; }}}
; Highlight {{{

(local hl
  {:group {:label                    "LightspeedLabel"
           :label-distant            "LightspeedLabelDistant"
           :label-overlapped         "LightspeedLabelOverlapped"
           :label-distant-overlapped "LightspeedLabelDistantOverlapped"
           :shortcut                 "LightspeedShortcut"
           :shortcut-overlapped      "LightspeedShortcutOverlapped"
           :masked-ch                "LightspeedMaskedChar"
           :unlabeled-match          "LightspeedUnlabeledMatch"
           :one-char-match           "LightspeedOneCharMatch"
           :unique-ch                "LightspeedUniqueChar"
           :pending-op-area          "LightspeedPendingOpArea"
           :pending-change-op-area   "LightspeedPendingChangeOpArea"
           :greywash                 "LightspeedGreyWash"
           :cursor                   "LightspeedCursor"}
   :ns (api.nvim_create_namespace "")
   :add-hl (fn [self hl-group line startcol endcol]
             (api.nvim_buf_add_highlight 0 self.ns hl-group line startcol endcol))
   :set-extmark (fn [self line col opts]
                  (api.nvim_buf_set_extmark 0 self.ns line col opts))
   :cleanup (fn [self] (api.nvim_buf_clear_namespace 0 self.ns 0 -1))})


(fn init-highlight [force?]
  (local bg vim.o.background)
  (local groupdefs
    [[hl.group.label                    {:guifg (match bg :light "#f02077" _ "#ff2f87")
                                         :ctermfg "Red"
                                         :guibg :NONE :ctermbg :NONE
                                         :gui "bold,underline"
                                         :cterm "bold,underline"}]
     [hl.group.label-overlapped         {:guifg (match bg :light "#ff4090" _ "#e01067")
                                         :ctermfg "Magenta"
                                         :guibg :NONE :ctermbg :NONE
                                         :gui "underline"
                                         :cterm "underline"}]
     [hl.group.label-distant            {:guifg (match bg :light "#399d9f" _ "#99ddff")
                                         :ctermfg (match bg :light "Blue" _ "Cyan")
                                         :guibg :NONE :ctermbg :NONE
                                         :gui "bold,underline"
                                         :cterm "bold,underline"}]
     [hl.group.label-distant-overlapped {:guifg (match bg :light "#59bdbf" _ "#79bddf")
                                         :ctermfg (match bg :light "Cyan" _ "Blue")
                                         :gui "underline" :cterm "underline"}]
     [hl.group.shortcut                 {:guibg "#f00077" :ctermbg "Red"
                                         :guifg "#ffffff" :ctermfg "White"
                                         :gui "bold,underline" :cterm "bold,underline"}]  ; ~inverse of label
     [hl.group.one-char-match           {:guibg "#f00077" :ctermbg "Red"
                                         :guifg "#ffffff" :ctermfg "White"
                                         :gui "bold" :cterm "bold"}]  ; shortcut without underline
     [hl.group.masked-ch                {:guifg (match bg :light "#cc9999" _ "#b38080")
                                         :ctermfg "DarkGrey"
                                         :guibg :NONE :ctermbg :NONE
                                         :gui :NONE :cterm :NONE}]
     [hl.group.unlabeled-match          {:guifg (match bg :light "#272020" _ "#f3ecec")
                                         :ctermfg (match bg :light "Black" _ "White")
                                         :guibg :NONE :ctermbg :NONE
                                         :gui "bold"
                                         :cterm "bold"}]
     [hl.group.pending-op-area          {:guibg "#f00077" :ctermbg "Red"
                                         :guifg "#ffffff" :ctermfg "White"}]  ; ~shortcut without bold/underline
     [hl.group.pending-change-op-area   {:guifg (match bg :light "#f02077" _ "#ff2f87")
                                         :ctermfg "Red"
                                         :guibg :NONE :ctermbg :NONE
                                         :gui "strikethrough"
                                         :cterm "strikethrough"}]
     [hl.group.greywash                 {:guifg "#777777" :ctermfg "Grey"
                                         :guibg :NONE :ctermbg :NONE
                                         :gui :NONE :cterm :NONE}]])
  ; Defining groups.
  (each [_ [group attrs] (ipairs groupdefs)]
    (let [attrs-str (-> (icollect [k v (pairs attrs)] (.. k "=" v))
                        (table.concat " "))]
      ; "default" = do not override any existing definition for the group.
      (vim.cmd (.. "highlight " (if force? "" "default ")
                   group " " attrs-str))))
  ; Setting linked groups.
  (each [_ [from-group to-group]
         (ipairs [[hl.group.unique-ch hl.group.unlabeled-match]
                  [hl.group.shortcut-overlapped hl.group.shortcut]
                  [hl.group.cursor "Cursor"]])]
    (vim.cmd (.. "highlight " (if force? "" "default ")
                 "link " from-group " " to-group))))


(fn grey-out-search-area [reverse?]
  (let [[curline curcol] (vim.tbl_map dec (get-cursor-pos))
        [win-top win-bot] [(dec (vim.fn.line "w0")) (dec (vim.fn.line "w$"))]
        [start finish] (if reverse?
                         [[win-top 0] [curline curcol]]
                         [[curline (inc curcol)] [win-bot -1]])]
    ; Expects 0,0-indexed args; `finish` is exclusive.
    (vim.highlight.range 0 hl.ns hl.group.greywash start finish)))

; }}}
; Common {{{

(fn echo-no-prev-search [] (echo "no previous search"))

(fn echo-not-found [s] (echo (.. "not found: " s)))


(fn push-cursor! [direction]
  "Push cursor 1 character to the left or right, possibly beyond EOL."
  (vim.fn.search "\\_." (match direction :fwd "W" :bwd "bW") ?stopline))


(fn cursor-before-eof? []
  (and (= (vim.fn.line ".") (vim.fn.line "$"))
       (= (vim.fn.virtcol ".") (dec (vim.fn.virtcol "$")))))


(fn force-matchparen-refresh []
  ; HACK: :DoMatchParen turns matchparen on simply by triggering
  ;       CursorMoved events (see matchparen.vim). We can do the same,
  ;       which is cleaner for us than calling :DoMatchParen directly,
  ;       since that would wrap this in a `windo`, and might visit
  ;       another buffer, breaking our visual selection (and thus also
  ;       dot-repeat, apparently). (See :h visual-start, and the
  ;       discussion at #38.)
  ;       Programming against the API would be more robust of course,
  ;       but in the unlikely case that the implementation details would
  ;       change, this still cannot do any damage on our side if called
  ;       silent!-ly (the feature just ceases to work then).
  (vim.cmd "silent! doautocmd matchparen CursorMoved")
  ; If vim-matchup is installed, it can similarly be forced to refresh
  ; by triggering a CursorMoved event. (The same caveats apply.)
  (vim.cmd "silent! doautocmd matchup_matchparen CursorMoved"))


(macro jump-to! [target {: add-to-jumplist? : after : reverse? : inclusive-motion?}]
  `(let [op-mode?# (operator-pending-mode?)
         ; Needs to be here, inside the returned form, as we need to get
         ; `vim.o.virtualedit` at runtime.
         restore-virtualedit-autocmd#
         (.. "autocmd CursorMoved,WinLeave,BufLeave"
             ",InsertEnter,CmdlineEnter,CmdwinEnter"
             " * ++once set virtualedit="
             vim.o.virtualedit)]
     (when ,add-to-jumplist? (vim.cmd "norm! m`"))
     (vim.fn.cursor ,target)

     ; Adjust position after the jump (for t-motion or x-mode).
     ,after

     ; Simulating inclusive/exclusive behaviour for operator-pending mode by
     ; adjusting the cursor position.

     ; For operators, our jump is always interpreted by Vim as an exclusive
     ; motion, so whenever we'd like to behave as an inclusive one, an
     ; additional push is needed to even that out (:h inclusive).
     ; (This is only relevant in the forward direction.)
     (when (and op-mode?# (not ,reverse?) ,inclusive-motion?)
       ; Check for modifiers forcing motion types. (:h forced-motion)
       (match (string.sub (vim.fn.mode :t) -1)
         ; Note that we should _never_ push the cursor in the linewise case,
         ; as we might push it beyond EOL, and that would add another line
         ; to the selection.

         ; Blockwise (<c-v>) itself makes the motion inclusive, we're done.

         ; We want the `v` modifier to behave in the native way, that is, to
         ; toggle between inclusive/exclusive if applied to a charwise
         ; motion (:h o_v). As our jump is technically - i.e., from Vim's
         ; perspective - an exclusive motion, `v` will change it to
         ; _inclusive_, so we should push the cursor back to "undo" that.
         ; (Previous column as inclusive = target column as exclusive.)
         :v (push-cursor! :bwd)

         ; Else, in the normal case (no modifier), we should push the cursor
         ; forward (next column as exclusive = target column as inclusive).
         :o (if (not (cursor-before-eof?)) (push-cursor! :fwd)
                ; The EOF edge case requires some hackery.
                ; (Note: The cursor will be moved to the end of the operated
                ; area anyway, no need to undo the `l` afterwards.)
                (do (vim.cmd "set virtualedit=onemore")
                    (vim.cmd "norm! l")
                    (vim.cmd restore-virtualedit-autocmd#)))))
     (when (not op-mode?#)
       (force-matchparen-refresh))))


(fn onscreen-match-positions [pattern reverse? {: ft-search? : limit}]
  "Returns an iterator streaming the return values of `searchpos` for
the given pattern, stopping at the window edge; in case of 2-character
search, folds and offscreen parts of non-wrapped lines are skipped too.
Caveat: side-effects take place here (cursor movement, &cpo), and the
clean-up happens only when the iterator is exhausted, so be careful with
early termination in loops."
  (let [view (vim.fn.winsaveview)
        cpo vim.o.cpo
        opts (if reverse? "b" "")
        stopline (vim.fn.line (if reverse? "w0" "w$"))  ; top/bottom of window
        cleanup #(do (vim.fn.winrestview view) (set vim.o.cpo cpo) nil)
        ; Only relevant for 2-character search from here on.
        non-editable-width (dec (leftmost-editable-wincol))  ; sign/number/foldcolumn
        col-in-edit-area (- (vim.fn.wincol) non-editable-width)
        left-bound (- (vim.fn.col ".") (dec col-in-edit-area))
        window-width (api.nvim_win_get_width 0)
        ; -1, as both chars of the match should be visible.
        ; NOTE: Should we change our minds and allow f/t to skip folds
        ;       and offscreen segments, then this has to be incremented
        ;       at the proper place(s)!
        right-bound (+ left-bound (dec (- window-width non-editable-width 1)))]

    (fn skip-to-fold-edge! []
      (match ((if reverse? vim.fn.foldclosed vim.fn.foldclosedend) (vim.fn.line "."))
        -1 :not-in-fold
        fold-edge (do (vim.fn.cursor fold-edge 0)
                      (vim.fn.cursor 0 (if reverse? 1 (vim.fn.col "$")))
                      ; ...regardless of whether it _actually_ moved
                      :moved-the-cursor)))

    (fn skip-to-next-onscreen-pos! []
      (local [line col &as from-pos] (get-cursor-pos))
      (match (if (< col left-bound) (if reverse? (when (>= (dec line) stopline)
                                                   [(dec line) right-bound])
                                        [line left-bound])
                 (> col right-bound) (if reverse? [line right-bound]
                                         (when (<= (inc line) stopline)
                                           [(inc line) left-bound])))
        to-pos (when (not= from-pos to-pos)
                 (vim.fn.cursor to-pos)
                 :moved-the-cursor)))

    (set vim.o.cpo (cpo:gsub "c" ""))  ; do not skip overlapping matches
    (var match-count 0)
    (fn rec [match-at-curpos?]
      (if (and limit (>= match-count limit)) (cleanup)
          (match (vim.fn.searchpos
                   pattern (.. opts (if match-at-curpos? "c" "")) stopline)
            [0 _] (cleanup)
            [line col &as pos]
            (if ft-search? (do (++ match-count) pos)
                (match (skip-to-fold-edge!)
                  :moved-the-cursor (rec false)
                  :not-in-fold
                  (if (or vim.wo.wrap (<= left-bound col right-bound))  ; = on-screen
                    (do (++ match-count) pos)
                    (match (skip-to-next-onscreen-pos!)
                      :moved-the-cursor (rec true)  ; true -> we might be _on_ a match
                      _ (cleanup))))))))))


; Thinking about some totally different implementation, not using search().
; (This is unusably slow if the window has a lot of content.)
(fn highlight-unique-chars [reverse? ignorecase]
  (local unique-chars {})
  (each [pos (onscreen-match-positions ".." reverse? {})]  ; do not match before EOL
    (let [ch (char-at-pos pos {})]
      (tset unique-chars ch (match (. unique-chars ch) nil pos _ false))))
  (each [ch pos-or-false (pairs unique-chars)]
    (when pos-or-false
      (let [[line col] pos-or-false]
        (hl:set-extmark (dec line) (dec col)
          {:virt_text [[ch hl.group.unique-ch]] :virt_text_pos "overlay"})))))


(fn highlight-cursor [?pos]
  "The cursor is down on the command line during `getchar`,
so we set a temporary highlight on it to see where we are."
  (let [[line col &as pos] (or ?pos (get-cursor-pos))
        ; nil means the cursor is on an empty line.
        ch-at-curpos (or (char-at-pos pos {}) " ")]  ; char-at-pos needs 1,1-idx
    ; (Ab)using extmarks even here, to be able to highlight the cursor on empty lines too.
    (hl:set-extmark (dec line) (dec col) {:virt_text [[ch-at-curpos hl.group.cursor]]
                                          :virt_text_pos "overlay"
                                          :hl_mode "combine"})))


(fn handle-interrupted-change-op! []
  "Return to previous mode and adjust cursor position if needed after
interrupted change-operation."
  ; Cannot really follow why, but this cleanup is needed here, else
  ; there is a short blink on the command line (the cursor jumps ahead,
  ; as if something has been echoed and then erased immediately).
  (echo "")
  (let [curcol (vim.fn.col ".")
        endcol (vim.fn.col "$")
        ?right (if (and (not vim.o.insertmode) (> curcol 1) (< curcol endcol))
                 "<RIGHT>"
                  "")]
    (-> (replace-keycodes (.. "<C-\\><C-G>" ?right))  ; :h CTRL-\_CTRL-G
        (api.nvim_feedkeys :n true))))


; Note: One of the main purpose of these macros, besides wrapping cleanup stuff,
; is to enforce and encapsulate the requirement that tail-positioned "exit"
; forms in `match` blocks should always return nil. (Interop with side-effecting
; VimL functions can be dangerous, they might return 0 for example, like
; `feedkey`, and with that they can screw up Fennel match forms in a breeze,
; resulting in misterious bugs, so it's better to be paranoid.)

(macro exit [...]
  `(do
     ; I don't understand why this double wrap is needed, but it is
     ; (else only sees the first item).
     (do ,...)
     (when (vim.fn.exists :#User#LightspeedLeave)
       (vim.cmd "doautocmd <nomodeline> User LightspeedLeave"))
     nil))


; Be sure _not_ to call this twice accidentally, `handle-interrupted-change-op!`
; might move the cursor twice then!
(macro exit-early [...]
  `(do (when (change-operation?)
         (handle-interrupted-change-op!))
       ; Putting the form here, _after_ the change-op handler,
       ; because it might feed keys too.
       (do ,...)
       (exit)))


(fn get-input-and-clean-up []
  (let [(ok? res) (getchar-as-str)]
    ; Cleaning up after every input religiously
    ; (trying to work in a more or less stateless manner).
    (hl:cleanup)
    ; <esc> should cleanly exit anytime.
    (when (and ok? (not= res (replace-keycodes "<esc>")))
      res)))


; repeat.vim support
; (see the docs in the script:
; https://github.com/tpope/vim-repeat/blob/master/autoload/repeat.vim)
(fn set-dot-repeat [cmd ?count]
  (when (operator-pending-mode?)
    (local op vim.v.operator)
    (when (not= op :y)
      (let [change (when (= op :c)
                     ; We cannot getreg('.') at this point, since the
                     ; change has not happened yet - therefore the
                     ; below hack (thx Sneak).
                     (replace-keycodes "<c-r>.<esc>"))
            seq (.. op (or ?count "") cmd (or change ""))]
        ; Using pcall, since vim-repeat might not be installed.
        ; Use the same register for the repeated operation.
        (pcall vim.fn.repeat#setreg seq vim.v.register)
        ; Note: we're feeding count inside the seq itself.
        (pcall vim.fn.repeat#set seq -1)))))

; }}}
; 1-character search {{{

; Precursory remarks: do not readily succumb to the siren call of
; generality here. 1- and 2-character search, according to this plugin's
; concept, are specialized tools for different purposes, and their
; behaviour is different enough to validate a separate implementation,
; without an encompassing wrapper function. There are annoying overlaps
; for sure, but this is a case where mindless DRY-ing (if that makes
; sense) might ultimately introduce more complexity and maintenance
; issues than it absorbs, I guess. Time might prove me wrong.

; State for 1-character search that is persisted between invocations.
(local ft {:instant-repeat? nil
           :started-reverse? nil
           :prev-reverse? nil
           ; For the workaround for native-like `;`/`,`-behaviour.
           :prev-t-like? nil
           :prev-search nil
           :prev-dot-repeatable-search nil
           ; Stack of previous positions (maintained only while
           ; instant-repeat is active).
           :stack []})

(fn ft.to [self reverse? t-like? dot-repeat? revert?]
  "Entry point for 1-character search."
  (let [_ (when-not self.instant-repeat?
            (set self.started-reverse? reverse?))
        reverse? (if self.instant-repeat?
                   ; f/t always continue in the original direction,
                   ; and F/T in the reverse of the original (so they mean
                   ; _relative_ reverse in case of instant-repeat).
                   (or (and (not reverse?) self.started-reverse?)
                       (and reverse? (not self.started-reverse?)))
                   reverse?)
        ; This is only relevant for the workaround described at `:h
        ; lightspeed-custom-ft-repeat-mappings`. (#19)
        switched-directions? (or (and reverse? (not self.prev-reverse?))
                                 (and (not reverse?) self.prev-reverse?))
        ; TODO: `count` is a very obscure name, could we find sg better?
        count (if (not self.instant-repeat?) vim.v.count1
                  (if (not revert?)
                      ; When instant-repeating t/T, we increment the count by
                      ; one, else we would find the same target in front of us
                      ; again and again, and be stuck.
                      (if (and t-like?
                               (not switched-directions?))  ; only for the ;/, workaround
                          (inc vim.v.count1)
                          vim.v.count1)
                      ; After a reverted repeat, we highlight the next n matches
                      ; as usual, as per `limit_ft_matches`, but will _not_
                      ; move the cursor. In case of `T`, we still don't want to
                      ; highlight the first match, i.e., the immediate next
                      ; character, so we're setting `count` to 1, to make the
                      ; highlighting loop skip that. (But otherwise we'll ignore
                      ; this, the cursor will stay in place.)
                      (if t-like? 1 0)))
        [repeat-key revert-key] (->> [opts.instant_repeat_fwd_key
                                      opts.instant_repeat_bwd_key]
                                     (vim.tbl_map replace-keycodes))
        op-mode? (operator-pending-mode?)
        dot-repeatable-op? (dot-repeatable-operation?)
        motion (if (and (not t-like?) (not reverse?)) "f"
                   (and (not t-like?) reverse?) "F"
                   (and t-like? (not reverse?)) "t"
                   (and t-like? reverse?) "T")
        cmd-for-dot-repeat (.. (replace-keycodes "<Plug>Lightspeed_dotrepeat_") motion)]

    (when-not (or dot-repeat? self.instant-repeat?)
      (when (vim.fn.exists :#User#LightspeedEnter)
        (vim.cmd "doautocmd <nomodeline> User LightspeedEnter"))
      (echo "")
      (highlight-cursor)
      (vim.cmd :redraw))

    (var enter-repeat? nil)
    (match (if self.instant-repeat? self.prev-search
               dot-repeat? self.prev-dot-repeatable-search
               (match (or (get-input-and-clean-up)
                          (exit-early))
                 "\r" (do (set enter-repeat? true)
                          (or self.prev-search
                              (exit-early
                                (echo-no-prev-search))))
                 in in))
      in1
      (let [new-search? (not (or enter-repeat? self.instant-repeat? dot-repeat?))]
        (when new-search?  ; endnote #1
          (if dot-repeatable-op?
            (do (set self.prev-dot-repeatable-search in1)
                (set-dot-repeat cmd-for-dot-repeat count))
            (set self.prev-search in1)))
        (set self.prev-reverse? reverse?)
        (set self.prev-t-like? t-like?)

        (var match-pos nil)
        (var i 0)
        (each [[line col &as pos]
               (let [pattern (.. "\\V" (in1:gsub "\\" "\\\\"))
                     limit (when opts.limit_ft_matches (+ count opts.limit_ft_matches))]
                 (onscreen-match-positions pattern reverse? {:ft-search? true : limit}))]
          (++ i)
          (if (<= i count) (set match-pos pos)
              (when-not op-mode?
                (hl:add-hl hl.group.one-char-match (dec line) (dec col) col))))

        (if (and (> count 0) (not match-pos))
            (exit-early
              (echo-not-found in1))  ; note: no highlight to clean up if no match found
            (do
              (when-not revert?
                (jump-to! match-pos
                          {:add-to-jumplist? (not self.instant-repeat?)
                           :after (when t-like? (push-cursor! (if reverse? :fwd :bwd)))
                           : reverse?
                           :inclusive-motion? true}))  ; like the native f/t
              (local new-pos (get-cursor-pos))
              (when-not op-mode?  ; note: no highlight to clean up in op-mode
                (highlight-cursor)
                (vim.cmd :redraw)
                (let [(ok? in2) (getchar-as-str)
                      mode (if (= (vim.fn.mode) :n) :n :x)  ; vim-cutlass compat (#28)
                      repeat? (or (= in2 repeat-key)
                                  (string.match (vim.fn.maparg in2 mode)
                                                (.. "<Plug>Lightspeed_"
                                                    (if t-like? "t" "f"))))
                      revert? (or (= in2 revert-key)
                                  (string.match (vim.fn.maparg in2 mode)
                                                (.. "<Plug>Lightspeed_"
                                                    (if t-like? "T" "F"))))]
                  (hl:cleanup)
                  (set self.instant-repeat? (and ok? (or repeat? revert?)))
                  (if (not self.instant-repeat?)
                      (exit
                        (set self.stack [])
                        (vim.fn.feedkeys (if ok? in2 (replace-keycodes "<esc>")) :i))
                      (do (if revert? (match (table.remove self.stack)
                                        prev-pos (vim.fn.cursor prev-pos))
                              (table.insert self.stack new-pos))
                          (ft:to false t-like? false revert?)))))))))))

; }}}
; 2-character search {{{

(fn get-labels []
  (or opts.labels
      (if opts.jump_to_first_match
        ["s" "f" "n" "/" "u" "t" "q" "S" "F" "G" "H" "L" "M" "N" "?" "U" "R" "Z" "T" "Q"]
        ["f" "j" "d" "k" "s" "l" "a" ";" "e" "i" "w" "o" "g" "h" "v" "n" "c" "m" "z" "."])))


(fn get-cycle-keys []
  (->> [(or opts.cycle_group_fwd_key (if opts.jump_to_first_match "<tab>" "<space>"))
        (or opts.cycle_group_bwd_key (if opts.jump_to_first_match "<s-tab>" "<tab>"))]
       (vim.tbl_map replace-keycodes)))


(fn get-match-map-for [ch1 reverse?]
  "Return a map that stores the positions of all on-screen pairs starting
with `ch1` in separate ordered lists, keyed by the succeeding char."
  (let [match-map {}                       ; {str [[1, 1, bool]]} i.e.:
                                           ; {successor-char [[line, col, partially-covered?]]}
        prefix "\\V\\C"                    ; force matching case (for the moment)
        input (ch1:gsub "\\" "\\\\")       ; backslash still needs to be escaped for \V
        pattern (.. prefix input "\\_.")]  ; match anything (including EOL) after it
    (var match-count 0)
    ; Saving some of the search state locally, in order to discover overlaps.
    (var prev {})
    (each [[line col &as pos] (onscreen-match-positions pattern reverse? {})]
      (let [overlap-with-prev? (and (= line prev.line)
                                    (= col ((if reverse? dec inc) prev.col)))
            ch2 (or (char-at-pos pos {:char-offset 1})
                    "\r")  ; <enter> is the expected input for line breaks
            same-pair? (= ch2 prev.ch2)]
        (if (or (when-not opts.match_only_the_start_of_same_char_seqs
                  ; If match_only_the_start... is turned off, we are skipping
                  ; only every second one from the consecutive overlapping
                  ; matches of the same pair; thus, if the previous match has
                  ; been skipped, we're good to go, no more checks necessary.
                  prev.skipped?)
                (not (and overlap-with-prev? same-pair?)))
          (let [partially-covered? (and overlap-with-prev? (not reverse?))]
            (when-not (. match-map ch2) (tset match-map ch2 []))
            ; In the forward direction, the previous match should be on top
            ; (overlapping the recent), in the reverse direction, the recent one.
            ; (The _label_ should be visible in both cases.)
            (table.insert (. match-map ch2) [line col partially-covered? ?ch3])
            (when (and overlap-with-prev? reverse?)
              ; Set the previous match to 'partially-covered'.
              (tset (last (. match-map prev.ch2)) 3 true))
            (set prev {: line : col : ch2 :skipped? false})
            (++ match-count))
          (set prev {: line : col : ch2 :skipped? true}))))
    (match match-count
      0 nil
      ; A sole match will be handled specially, so we extract the
      ; necessary information from the map.
      1 (let [ch2 (. (vim.tbl_keys match-map) 1)
              pos (. (vim.tbl_values match-map) 1 1)]
          [ch2 pos])
      _ match-map)))


(fn set-beacon-at [[line col partially-covered? &as pos]
                   ch1 ch2
                   {: labeled? : init-round? : repeat? : distant? : shortcut?}]
  (let [ch1 (or (. opts.substitute_chars ch1) ch1)
        ch2 (or (when-not labeled? (. opts.substitute_chars ch2)) ch2)
        ; When repeating, there is no initial round, i.e., no overlaps
        ; possible (triplets of the same character are _always_ skipped),
        ; and neither are there shortcuts.
        partially-covered? (when-not repeat? partially-covered?)
        shortcut? (when-not repeat? shortcut?)
        label-hl (if shortcut? hl.group.shortcut
                     distant? hl.group.label-distant
                     hl.group.label)
        overlapped-label-hl (if shortcut? hl.group.shortcut-overlapped
                                distant? hl.group.label-distant-overlapped
                                hl.group.label-overlapped)
        [startcol chunk1 ?chunk2]
        (if (not labeled?)  ; = a first - i.e. "autojumpable" - match
            ; `(not labeled?)` presupposes `init-round?` (and excludes `repeat?`,
            ; logically), since it means we will just jump there after the next
            ; input (that is why it doesn't get a label in the first place).
            (if partially-covered?
                [(inc col) [ch2 hl.group.unlabeled-match] nil]
                [col [ch1 hl.group.unlabeled-match] [ch2 hl.group.unlabeled-match]])

            partially-covered?  ; labeled
            (if init-round?
                [(inc col) [ch2 overlapped-label-hl] nil]
                ; The full beacon is shown now in the 2nd round, but the label
                ; keeps the same special highlight. (It is important for a label
                ; to stay unchanged once shown up, if possible, else the eye might
                ; get confused, which kinda beats the purpose.)
                [col [ch1 hl.group.masked-ch] [ch2 overlapped-label-hl]])

            ; `repeat?` is mutually exclusive both with `(not labeled?)` and
            ; `partially-covered?` (since only the second round takes place).
            ; Obviously, there is no need for a ch2-reminder in the first field.
            repeat?
            [(inc col) [ch2 label-hl] nil]

            ; Common case: labeled, fully visible match, new invocation.
            [col [ch1 hl.group.masked-ch] [ch2 label-hl]])]
      (hl:set-extmark (dec line) (dec startcol) {:virt_text [chunk1 ?chunk2]
                                                 :virt_text_pos "overlay"})))


(fn set-beacon-groups [ch2 positions labels shortcuts
                       {: group-offset : init-round? : repeat?}]
  (let [group-offset (or group-offset 0)
        |labels| (length labels)
        ; Set one group of beacons that uses up the available target labels.
        set-group (fn [start distant?]
                    (for [i start (dec (+ start |labels|))  ; end is inclusive
                          :until (or (< i 1) (> i (length positions)))]
                      (let [pos (. positions i)
                            ; 1-indexing is not a great match for modulo arithmetic.
                            label (or (. labels (% i |labels|))
                                      (. labels |labels|))  ; when mod = 0
                            shortcut? (when-not distant? (. shortcuts pos))]
                        (set-beacon-at pos ch2 label {:labeled? true
                                                      : init-round? : distant?
                                                      : repeat? : shortcut?}))))
        start (inc (* group-offset |labels|))
        end (dec (+ start |labels|))]
    ; Inner group (directly reachable matches).
    (set-group start false)
    ; Outer group (matches that are one group switch away).
    (set-group (+ start |labels|) true)))


; We're doing a lot of redundant work here, but it's much cleaner to uncouple
; this feature from the rest, and not complicate the logic of all the other
; functions. (It's nice that `get-match-map` groups the results by successor
; chars, and we can simply say in round 2 in the main function, "ok, then do the
; labeling for just a given ch2 now", and everything is set for us.)
(fn get-shortcuts [match-map labels reverse? jump-to-first?]
  (let [collides-with-a-ch2? #(vim.tbl_contains (vim.tbl_keys match-map) $)
        by-distance-from-cursor (fn [[[l1 c1] _ _] [[l2 c2] _ _]]
                                  (if (= l1 l2) (if reverse? (> c1 c2) (< c1 c2))
                                      (if reverse? (> l1 l2) (< l1 l2))))
        shortcuts []]
    (each [ch2 positions (pairs match-map)]
      ; Note: ignoring the distant group.
      (each [i pos (ipairs positions)]
        (local labeled-pos? (not (or (= (length positions) 1)
                                     (and jump-to-first? (= i 1)))))
        (when labeled-pos?
          (match (. labels (if jump-to-first? (dec i) i))
            label (when-not (collides-with-a-ch2? label)
                    ; Even if ending up using the shortcut, we will need
                    ; `ch2`, to save the search attributes for repeats.
                    (table.insert shortcuts [pos label ch2]))))))
    (table.sort shortcuts by-distance-from-cursor)
    (let [lookup-by-pos (let [labels-used-up {}]
                          ; Keep only the first of each label,
                          ; and return the stuff as a lookup table.
                          (collect [_ [pos label ch2] (ipairs shortcuts)]
                            (when-not (. labels-used-up label)
                              (tset labels-used-up label true)
                              (values pos [label ch2]))))
          lookup-by-label (collect [pos [label ch2] (pairs lookup-by-pos)]
                            (values label [pos ch2]))]
      (vim.tbl_extend :error lookup-by-pos lookup-by-label))))


(fn ignore-char-until-timeout [char-to-ignore]
  (let [start (os.clock)
        timeout-secs (/ opts.jump_on_partial_input_safety_timeout 1000)
        (ok? input) (getchar-as-str)]
    (when-not (and (= input char-to-ignore) (< (os.clock) (+ start timeout-secs)))
      (when ok? (vim.fn.feedkeys input :i)))))


; State for 2-character search that is persisted between invocations.
(local s {:prev-search {:in1 nil
                        :in2 nil}
          :prev-dot-repeatable-search {:in1 nil
                                       :in2 nil
                                       :in3 nil
                                       :x-mode? nil}})

(fn s.to [self reverse? invoked-in-x-mode? dot-repeat?]
  "Entry point for 2-character search."

  ; local vars (set after input)
  ; ----------------------------
  ; `enter-repeat?`
  ; `new-search?`
  ; `x-mode?`

  ; local helper functions
  ; ----------------------
  ; #1 macro `with-hl-chores`
  ; #2 fn    `switch-off-scrolloff`
  ; #3 fn    `restore-scrolloff`
  ; #4 fn    `cycle-through-match-groups`
  ; #5 fn    `save-state-for`
  ; #6 fn    `jump-with-wrap!`
  ; #7 fn    `jump-and-ignore-ch2-until-timeout!`

  ; algorithm skeleton
  ; ------------------
  ; get 1st input (in1) (direct input or persisted state)
  ; build 'match map' for in1
  ; if no match: exit
  ; elif only match:
  ;   save state (for repeats) & jump w/ timeout & exit (#5,#7)
  ; else:
  ;   calculate 'shortcutable' positions
  ;   if new search (not persisted state):
  ;     light up beacons (see glossary) (#1)
  ;   get 2nd input (in2) (direct input or persisted state)
  ;   if in2 is a shortcut-label:
  ;     save state & jump & exit (#5,#6)
  ;   else:
  ;     save state (#5)
  ;     if no match: exit
  ;     elif only match:
  ;       jump & exit (#6)
  ;     else:
  ;       if auto-jump to first match is set: jump (#6)
  ;       (#2)
  ;       if not dot-repeating: light up beacons (#1)
  ;       loop for getting 3rd input (in3) (#4)
  ;           - potentially switching match groups here,
  ;             the labels' referred targets might change
  ;       if in3 is a label in use:
  ;         jump & exit (#3,#6)
  ;       else: exit (#3)

  (let [op-mode? (operator-pending-mode?)
        change-op? (change-operation?)
        delete-op? (delete-operation?)
        dot-repeatable-op? (dot-repeatable-operation?)
        x-mode-prefix-key (replace-keycodes
                            (or opts.x_mode_prefix_key
                                opts.full_inclusive_prefix_key))  ; deprecated
        [cycle-fwd-key cycle-bwd-key] (get-cycle-keys)
        labels (get-labels)
        ; We _never_ want to autojump in OP mode, since that would execute
        ; the operation without allowing us to select a labeled target.
        jump-to-first? (and opts.jump_to_first_match (not op-mode?))
        cmd-for-dot-repeat (replace-keycodes (.. "<Plug>Lightspeed_dotrepeat_"
                                                 (if invoked-in-x-mode?
                                                     (if reverse? "X" "x")
                                                     (if reverse? "S" "s"))))]
    (var enter-repeat? nil)
    (var new-search? nil)
    (var x-mode? nil)

    (macro with-hl-chores [...]
      `(do (when opts.grey_out_search_area (grey-out-search-area reverse?))
           (do ,...)
           (highlight-cursor)
           (vim.cmd :redraw)))

    (fn cycle-through-match-groups [in2 positions-to-label shortcuts enter-repeat?]
      (var ret nil)
      (var group-offset 0)
      (var loop? true)
      (while loop?
        (match (or (when dot-repeat? self.prev-dot-repeatable-search.in3)
                   (get-input-and-clean-up)
                   (do (set loop? false)  ; <esc> or <c-c> should exit the loop
                       (set ret nil)
                       nil))
          input
          (if (not (one-of? input cycle-fwd-key cycle-bwd-key))
            ; Note: dot-repeat arrives here, and short-circuits.
            (do (set loop? false) (set ret [group-offset input]))
            ; Cycle to and highlight the next/previous group.
            (let [max-offset (math.floor (/ (length positions-to-label) (length labels)))]
              (set group-offset (-> group-offset
                                    ((match input cycle-fwd-key inc _ dec))
                                    (clamp 0 max-offset)))
              (with-hl-chores
                (set-beacon-groups in2 positions-to-label labels shortcuts
                                   {: group-offset :repeat? enter-repeat?}))))))
      ret)

    (fn save-state-for [{: enter-repeat : dot-repeat}]
      (when new-search?
        ; Arbitrary choice: let dot-repeat _not_ update the previous
        ; normal/visual/yank search - this seems more useful.
        (if dot-repeatable-op? (when dot-repeat
                                 (tset dot-repeat :x-mode? x-mode?)
                                 (set self.prev-dot-repeatable-search dot-repeat))
            ; FIXME: We should save `x-mode?` for enter-repeat too,
            ;        or pressing <enter> should be alowed after the prefix.
            ;        (Probably the latter.)
            enter-repeat (set self.prev-search enter-repeat))))

    (local jump-with-wrap!
      (do
        ; `first-jump?` should only be persisted inside `to` (i.e. the lifetime
        ; is one invocation) and should be managed by the function itself (it is
        ; error-prone if we have to set a flag manually), so setting up a
        ; closure here.
        (var first-jump? true)
        (fn [target]
          (jump-to! target
                    {:add-to-jumplist? first-jump?
                     :after (when x-mode?
                              (push-cursor! :fwd)
                              (when reverse? (push-cursor! :fwd)))
                     : reverse?
                     :inclusive-motion? (and x-mode? (not reverse?))})
          (when dot-repeatable-op?
            (set-dot-repeat cmd-for-dot-repeat))
          (set first-jump? false))))

    (fn jump-and-ignore-ch2-until-timeout! [[target-line target-col _ &as target-pos] ch2]
      (local orig-pos (get-cursor-pos))  ; 1,1
      ; TODO: what if `jump-to!` would return the final, adjusted position?
      (jump-with-wrap! target-pos)
      ; Jumping based on partial input is nice, but it's annoying that we don't
      ; see the actual changes right away (we are waiting for another input, so
      ; that we can introduce a safety timespan to ignore the character in the
      ; next column). Therefore we highlight both the cursor's new position and
      ; the operated area for a visual feedback, to tell the user that the
      ; target has been found, and they can continue editing.
      (when new-search?
        (let [ctrl-v (replace-keycodes "<c-v>")
              forward-x? (and x-mode? (not reverse?))
              backward-x? (and x-mode? reverse?)
              forced-motion (string.sub (vim.fn.mode :t) -1)
              from-pos (vim.tbl_map dec orig-pos)  ; -> 0,0
               ; `target-pos` is a 3-tuple, with a bool at the end, so don't try
               ; to use map here. (We should probably refactor that...)
              to-pos (->> [target-line (if backward-x? (inc (inc target-col))
                                           forward-x? (inc target-col)
                                           target-col)]
                          (vim.tbl_map dec))  ; -> 0,0
              ; (Preliminary) boundaries of the highlighted - operated - area.
              [startline startcol &as start] (if reverse? to-pos from-pos)
              [endline endcol &as end] (if reverse? from-pos to-pos)]
          (when-not change-op?  ; in that case we're entering insert mode anyway
            (let [?pos-to-highlight-at
                  (when op-mode?
                    ; In OP-mode, the cursor always ends up at the beginning of the
                    ; area, and that is _not_ necessarily our targeted position.
                    (if (= forced-motion ctrl-v)
                        ; For blockwise mode, we need to find the top/leftmost "corner".
                        ; (We increment these, because `start` and `end` were calculated
                        ; for the area highlight, that needs 0,0-indexing.)
                        [(inc startline) (inc (math.min startcol endcol))]
                        ; Otherwise, in the forward direction, we need to stay at the
                        ; start position with our virtual cursor.
                        (not reverse?) orig-pos))]
              ; In any other case, the actual position will be highlighted.
              (highlight-cursor ?pos-to-highlight-at)))
          (when op-mode?
            (local inclusive-motion? forward-x?)
            (local hl-group (if (or change-op? delete-op?)
                                hl.group.pending-change-op-area
                                hl.group.pending-op-area))
            ; The range is _exclusive_ (the end column will _not_ be included
            ; in the highlight).
            (fn hl-range [start end]
              (vim.highlight.range 0 hl.ns hl-group start end))
            (match forced-motion
              ctrl-v (for [line startline endline]
                       (hl-range [line (math.min startcol endcol)]
                                 ; Blockwise operations make the motion
                                 ; inclusive on both ends, so we should
                                 ; increment the end column. (Reminder:
                                 ; `highlight.range` will not include it.)
                                 [line (inc (math.max startcol endcol))]))
              :V (hl-range [startline 0] [endline -1])
              ; We are in OP mode, doing chairwise motion, so 'v' _flips_ its
              ; inclusive/exclusive behaviour (:h o_v).
              :v (hl-range start [endline (if inclusive-motion? endcol (inc endcol))])
              :o (hl-range start [endline (if inclusive-motion? (inc endcol) endcol)])))
          (vim.cmd :redraw)
          (ignore-char-until-timeout ch2)
          ; Mitigate blink on the command line (see also
          ; `handle-interrupted-change-op!`).
          (when change-op? (echo ""))
          (hl:cleanup))))

    ; A note on a design decision: when a function encapsulates an inherently
    ; complex flow of logic, it is most important to get a good overview of the
    ; happy path as quickly as possible. Matched forms seem a good place to hide
    ; any kind of error-handling/teardown/afterthoughts inside them, at the cost
    ; of being more obscure themselves. However, the advantage is that whenever
    ; we get something (non-nil) out of a form, we can be sure that we have a
    ; valid input and a clean state that we can continue to work with, simple as
    ; that.

    ; After all the stage-setting, here comes the main action you've all been
    ; waiting for:

    (when-not dot-repeat?
      (when (vim.fn.exists :#User#LightspeedEnter)
        (vim.cmd "doautocmd <nomodeline> User LightspeedEnter"))
      (echo "")  ; Clean up the command line.
      (with-hl-chores
        (when opts.highlight_unique_chars
          (highlight-unique-chars reverse?))))

    (match (if dot-repeat?
             (do (set x-mode? self.prev-dot-repeatable-search.x-mode?)
                 self.prev-dot-repeatable-search.in1)
             (match (or (get-input-and-clean-up)
                        (exit-early))
               ; Here we can handle any other modifier key as "zeroth" input,
               ; if the need arises (e.g. regex search).
               in0 (do (set enter-repeat? (= in0 "\r"))  ; User hit <enter> right away: repeat previous search.
                       (set new-search? (not (or enter-repeat? dot-repeat?)))
                       (set x-mode? (or invoked-in-x-mode?
                                        (= in0 x-mode-prefix-key)))
                       (if enter-repeat?
                           (or self.prev-search.in1
                               (exit-early
                                 (echo-no-prev-search)))

                           (and x-mode? (not invoked-in-x-mode?))
                           (or (get-input-and-clean-up)  ; Get the "true" first input.
                               (exit-early))

                           in0))))
      in1
      (let [prev-in2 (if enter-repeat? self.prev-search.in2
                         dot-repeat? self.prev-dot-repeatable-search.in2)]
        (match (or (get-match-map-for in1 reverse?)
                   (exit-early
                     (echo-not-found (.. in1 (or prev-in2 "")))))
          [ch2 pos &as unique-match]
          (if (or new-search? (= ch2 prev-in2))
              ; Successful exit, option #1: jump to a unique character right after the first input.
              (exit
                (save-state-for {:enter-repeat {: in1 :in2 ch2}
                                 :dot-repeat {: in1 :in2 ch2 :in3 (. labels 1)}})
                (jump-and-ignore-ch2-until-timeout! pos ch2))
              (exit-early
                (echo-not-found (.. in1 prev-in2))))

          match-map
          (let [shortcuts (get-shortcuts match-map labels reverse? jump-to-first?)]
            (when new-search?
              ; Initial round of setting beacons, for all possible targets.
              ; (Assigning labels for each list of positions independently.)
              (with-hl-chores
                (each [ch2 positions (pairs match-map)]
                  (let [[first & rest] positions
                        positions-to-label (if jump-to-first? rest positions)]
                    ; If `rest` is empty (only one match for `ch2`), we will jump anyway.
                    (when (or jump-to-first? (empty? rest))  ; Fennel gotcha: empty rest = [], _not_ nil
                      ; Highlight these pairs with a "direct route" differently.
                      (set-beacon-at first in1 ch2 {:init-round? true}))
                    (when-not (empty? rest)
                      (set-beacon-groups ch2 positions-to-label labels shortcuts
                                         {:init-round? true}))))))
            (match (or prev-in2
                       (get-input-and-clean-up)
                       (exit-early))
              in2
              (match (when new-search? (. shortcuts in2))
                [pos ch2 &as shortcut]
                ; Successful exit, option #2: selecting a shortcut-label.
                (exit
                  (save-state-for {:enter-repeat {: in1 :in2 ch2}
                                   :dot-repeat {: in1 :in2 ch2 :in3 in2}})
                  (jump-with-wrap! pos))

                _
                (do
                  (save-state-for {:enter-repeat {: in1 : in2}  ; endnote #1
                                   ; For the moment, set the first match as the target.
                                   :dot-repeat {: in1 : in2 :in3 (. labels 1)}})
                  (match (or (. match-map in2)
                             (exit-early
                               (echo-not-found (.. in1 in2))))
                    positions
                    (let [[first & rest] positions
                          positions-to-label (if jump-to-first? rest positions)]
                      (when (or jump-to-first? (empty? rest))
                        (jump-with-wrap! first))
                      (if (empty? rest)
                        ; Successful exit, option #3: jumped to the only match automatically.
                        (exit)
                        (do
                          ; Operations that spanned multiple groups are dot-repeated as
                          ; <enter>-repeat, i.e., only the search pattern is saved then
                          ; (endnote #3).
                          (when-not (and dot-repeat? self.prev-dot-repeatable-search.in3)
                            ; Lighting up beacons again, now only for pairs with `in2`
                            ; as second character.
                            (with-hl-chores
                              (set-beacon-groups in2 positions-to-label labels shortcuts
                                                 {:repeat? enter-repeat?})))
                          (match (or (cycle-through-match-groups in2 positions-to-label
                                                                 shortcuts enter-repeat?)
                                     ; Note: highlight is cleaned up by `cycle-through...`.
                                     (exit-early))  ; <C-c> case
                            [group-offset in3]
                            (do
                              (when (and dot-repeatable-op? (not dot-repeat?))
                                ; Reminder: above we have already set this to the character
                                ; of the first label, as a default. (We might had only one
                                ; match, and jumped automatically, not reaching this point.)
                                (set self.prev-dot-repeatable-search.in3
                                     ; If the operation spanned multiple groups, we are
                                     ; switching dot-repeat to <enter>-repeat (endnote #3).
                                     (if (= group-offset 0) in3 nil)))
                              (match (-?>> in3
                                           (. (reverse-lookup labels))  ; valid label (indexed on the list)?
                                           (+ (* group-offset (length labels)))
                                           (. positions-to-label))  ; currently active?
                                ; Successful exit, option #4: selecting an active label.
                                pos-of-active-label (exit
                                                      (jump-with-wrap! pos-of-active-label))
                                _ (if jump-to-first?
                                      ; Successful exit, option #5: falling through with any
                                      ; non-label key in "autojump" mode (so that we can
                                      ; continue editing right away).
                                      (exit
                                        (vim.fn.feedkeys in3 :i))
                                      (exit-early))))))))))))))))))

; }}}
; Handling editor options {{{

; Quick-and-dirty code, we'll tidy up/expand/rethink this section later.

; We will probably expose this table in the future, as an `opts` field.
(local temporary-editor-opts {:vim.wo.conceallevel 0
                              :vim.wo.scrolloff 0})

(local saved-editor-opts {})


(fn save-editor-opts []
  (each [opt _ (pairs temporary-editor-opts)]
    (let [[_ scope name] (vim.split opt "." true)]
      (tset saved-editor-opts
            opt
            ; Workaround for Nvim #13964.
            (if (= opt :vim.wo.scrolloff) (api.nvim_eval "&l:scrolloff")
                ; (= opt :vim.o.scrolloff) (api.nvim_eval "&scrolloff")
                ; (= opt :vim.wo.sidescrolloff) (api.nvim_eval "&l:sidescrolloff")
                ; (= opt :vim.o.sidescrolloff) (api.nvim_eval "&sidescrolloff")
                (. _G.vim scope name))))))


(fn set-editor-opts [opts]
  (each [opt val (pairs opts)]
    (let [[_ scope name] (vim.split opt "." true)]
      (tset _G.vim scope name val))))


(fn set-temporary-editor-opts []
  (set-editor-opts temporary-editor-opts))


(fn restore-editor-opts []
  (set-editor-opts saved-editor-opts))

; }}}
; Mappings {{{

(fn set-plug-keys []
  (local plug-keys
     ; params of `s:to`: reverse? [x-mode?] [dot-repeat?]
    [[:n "<Plug>Lightspeed_s" "s:to(false)"]
     [:n "<Plug>Lightspeed_S" "s:to(true)"]
     [:x "<Plug>Lightspeed_s" "s:to(false)"]
     [:x "<Plug>Lightspeed_S" "s:to(true)"]
     [:o "<Plug>Lightspeed_s" "s:to(false)"]
     [:o "<Plug>Lightspeed_S" "s:to(true)"]

     [:n "<Plug>Lightspeed_x" "s:to(false, true)"]
     [:n "<Plug>Lightspeed_X" "s:to(true, true)"]
     [:x "<Plug>Lightspeed_x" "s:to(false, true)"]
     [:x "<Plug>Lightspeed_X" "s:to(true, true)"]
     [:o "<Plug>Lightspeed_x" "s:to(false, true)"]
     [:o "<Plug>Lightspeed_X" "s:to(true, true)"]

     ; params of `ft:to`: reverse? [t-like?] [dot-repeat?]
     [:n "<Plug>Lightspeed_f" "ft:to(false)"]
     [:n "<Plug>Lightspeed_F" "ft:to(true)"]
     [:x "<Plug>Lightspeed_f" "ft:to(false)"]
     [:x "<Plug>Lightspeed_F" "ft:to(true)"]
     [:o "<Plug>Lightspeed_f" "ft:to(false)"]
     [:o "<Plug>Lightspeed_F" "ft:to(true)"]

     [:x "<Plug>Lightspeed_t" "ft:to(false, true)"]
     [:x "<Plug>Lightspeed_T" "ft:to(true, true)"]
     [:n "<Plug>Lightspeed_t" "ft:to(false, true)"]
     [:n "<Plug>Lightspeed_T" "ft:to(true, true)"]
     [:o "<Plug>Lightspeed_t" "ft:to(false, true)"]
     [:o "<Plug>Lightspeed_T" "ft:to(true, true)"]

     ; Just for our convenience, to be used here in the script.
     [:o "<Plug>Lightspeed_dotrepeat_s" "s:to(false, false, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_S" "s:to(true, false, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_x" "s:to(false, true, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_X" "s:to(true, true, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_f" "ft:to(false, false, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_F" "ft:to(true, false, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_t" "ft:to(false, true, true)"]
     [:o "<Plug>Lightspeed_dotrepeat_T" "ft:to(true, true, true)"]])

  (each [_ [mode lhs rhs-call] (ipairs plug-keys)]
    (api.nvim_set_keymap mode lhs (.. "<cmd>lua require'lightspeed'." rhs-call "<cr>")
                         {:noremap true :silent true})))


(fn set-default-keymaps []
  (local default-keymaps
    [[:n "s" "<Plug>Lightspeed_s"]
     [:n "S" "<Plug>Lightspeed_S"]
     [:x "s" "<Plug>Lightspeed_s"]
     [:x "S" "<Plug>Lightspeed_S"]
     [:o "z" "<Plug>Lightspeed_s"]
     [:o "Z" "<Plug>Lightspeed_S"]

     [:o "x" "<Plug>Lightspeed_x"]
     [:o "X" "<Plug>Lightspeed_X"]

     [:n "f" "<Plug>Lightspeed_f"]
     [:n "F" "<Plug>Lightspeed_F"]
     [:x "f" "<Plug>Lightspeed_f"]
     [:x "F" "<Plug>Lightspeed_F"]
     [:o "f" "<Plug>Lightspeed_f"]
     [:o "F" "<Plug>Lightspeed_F"]

     [:n "t" "<Plug>Lightspeed_t"]
     [:n "T" "<Plug>Lightspeed_T"]
     [:x "t" "<Plug>Lightspeed_t"]
     [:x "T" "<Plug>Lightspeed_T"]
     [:o "t" "<Plug>Lightspeed_t"]
     [:o "T" "<Plug>Lightspeed_T"]])

  (each [_ [mode lhs rhs] (ipairs default-keymaps)]
    (when (and
            ; User has not mapped (a keyseq starting with) `lhs` to something else.
            (= (vim.fn.mapcheck lhs mode) "")
            ; User has not already mapped something to the <Plug> key.
            (= (vim.fn.hasmapto rhs mode) 0))
      (api.nvim_set_keymap mode lhs rhs {:silent true}))))

; }}}
; Init {{{

(init-highlight)
(set-plug-keys)
(set-default-keymaps)

; Colorscheme plugins might clear out our highlight definitions, without
; defining their own.
(vim.cmd
  "augroup lightspeed_reinit_highlight
   autocmd!
   autocmd ColorScheme * lua require'lightspeed'.init_highlight()
   augroup end")

(vim.cmd
  "augroup lightspeed_editor_opts
   autocmd!
   autocmd User LightspeedEnter lua require'lightspeed'.save_editor_opts(); require'lightspeed'.set_temporary_editor_opts()
   autocmd User LightspeedLeave lua require'lightspeed'.restore_editor_opts()
   augroup end")

; }}}
; Endnotes {{{

; (1) These should be saved right here, because the repeated search
;     might have a match anyway.

; (2) <C-o> will unfortunately ignore this if the line has not changed.
;     https://github.com/neovim/neovim/issues/9874

; (3) It makes no practical sense to dot-repeat an operation spanning
;     multiple groups exactly as it went ("delete again till the 27th
;     match..."?). The most intuitive/logical behaviour is repeating as
;     <enter>-repeat in these cases, prompting for a target label again.

; }}}

{: opts
 : setup
 : ft
 : s

 :save_editor_opts save-editor-opts
 :set_temporary_editor_opts set-temporary-editor-opts
 :restore_editor_opts restore-editor-opts

 :init_highlight init-highlight
 :set_default_keymaps set-default-keymaps}

; vim:foldmethod=marker
