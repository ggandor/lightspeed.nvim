; Imports & aliases ///1

(local api vim.api)


; Fennel utils ///1

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


; Nvim utils ///1

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
    (when (not= char-nr -1)
      (vim.fn.nr2char char-nr))))


(fn leftmost-editable-wincol []
  ; Note: This will not have a visible effect if not forcing a redraw.
  (local view (vim.fn.winsaveview))
  (vim.cmd "norm! 0")
  (local wincol (vim.fn.wincol))
  (vim.fn.winrestview view)
  wincol)


; Glossary ///1

; Instant-repeat (1-char search)
; While Lightspeed is active, repeatedly pressing f/F/t/T goes  (or
; right before/after) the next/previous match (effectively repeats the
; last 1-character search with a count of 1). Pressing any other key
; exits from this "standby" mode; subsequent calls will behave as new
; invocations.

; Beacon (2-char search)
; An extmark positioned over an on-screen matching pair, giving
; information about how it can be reached. It can take on many forms; in
; the common case, the first field shows the 2nd character of the
; original pair, as a reminder (that is, it is shown on p of the
; _first_ character), while the second field shows a "target label"
; (that is possibly a "shortcut"). If there is only one match, the
; extmark shows the pair as it is, with a different highlighting (we
; will jump there aumatically then).
; Beacons can also overlap each other - in that case, the invariant 
; be maintained is that the target label (i.e., the second/right field)
; should remain visible in all circumstances.

; Label (2-char search)
; The character needed  be pressed to jump to the match position,
; after the whole search pattern has been given. It is always shown on
; p of the second character of the pair.

; Shortcut (2-char search)
; A position where the assigned label itself is enough  determine the
; target you want  jump to (for example when a character is always
; followed by a certain other character in the search area). Those you
; can reach via typing the label character right after the first input,
; bypassing the second one. The label gets a different highlight in
; these cases.


; Setup ///1

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


; Highlight ///1

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
     [hl.group.greywash                 {:guifg "#777777" :ctermfg "Grey"
                                         :guibg :NONE :ctermbg :NONE
                                         :gui :NONE :cterm :NONE}]])
  ; Defining groups.
  (each [_ [group attrs] (ipairs groupdefs)]
    (let [attrs-str (-> (icollect [k v (pairs attrs)] (.. k "=" v))
                        (table.concat " "))]
      ; "default" = do not override any existing definition for the group.
      (vim.cmd (.. "highlight "
                   (if force? "" "default ")
                   group " " attrs-str))))
  ; Setting linked groups.
  (each [_ [from-group to-group]
         (ipairs [[hl.group.unique-ch hl.group.unlabeled-match]
                  [hl.group.shortcut-overlapped hl.group.shortcut]
                  [hl.group.cursor "Cursor"]])]
    (vim.cmd (.. "highlight "
                 (if force? "" "default ")
                 "link " from-group " " to-group))))


(fn grey-out-search-area [reverse?]
  (let [[curline curcol] (vim.tbl_map dec (get-cursor-pos))
        [win-top win-bot] [(dec (vim.fn.line "w0")) (dec (vim.fn.line "w$"))]
        [start finish] (if reverse?
                         [[win-top 0] [curline curcol]]
                         [[curline (inc curcol)] [win-bot -1]])]
    ; Expects 0,0-indexed args; `finish` is exclusive.
    (vim.highlight.range 0 hl.ns hl.group.greywash start finish)))


(fn highlight-range [hl-group
                     [startline startcol &as start]
                     [endline endcol &as end]
                     {: forced-motion : inclusive-motion?}]
  "A wrapper around `vim.highlight.range` that handles forced motion
types properly."
  (let [ctrl-v (replace-keycodes "<c-v>")
        hl-range (fn [start end end-inclusive?]
                   (vim.highlight.range
                     0 hl.ns hl-group start end nil end-inclusive?))]
    (match forced-motion
      ctrl-v (let [[startcol endcol] [(math.min startcol endcol)
                                      (math.max startcol endcol)]]
               (for [line startline endline]
                 ; Blockwise operations make the motion inclusive on
                 ; both ends, unconditionally.
                 (hl-range [line startcol] [line endcol] true)))
      :V (hl-range [startline 0] [endline -1])
      ; We are in OP mode, doing chairwise motion, so 'v' _flips_ its
      ; inclusive/exclusive behaviour (:h o_v).
      :v (hl-range start end (not inclusive-motion?))
      _ (hl-range start end inclusive-motion?))))


; Common ///1

(fn echo-no-prev-search [] (echo "no previous search"))

(fn echo-not-found [s] (echo (.. "not found: " s)))


(fn push-cursor! [direction]
  "Push cursor 1 character to the left or right, possibly beyond EOL."
  (vim.fn.search "\\_." (match direction :fwd "W" :bwd "bW")))


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


(macro jump-to! [target
                 {: add-to-jumplist? : after : reverse? : inclusive-motion?}]
  `(let [op-mode?# (operator-pending-mode?)
         ; Needs to be here, inside the returned form, as we need to get
         ; `vim.o.virtualedit` at runtime.
         restore-virtualedit-autocmd#
         (.. "autocmd CursorMoved,WinLeave,BufLeave"
             ",InsertEnter,CmdlineEnter,CmdwinEnter"
             " * ++once set virtualedit="
             vim.o.virtualedit)]
     ; <C-o> will unfortunately ignore this if the line has not changed.
     ; See https://github.com/neovim/neovim/issues/9874
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
      (match ((if reverse? vim.fn.foldclosed vim.fn.foldclosedend)
              (vim.fn.line "."))
        -1 :not-in-fold
        fold-edge (do (vim.fn.cursor fold-edge 0)
                      (vim.fn.cursor 0 (if reverse? 1 (vim.fn.col "$")))
                      ; ...regardless of whether it _actually_ moved
                      :moved-the-cursor)))

    (fn skip-to-next-in-window-pos! []
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
                    (match (skip-to-next-in-window-pos!)
                      :moved-the-cursor (rec true)  ; true, as we might be _on_ a match
                      _ (cleanup))))))))))


; Thinking about some totally different implementation, not using search().
; (This is unusably slow if the window has a lot of content.)
(fn highlight-unique-chars [reverse? ignorecase]
  (let [unique-chars {}
        pattern ".\\_."]
    (each [pos (onscreen-match-positions pattern reverse? {})]
      (local ch (char-at-pos pos {}))
      (tset unique-chars ch (match (. unique-chars ch) nil pos _ false)))
    (each [ch pos (pairs unique-chars)]
      (match pos
        [line col]
        (hl:set-extmark (dec line)
                        (dec col)
                        {:virt_text [[ch hl.group.unique-ch]]
                         :virt_text_pos "overlay"})))))


(fn highlight-cursor [?pos]
  "The cursor is down on the command line during `getchar`,
so we set a temporary highlight on it to see where we are."
  (let [[line col &as pos] (or ?pos (get-cursor-pos))
        ; nil means the cursor is on an empty line.
        ch-at-curpos (or (char-at-pos pos {}) " ")]  ; char-at-pos needs 1,1-idx
    ; (Ab)using extmarks even here, to be able to highlight the cursor on empty lines too.
    (hl:set-extmark (dec line)
                    (dec col)
                    {:virt_text [[ch-at-curpos hl.group.cursor]]
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


(fn doau-when-exists [event]
  (when (vim.fn.exists (.. :#User# event))
    (vim.cmd (.. "doautocmd <nomodeline> User " event))))


(fn enter [mode]
  (doau-when-exists :LightspeedEnter)
  (match mode
    :sx (doau-when-exists :LightspeedSxEnter)
    :ft (doau-when-exists :LightspeedFtEnter)))


; Note: One of the main purpose of these macros, besides wrapping cleanup stuff,
; is to enforce and encapsulate the requirement that tail-positioned "exit"
; forms in `match` blocks should always return nil. (Interop with side-effecting
; VimL functions can be dangerous, they might return 0 for example, like
; `feedkey`, and with that they can screw up Fennel match forms in a breeze,
; resulting in misterious bugs, so it's better to be paranoid.)
(macro exit-template [mode early-exit? ...]
  `(do
     ; Be sure _not_ to call the macro twice accidentally,
     ; `handle-interrupted-change-op!` might move the cursor twice then!
     ,(when early-exit?
        `(when (change-operation?) (handle-interrupted-change-op!)))
     ; Putting the form here, after the change-op handler, because it might feed
     ; keys too. (Is that a valid problem? Change operation can only be
     ; interrupted by <c-c> or <esc> I guess...)
     ; (Note: I'd like to understand why it's necessary to wrap the varargs in
     ; an additional `do` - else only sees the first item.)
     (do ,...)
     ,(match mode
        :sx `(doau-when-exists :LightspeedSxLeave)
        :ft `(doau-when-exists :LightspeedFtLeave))
     (doau-when-exists :LightspeedLeave)
     nil))


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


(fn get-plug-key [kind reverse? x-or-t? repeat-invoc]
  (.. "<Plug>Lightspeed_"
      (match repeat-invoc :dot "dotrepeat_" _ "")
      ; Forcing to bools with not-not, as those values can be nils.
      (match [kind (not (not reverse?)) (not (not x-or-t?))]
        [:ft false false] "f" 
        [:ft true  false] "F"
        [:ft false true ] "t"
        [:ft true  true ] "T"
        [:sx false false] "s"
        [:sx false true ] "S"
        [:sx true  false] "x"
        [:sx true  true ] "X")))


; 1-character search ///1

; Precursory remarks: do not readily succumb to the siren call of
; generality here. 1- and 2-character search, according to this plugin's
; concept, are specialized tools for different purposes, and their
; behaviour is different enough to validate a separate implementation,
; without an encompassing wrapper function. There are annoying overlaps
; for sure, but this is a case where mindless DRY-ing (if that makes
; sense) might ultimately introduce more complexity and maintenance
; issues than it absorbs, I guess. Time might prove me wrong.

; State for 1-character search that is persisted between invocations.
(local ft {:state {:instant {:in nil
                             :stack nil}
                   :dot {:in nil}
                   :cold {:in nil
                          :reverse? nil
                          :t-mode? nil}}})

(fn ft.go [self reverse? t-mode? repeat-invoc]
  "Entry point for 1-character search."
  (let [instant-repeat? (or (= repeat-invoc :instant)
                            (= repeat-invoc :reverted-instant))
        reverted-instant-repeat? (= repeat-invoc :reverted-instant)
        cold-repeat? (= repeat-invoc :cold)
        dot-repeat? (= repeat-invoc :dot)
        ; After a reverted repeat, we highlight the next n matches as always, as
        ; per `limit_ft_matches`, but will _not_ move the cursor. In case of
        ; `T`, we still don't want to highlight the first match, i.e., the
        ; immediate next character, so the highlighting loop will skip that as
        ; usual (see the details there).
        count (if reverted-instant-repeat? 0 vim.v.count1)
        [repeat-key revert-key] (->> [opts.instant_repeat_fwd_key
                                      opts.instant_repeat_bwd_key]
                                     (vim.tbl_map replace-keycodes))
        op-mode? (operator-pending-mode?)
        dot-repeatable-op? (dot-repeatable-operation?)
        cmd-for-dot-repeat (replace-keycodes
                             (get-plug-key :ft reverse? t-mode? :dot))]

    (macro exit [...] `(exit-template :ft false ,...))
    (macro exit-early [...] `(exit-template :ft true ,...))

    (when-not instant-repeat? (enter :ft))

    (when-not repeat-invoc
      (echo "") (highlight-cursor) (vim.cmd :redraw))

    (match (if instant-repeat? self.state.instant.in
               dot-repeat? self.state.dot.in
               cold-repeat? self.state.cold.in
               (match (or (get-input-and-clean-up)
                          (exit-early))
                 "\r" (or self.state.cold.in
                          (exit-early
                            (echo-no-prev-search)))
                 in0 in0))
      in1
      (do
        (when-not repeat-invoc
          (set self.state.cold {:in in1 : reverse? : t-mode?}))  ; endnote #1

        ; We should get this before the loop, because `onscreen-match-positions`
        ; moves the cursor while executing.
        (local [next-line next-col] (vim.fn.searchpos "\\_." (if reverse? :nWb :nW)))
        (var match-pos nil)
        (var i 0)
        (each [[line col &as pos]
               (let [pattern (.. "\\V" (in1:gsub "\\" "\\\\"))
                     limit (when opts.limit_ft_matches (+ count opts.limit_ft_matches))]
                 (onscreen-match-positions pattern reverse? {:ft-search? true : limit}))]
          ; If we started repeating t/T from _right before_ a match, then skip
          ; that match (endnote #2).
          (when-not (and repeat-invoc t-mode?
                         ; The first match is found at the saved neighbouring position.
                         (= i 0) (= line next-line) (= col next-col))
            (++ i)
            (if (<= i count) (set match-pos pos)
                (when-not op-mode?
                  (hl:add-hl hl.group.one-char-match (dec line) (dec col) col)))))

        (if (and (> count 0) (not match-pos))  ; note: no highlight to clean up
            (exit-early
              (echo-not-found in1))
            (do
              (when-not reverted-instant-repeat?
                (jump-to! match-pos
                          {:add-to-jumplist? (not instant-repeat?)
                           :after (when t-mode?
                                    (push-cursor! (if reverse? :fwd :bwd)))
                           : reverse?
                           :inclusive-motion? true}))  ; like the native f/t
              (if op-mode?  ; note: no highlight to clean up
                  (exit
                    (when dot-repeatable-op?
                      (set self.state.dot {:in in1})
                      (set-dot-repeat cmd-for-dot-repeat count)))
                  (do
                    (highlight-cursor)
                    (vim.cmd :redraw)
                    (match (or (get-input-and-clean-up)
                               (exit))
                      in2
                      (let [mode (if (= (vim.fn.mode) :n) :n :x)  ; vim-cutlass compat (#28)
                            repeat? (or (= in2 repeat-key)
                                        (string.match (vim.fn.maparg in2 mode)
                                                      (get-plug-key :ft false t-mode?)))
                            revert? (or (= in2 revert-key)
                                        (string.match (vim.fn.maparg in2 mode)
                                                      (get-plug-key :ft true t-mode?)))
                            do-instant-repeat? (or repeat? revert?)]
                        (if do-instant-repeat?
                            (do
                              (when-not instant-repeat?
                                (set self.state.instant {:in in1 :stack []}))
                              (if revert? (match (table.remove self.state.instant.stack)
                                            old-pos (vim.fn.cursor old-pos))
                                  repeat? (table.insert self.state.instant.stack (get-cursor-pos)))
                              (ft:go reverse? t-mode? (if revert? :reverted-instant :instant)))
                            (exit
                              (vim.fn.feedkeys in2 :i)))))))))))))


; The workaround described in :h lightspeed-custom-ft-repeat-mappings used these fields.
(let [deprec-msg [["ligthspeed.nvim" :Question]
                  [": You're trying to access deprecated fields in the lightspeed.ft table.\n"]
                  ["There are dedicated <Plug> keys available for native-like "]
                  [";" :Visual] [" and "] ["," :Visual] [" functionality now.\n"]
                  ["See "] [":h lightspeed-custom-mappings" :Visual] ["."]]]
  (setmetatable ft {:__index (fn [t k]
                               (when (one-of? k :instant-repeat? :prev-t-like?)
                                 (api.nvim_echo deprec-msg true {})))}))


; 2-character search ///1

; Helpers ///

(fn get-labels []
  (or opts.labels
      (if opts.jump_to_first_match
          ["f" "s" "n" "u" "t" "/" "q" "F" "S" "G" "H" "L" "M" "N" "U" "R" "T" "Z" "?" "Q"]
          ["f" "j" "d" "k" "s" "l" "a" ";" "e" "i" "w" "o" "g" "h" "v" "n" "c" "m" "z" "."])))


(fn get-cycle-keys []
  (->> [(or opts.cycle_group_fwd_key
            (if opts.jump_to_first_match "<tab>" "<space>"))
        (or opts.cycle_group_bwd_key
            (if opts.jump_to_first_match "<s-tab>" "<tab>"))]
       (vim.tbl_map replace-keycodes)))


(fn get-match-map-for [ch1 reverse?]
  "Return a map that stores the positions of all on-screen pairs starting
with `ch1` in separate ordered lists, keyed by the succeeding char (`ch2`)."
  (let [match-map {}  ; {str [[1, 1, bool]]} i.e.: {succ-char [[line, col, overlapped?]]}
        prefix "\\V\\C"                    ; force matching case (for the moment)
        input (ch1:gsub "\\" "\\\\")       ; backslash still needs to be escaped for \V
        pattern (.. prefix input "\\_.")]  ; match anything (including EOL) after it
    (var prev {})  ; saving some search state locally, to discover overlaps
    (var added-prev-as-match? nil)
    (each [[line col &as pos] (onscreen-match-positions pattern reverse? {})]
      (let [ch2 (or (char-at-pos pos {:char-offset 1})
                    "\r")  ; <enter> is the expected input for line breaks
            overlap-with-prev? (and (= line prev.line)
                                    (= col ((if reverse? dec inc) prev.col)))
            same-char-triplet? (and overlap-with-prev? (= ch2 prev.ch2))]
        (set prev {: line : col : ch2})
        (if (and same-char-triplet?
                 (or added-prev-as-match?
                     opts.match_only_the_start_of_same_char_seqs))
            (set added-prev-as-match? false)
            (do
              (when-not (. match-map ch2) (tset match-map ch2 []))
              (table.insert (. match-map ch2) [line col])
              (when overlap-with-prev?
                ; Set either the previous or the current match to
                ; 'overlapped', depending on the direction (the invariant
                ; is that the _label_ should remain visible in any case).
                (-> (last (. match-map (if reverse? prev.ch2 ch2)))
                    (tset 3 true)))
              (set added-prev-as-match? true)))))
    (match (next match-map)  ; not empty
      (ch2 positions) (or (when-not (next match-map ch2)  ; no further keys
                            (match positions
                              [pos nil] [ch2 pos]))  ; only match
                          match-map))))


(fn set-beacon-at [[line col overlapped?]
                   ch1
                   ch2
                   {: labeled? : repeat? : distant? : shortcut?}]
  (let [ch1 (or (. opts.substitute_chars ch1) ch1)
        ch2 (or (when-not labeled? (. opts.substitute_chars ch2)) ch2)
        ; When repeating, there is no initial round, i.e., no overlaps
        ; possible (triplets of the same character are _always_ skipped),
        ; and neither are there shortcuts.
        overlapped? (and (not repeat?) overlapped?)
        shortcut? (and (not repeat?) shortcut?)

        [label-hl overlapped-label-hl]
        (if shortcut? [hl.group.shortcut hl.group.shortcut-overlapped]
            distant? [hl.group.label-distant hl.group.label-distant-overlapped]
            [hl.group.label hl.group.label-overlapped])

        [startcol chunk1 ?chunk2]
        (if (not labeled?)
            ; That is, a first ("autojumpable") match.
            ; `(not labeled?)` presupposes the first round (and excludes
            ; `repeat?`, logically), since it means we will just jump there
            ; after the next input (that is why it doesn't get a label).
            (if overlapped?
                [(inc col) [ch2 hl.group.unlabeled-match] nil]
                [col [ch1 hl.group.unlabeled-match] [ch2 hl.group.unlabeled-match]])

            overlapped?
            ; Note that the label keeps the same special highlight in the 2nd
            ; round. (It is important for a label to stay unchanged once shown
            ; up, if possible, else the eye might get confused, which kinda
            ; beats the purpose.)
            [(inc col) [ch2 overlapped-label-hl] nil]

            repeat?
            ; `repeat?` is mutually exclusive both with `(not labeled?)` and
            ; `overlapped?` (since only the second round takes place).
            ; Obviously, there is no need for a ch2-reminder in the first field.
            [(inc col) [ch2 label-hl] nil]

            :else
            ; Common case: new invocation, labeled, fully visible match.
            [col [ch1 hl.group.masked-ch] [ch2 label-hl]])]
      (hl:set-extmark (dec line)
                      (dec startcol)
                      {:virt_text [chunk1 ?chunk2]
                       :virt_text_pos "overlay"})))


(fn set-labeled-beacons [ch2 positions labels shortcuts
                         {: group-offset : repeat?}]
  (let [group-offset (or group-offset 0)
        |labels| (length labels)
        start (inc (* group-offset |labels|))
        ; Set one group of beacons that uses up the available target labels.
        set-group
        (fn [start distant?]
          (for [i start (dec (+ start |labels|))  ; end is inclusive
                :until (or (< i 1) (> i (length positions)))]
            (let [pos (. positions i)
                  ; 1-indexing is not a great match for modulo arithmetic.
                  label (or (. labels (% i |labels|))
                            (. labels |labels|))  ; when mod = 0
                  shortcut? (and (not distant?) (. shortcuts pos))]
              (set-beacon-at pos ch2 label {:labeled? true
                                            : distant?
                                            : repeat?
                                            : shortcut?}))))]
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
  (let [set-of-ch2s-in-matches (vim.tbl_keys match-map)
        potential-2nd-input? (fn [label]
                               (vim.tbl_contains set-of-ch2s-in-matches label))
        by-distance-from-cursor (fn [[[l1 c1] _ _] [[l2 c2] _ _]]
                                  (if (= l1 l2)
                                      (if reverse? (> c1 c2) (< c1 c2))
                                      (if reverse? (> l1 l2) (< l1 l2))))
        ; Step 1: Filter positions for which there is a label assigned,
        ;         and the label character is not a potential second input.
        shortcut-candidates {}
        _ (each [ch2 positions (pairs match-map)]
            (each [i pos (ipairs positions)]
              (let [labeled-pos? (not (or (= (length positions) 1)
                                          (and jump-to-first? (= i 1))))]
                (when labeled-pos?
                  ; In case of `jump-to-first?`, the i-th label is assigned
                  ; to the i+1th position (we skipped the first one).
                  ; Note: Shortcutting is only possible for the first
                  ; match group, we're ignoring the distant one(s)
                  ; (an idx > #-of-labels short-circuits here).
                  (match (. labels (if jump-to-first? (dec i) i))
                    label (when-not (potential-2nd-input? label)
                            ; Even if ending up using the shortcut,
                            ; we might need `ch2` for repeats.
                            (table.insert shortcut-candidates
                                          [pos label ch2])))))))
        ; Step 2: If there are multiple candidate positions with the same
        ;         label, we'd like to make the shortcut from the closest one.
        _ (table.sort shortcut-candidates by-distance-from-cursor)
        ; Step 3: Keep the first (i.e., closest) one among candidates
        ;         using the same label, and return a table allowing for
        ;         lookup both by position and by label.
        labels-used-up {}
        shortcuts {}
        _ (each [_ [pos label ch2] (ipairs shortcut-candidates)]
            (when-not (. labels-used-up label)
              (tset labels-used-up label true)
              (doto shortcuts
                (tset pos [label ch2])
                (tset label [pos ch2]))))]
    shortcuts))


(fn ignore-char-until-timeout [char-to-ignore]
  (let [start (os.clock)
        timeout-secs (/ opts.jump_on_partial_input_safety_timeout 1000)
        (ok? input) (getchar-as-str)]
    (when-not (and (= input char-to-ignore)
                   (< (os.clock) (+ start timeout-secs)))
      (when ok? (vim.fn.feedkeys input :i)))))

; //> Helpers

; State for 2-character search that is persisted between invocations.
(local sx {:state {:dot {:in1 nil
                         :in2 nil
                         :in3 nil
                         :x-mode? nil}
                   ; Enter-repeat uses these inputs too.
                   :cold {:in1 nil
                          :in2 nil
                          :reverse? nil
                          :x-mode? nil}}})

(fn sx.go [self reverse? invoked-in-x-mode? repeat-invoc]
  "Entry point for 2-character search."

  ; Overview ///

  ; local helper macros & functions
  ; -------------------------------
  ; #1 macro `with-highlight-chores`
  ; #2 macro `exit`
  ; #3 macro `exit-early`
  ; #4 fn    `save-state-for-repeat`
  ; #5 fn    `jump-wrapped!`
  ; #6 fn    `jump-and-ignore-ch2-until-timeout!`
  ; #7 fn    `select-match-group`

  ; algorithm skeleton
  ; ------------------
  ; get 1st input (in1) (direct input or persisted state)
  ; build 'match map' for in1
  ; if no match: exit-early (#3)
  ; elif only match:
  ;   save state for repeats & jump w/ timeout & exit (#4,#6,#2)
  ; else:
  ;   calculate 'shortcutable' positions
  ;   if new search (not persisted state):
  ;     light up beacons (see glossary) (#1)
  ;   get 2nd input (in2) (direct input or persisted state)
  ;   if in2 is a shortcut-label:
  ;     save state for repeats & jump & exit (#4,#5,#2)
  ;   else:
  ;     save state for repeats (#4)
  ;     if no match: exit-early (#3)
  ;     elif only match:
  ;       jump & exit (#5,#2)
  ;     else:
  ;       if auto-jump to first match is set: jump (#5)
  ;       if doing "cold" repeat:
  ;          light up beacons w/o labels (#1)
  ;          & get 3rd input & exit w/ feeding it (#2)
  ;       if not dot-repeating: light up beacons (#1)
  ;       loop for getting 3rd input (in3) (#7)
  ;          potentially switching match groups here,
  ;          the labels' referred targets might change
  ;       if in3 is a label in use:
  ;         jump & exit (#5,#2)
  ;       elif auto-jump to first match is set:
  ;         exit w/ feeding in3 (#2)
  ;       else: exit-early (#3)

  ; //> Overview

  (let [dot-repeat? (= repeat-invoc :dot)
        cold-repeat? (= repeat-invoc :cold)
        op-mode? (operator-pending-mode?)
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
        cmd-for-dot-repeat (replace-keycodes
                             (get-plug-key :sx reverse? invoked-in-x-mode? :dot))]

    (var x-mode? invoked-in-x-mode?)
    (var enter-repeat? nil)
    (var new-search? nil)

    ; Helpers ///

    (macro exit [...] `(exit-template :sx false ,...))
    (macro exit-early [...] `(exit-template :sx true ,...))

    (macro with-highlight-chores [...]
      `(do (when (and opts.grey_out_search_area (not cold-repeat?))
             (grey-out-search-area reverse?))
           (do ,...)
           (highlight-cursor)
           (vim.cmd :redraw)))

    (fn save-state-for-repeat [{: cold : dot}]
      (when new-search?
        (when cold 
          (set self.state.cold (doto cold
                                 (tset :x-mode? x-mode?)
                                 (tset :reverse? reverse?))))
        (when (and dot-repeatable-op? dot)
          (set self.state.dot (doto dot
                                (tset :x-mode? x-mode?))))))

    (local jump-wrapped!
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

    (fn jump-and-ignore-ch2-until-timeout! [[target-line target-col] ch2]
      (local from-pos (vim.tbl_map dec (get-cursor-pos)))  ; 1,1 -> 0,0
      ; Note to myself: what if `jump-to!` would return the final,
      ; adjusted position?
      (jump-wrapped! [target-line target-col])  ; 1,1
      (when new-search?
        ; Highlight new cursor position & operated area (in OP-mode).
        ; Jumping based on partial input is nice, but it's annoying that we
        ; don't see the actual changes right away (we are waiting for another
        ; input, so that we can introduce a safety timespan to ignore the
        ; character in the next column). Therefore we need to provide visual
        ; feedback, to tell the user that the target has been found, and they
        ; can continue editing.
        (let [ctrl-v (replace-keycodes "<c-v>")
              forward-x? (and x-mode? (not reverse?))
              backward-x? (and x-mode? reverse?)
              forced-motion (string.sub (vim.fn.mode :t) -1)
              to-col (if backward-x? (inc (inc target-col))
                         forward-x? (inc target-col)
                         target-col)
              to-pos (vim.tbl_map dec [target-line to-col])  ; 1,1 -> 0,0
              ; Preliminary boundaries of the highlighted - operated - area
              ; (forced-motion might affect these).
              [startline startcol &as start] (if reverse? to-pos from-pos)
              [_ endcol &as end] (if reverse? from-pos to-pos)
              ; In OP-mode, the cursor always ends up at the beginning of the
              ; area, and that is _not_ necessarily our targeted position.
              ?highlight-cursor-at (when op-mode?
                                     (->> (if (= forced-motion ctrl-v)
                                              ; For blockwise mode, we need to find
                                              ; the top/leftmost "corner". 
                                              [startline (math.min startcol endcol)]
                                              ; Otherwise, in the forward direction,
                                              ; we need to stay at the _start_
                                              ; position with our virtual cursor.
                                              (not reverse?)
                                              from-pos)
                                          (vim.tbl_map inc)))]  ; 0,0 -> 1,1 (`highlight-cursor`)
          (when-not change-op?  ; then we're entering insert mode anyway (cannot move away)
            (highlight-cursor ?highlight-cursor-at))  ; nil = at the actual position
          (when op-mode?
            (highlight-range hl.group.pending-op-area start end
                             {: forced-motion :inclusive-motion? forward-x?}))
          (vim.cmd :redraw)
          (ignore-char-until-timeout ch2)
          ; Mitigate blink on the command line
          ; (see also `handle-interrupted-change-op!`).
          (when change-op? (echo ""))
          (hl:cleanup))))

    (fn select-match-group [in2 positions-to-label shortcuts enter-repeat?]
      (var ret nil)
      (var group-offset 0)
      (var loop? true)
      (while loop?
        (match (or (when dot-repeat? self.state.dot.in3)
                   (get-input-and-clean-up)
                   (do (set loop? false)  ; <esc> or <c-c> should exit the loop
                       (set ret nil)
                       nil))
          input
          (if (not (one-of? input cycle-fwd-key cycle-bwd-key))
              ; Note: dot-repeat arrives here, and short-circuits.
              (do (set loop? false)
                  (set ret [group-offset input]))
              ; Cycle to and highlight the next/previous group.
              (let [max-offset (math.floor (/ (length positions-to-label)
                                              (length labels)))]
                (set group-offset (-> group-offset
                                      ((match input cycle-fwd-key inc _ dec))
                                      (clamp 0 max-offset)))
                (with-highlight-chores
                  (set-labeled-beacons
                    in2 positions-to-label labels shortcuts
                    {: group-offset :repeat? enter-repeat?}))))))
      ret)

    ; //> Helpers

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

    (enter :sx)

    (when-not repeat-invoc
      (echo "")  ; Clean up the command line.
      (with-highlight-chores
        (when opts.highlight_unique_chars
          (highlight-unique-chars reverse?))))

    (match (if dot-repeat? (do (set x-mode? self.state.dot.x-mode?)
                               self.state.dot.in1)
               cold-repeat? self.state.cold.in1
               (match (or (get-input-and-clean-up)
                          (exit-early))
                 ; Here we can handle any other modifier key as "zeroth" input,
                 ; if the need arises (e.g. regex search).
                 ; TODO: Refactor this block...
                 in0 (do (match in0
                           "\r" (set enter-repeat? true)
                           x-mode-prefix-key (set x-mode? true))
                         (var res in0)
                         (when (and x-mode? (not invoked-in-x-mode?))
                           ; Get the "true" first input then.
                           (match (or (get-input-and-clean-up)
                                      (exit-early))
                             "\r" (set enter-repeat? true)
                             in0* (set res in0*)))
                         (set new-search? (not (or repeat-invoc enter-repeat?)))
                         (if enter-repeat? (or self.state.cold.in1
                                               (exit-early
                                                 (echo-no-prev-search)))
                             res))))
      in1
      (let [prev-in2 (if (or cold-repeat? enter-repeat?) self.state.cold.in2
                         dot-repeat? self.state.dot.in2)]
        (match (or (get-match-map-for in1 reverse?)
                   (exit-early
                     (echo-not-found (.. in1 (or prev-in2 "")))))
          [ch2 pos &as only-match]
          (if (or new-search? (= ch2 prev-in2))
              ; Successful exit, option #1: jump to a unique character right after the first input.
              (exit
                (save-state-for-repeat {:cold {: in1 :in2 ch2}
                                        :dot {: in1 :in2 ch2 :in3 (. labels 1)}})
                (jump-and-ignore-ch2-until-timeout! pos ch2))
              (exit-early
                (echo-not-found (.. in1 prev-in2))))

          match-map
          (let [shortcuts (get-shortcuts match-map labels reverse? jump-to-first?)]
            (when new-search?
              ; Initial round of setting beacons, for all possible targets.
              ; (Assigning labels for each list of positions independently.)
              (with-highlight-chores
                (each [ch2 positions (pairs match-map)]
                  (let [[first & rest] positions
                        positions-to-label (if jump-to-first? rest positions)]
                    ; If `rest` is empty (only one match for `ch2`), we will jump anyway.
                    (when (or jump-to-first? (empty? rest))  ; Fennel gotcha: empty rest = [], _not_ nil
                      ; Highlight these pairs with a "direct route" differently.
                      (set-beacon-at first in1 ch2 {}))
                    (when-not (empty? rest)
                      (set-labeled-beacons
                        ch2 positions-to-label labels shortcuts {}))))))
            (match (or prev-in2
                       (get-input-and-clean-up)
                       (exit-early))
              in2
              (match (when new-search? (. shortcuts in2))
                [pos ch2 &as shortcut]
                ; Successful exit, option #2: selecting a shortcut-label.
                (exit
                  (save-state-for-repeat {:cold {: in1 :in2 ch2}
                                          :dot {: in1 :in2 ch2 :in3 in2}})
                  (jump-wrapped! pos))

                _
                (do
                  (save-state-for-repeat
                    {:cold {: in1 : in2}  ; endnote #1
                     ; For the moment, set the first match as the target.
                     :dot {: in1 : in2 :in3 (. labels 1)}})
                  (match (or (. match-map in2)
                             (exit-early
                               (echo-not-found (.. in1 in2))))
                    positions
                    ; TODO: Refactor this part...
                    (let [[[line col &as first] & rest] positions
                          [f-rest & r-rest] rest
                          ; Skipping makes no sense in the forward direction,
                          ; since in OP-mode (when we land before the target)
                          ; we always have to choose a label.
                          [next-line next-col] (vim.fn.searchpos "\\_." :nWb)
                          skip-one? (and cold-repeat? x-mode? reverse?
                                         ; The first match is found at the saved
                                         ; neighbouring position. (`(dec next-col)`
                                         ; is an OK hack here, as a match can
                                         ; only be on one line at once.)
                                         (= line next-line) (= col (dec next-col)))
                          [first rest positions] (if skip-one?
                                                     [f-rest r-rest rest]
                                                     [first rest positions])
                          ; TODO: add `cold-repeat?` here when implementing
                          ;       the labeled version.
                          positions-to-label (if jump-to-first? rest positions)]
                      (when (and first  ; there might be none if skipped one
                                 (or cold-repeat? jump-to-first? (empty? rest)))
                        (jump-wrapped! first))
                      (if (empty? rest)
                          ; Successful exit, option #3: jumped to the only match
                          ; automatically.
                          (exit)
                          ; A special exit point - in case of "cold" repeat, we
                          ; just wait for another input & unconditionally
                          ; feed it, to be able to highlight the remaining
                          ; matches in a clean way.
                          cold-repeat?
                          (when-not op-mode?
                            (with-highlight-chores
                              (each [_ [line col] (ipairs rest)]
                                (hl:add-hl hl.group.one-char-match
                                           (dec line) (dec col) (inc col))))
                              (exit
                                (-> (or (get-input-and-clean-up) "")
                                    (vim.fn.feedkeys :i))))
                          (do
                            ; Operations that spanned multiple groups are dot-repeated as
                            ; <enter>-repeat, i.e., only the search pattern is saved then
                            ; (endnote #3).
                            (when-not (and dot-repeat? self.state.dot.in3)
                              ; Lighting up beacons again, now only for pairs with `in2`
                              ; as second character.
                              (with-highlight-chores
                                (set-labeled-beacons
                                  in2 positions-to-label labels shortcuts
                                  {:repeat? enter-repeat?})))
                            (match (or (select-match-group in2 positions-to-label
                                                           shortcuts enter-repeat?)
                                       (exit-early))  ; <C-c> (note: no highlight to clean up)
                              [group-offset in3]
                              (do
                                ; Reminder: above we have already set this to the character
                                ; of the first label, as a default. (We might had only one
                                ; match, and jumped automatically, not reaching this point.)
                                ; If the operation spanned multiple groups, we are switching
                                ; dot-repeat to <enter>-repeat (endnote #3).
                                (when (and dot-repeatable-op? (not dot-repeat?))
                                  (set self.state.dot.in3 (if (= group-offset 0) in3 nil)))
   *                            ; Valid label, currently in use (in the active match group)?
                                (match (-?>> (. (reverse-lookup labels) in3)  ; (?)label-idx
                                             (+ (* group-offset (length labels))) ; position-idx
                                             (. positions-to-label))  ; (?)position
                                  ; Successful exit, option #4: selecting an active label.
                                  pos (exit
                                        (jump-wrapped! pos))
                                  _ (if jump-to-first?
                                        ; Successful exit, option #5: falling through with any
                                        ; non-label key in "autojump" mode (so that we can
                                        ; continue editing right away).
                                        (exit
                                          (vim.fn.feedkeys in3 :i))
                                        (exit-early))))))))))))))))))


; Handling editor options ///1

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


; Mappings ///1

(fn set-plug-keys []
  (local plug-keys
    [
     ; params: reverse? [x-mode?] [repeat-invoc]
     ["<Plug>Lightspeed_s" "sx:go(false)"]
     ["<Plug>Lightspeed_S" "sx:go(true)"]
     ["<Plug>Lightspeed_x" "sx:go(false, true)"]
     ["<Plug>Lightspeed_X" "sx:go(true, true)"]

     ; params: reverse? [t-mode?] [repeat-invoc]
     ["<Plug>Lightspeed_f" "ft:go(false)"]
     ["<Plug>Lightspeed_F" "ft:go(true)"]
     ["<Plug>Lightspeed_t" "ft:go(false, true)"]
     ["<Plug>Lightspeed_T" "ft:go(true, true)"]

     ; "cold" repeat (;/,-like) (note: we should not start the name with ft_ or sx_ if using `hasmapto`)
     ["<Plug>Lightspeed_;_sx" "sx:go(require'lightspeed'.sx.state.cold['reverse?'], require'lightspeed'.sx.state.cold['x-mode?'], 'cold')"]
     ["<Plug>Lightspeed_,_sx" "sx:go(not require'lightspeed'.sx.state.cold['reverse?'], require'lightspeed'.sx.state.cold['x-mode?'], 'cold')"]

     ["<Plug>Lightspeed_;_ft" "ft:go(require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"]
     ["<Plug>Lightspeed_,_ft" "ft:go(not require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"]

     ; TODO: let these repeat the last one
     ["<Plug>Lightspeed_;" "ft:go(require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"]
     ["<Plug>Lightspeed_," "ft:go(not require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"]
     ])

  (each [_ [lhs rhs-call] (ipairs plug-keys)]
    (each [_ mode (ipairs [:n :x :o])]
      (api.nvim_set_keymap mode lhs (.. "<cmd>lua require'lightspeed'." rhs-call "<cr>")
                           {:noremap true :silent true})))
  
  ; Just for our convenience, to be used here in the script.
  (each [_ [lhs rhs-call]
         (ipairs
           [["<Plug>Lightspeed_dotrepeat_s" "sx:go(false, false, 'dot')"]
            ["<Plug>Lightspeed_dotrepeat_S" "sx:go(true, false, 'dot')"]
            ["<Plug>Lightspeed_dotrepeat_x" "sx:go(false, true, 'dot')"]
            ["<Plug>Lightspeed_dotrepeat_X" "sx:go(true, true, 'dot')"]

            ["<Plug>Lightspeed_dotrepeat_f" "ft:go(false, false, 'dot')"]
            ["<Plug>Lightspeed_dotrepeat_F" "ft:go(true, false, 'dot')"]
            ["<Plug>Lightspeed_dotrepeat_t" "ft:go(false, true, 'dot')"]
            ["<Plug>Lightspeed_dotrepeat_T" "ft:go(true, true, 'dot')"]])]
    (api.nvim_set_keymap :o lhs (.. "<cmd>lua require'lightspeed'." rhs-call "<cr>")
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


; Init ///1

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


; Endnotes ///1

; (1) These should be saved right here, because the repeated search
;     might have a match anyway.

; (2) This is in fact coupled with `onscreen-match-positions`, so it's
;     _much_ cleaner to implement the logic here than in `count`. In
;     that case, we would have to duplicate the whole logic of
;     transforming the input to the actual pattern (that might get
;     arbitrarily complex with future enhancements).
;     In the case of instant-repeating t/T, we _have to_ skip the first
;     match, else we would find the same target in front of us again and
;     again, and be stuck. Note that we could have solved that with a
;     simple increment of `count`, without any complex checks, because
;     when instant-repeating, we know that we should be right before a
;     match - but as we have already implemented this hack for
;     cold-repeat, it makes sense to let this handle instant-repeat too.

; (3) It makes no practical sense to dot-repeat an operation spanning
;     multiple groups exactly as it went ("delete again till the 27th
;     match..."?). The most intuitive/logical behaviour is repeating as
;     <enter>-repeat in these cases, prompting for a target label again.


; Module ///1

{: opts
 : setup
 : ft
 : sx

 :save_editor_opts save-editor-opts
 :set_temporary_editor_opts set-temporary-editor-opts
 :restore_editor_opts restore-editor-opts

 :init_highlight init-highlight
 :set_default_keymaps set-default-keymaps}


; vim: foldmethod=marker foldmarker=///,//>
