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
          (icollect [_ y (ipairs (table.pack ...))]
            `(= ,x ,y)))))

(macro when-not [condition ...]
  `(when (not ,condition) ,...))

; }}}
; Nvim utils {{{

(fn echo [msg]
  (vim.cmd :redraw) (api.nvim_echo [[msg]] false []))

(fn replace-vim-keycodes [s]
  (api.nvim_replace_termcodes s true false true))

(fn operator-pending-mode? []
  (-> (. (api.nvim_get_mode) :mode) (string.match "o")))

(fn yank-operation? [] (and (operator-pending-mode?) (= vim.v.operator :y)))
(fn change-operation? [] (and (operator-pending-mode?) (= vim.v.operator :c)))
(fn delete-operation? [] (and (operator-pending-mode?) (= vim.v.operator :d)))
(fn dot-repeatable-operation? [] (and (operator-pending-mode?) (not= vim.v.operator :y)))

(fn get-current-pos []
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
           :full_inclusive_prefix_key "<c-x>"
           :cycle_group_fwd_key nil
           :cycle_group_bwd_key nil
           :labels nil})

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


(fn init-highlight []
  (local bg vim.o.background)
  (local groupdefs
    [[hl.group.label                    {:guifg (match bg :light "#f02077" _ "#ff2f87")
                                         :ctermfg "Red"
                                         :gui "bold,underline"
                                         :cterm "bold,underline"}]
     [hl.group.label-overlapped         {:guifg (match bg :light "#ff4090" _ "#e01067")
                                         :ctermfg "Magenta"
                                         :gui "underline"
                                         :cterm "underline"}]
     [hl.group.label-distant            {:guifg (match bg :light "#399d9f" _ "#99ddff")
                                         :ctermfg (match bg :light "Blue" _ "Cyan")
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
     [hl.group.masked-ch                {:guifg "#cc9999" :ctermfg "DarkGrey"}]
     [hl.group.unlabeled-match          {:guifg (match bg :light "#272020" _ "#f3ecec")
                                         :ctermfg (match bg :light "Black" _ "White")
                                         :gui "bold"
                                         :cterm "bold"}]
     [hl.group.pending-op-area          {:guibg "#f00077" :ctermbg "Red"
                                         :guifg "#ffffff" :ctermfg "White"}]  ; ~shortcut without bold/underline
     [hl.group.pending-change-op-area   {:guifg (match bg :light "#f02077" _ "#ff2f87")
                                         :ctermfg "Red"
                                         :gui "strikethrough"
                                         :cterm "strikethrough"}]
     [hl.group.greywash                 {:guifg "#777777" :ctermfg "Grey"}]])
  (each [_ [group attrs] (ipairs groupdefs)]
    (let [attrs-str (-> (icollect [k v (pairs attrs)] (.. k "=" v))
                        (table.concat " "))]
      ; "default" = do not override any existing definition for the group.
      (vim.cmd (.. "highlight default " group " " attrs-str))))
  (each [_ [from-group to-group]
         (ipairs [[hl.group.unique-ch hl.group.unlabeled-match]
                  [hl.group.shortcut-overlapped hl.group.shortcut]
                  [hl.group.cursor "Cursor"]])]
    (vim.cmd (.. "highlight default link " from-group " " to-group))))

(init-highlight)


; Colorscheme plugins might clear out our highlight definitions, without
; defining their own. See: https://github.com/phaazon/hop.nvim/issues/35
(fn add-highlight-autocmds []
  (vim.cmd "augroup LightspeedInitHighlight")
  (vim.cmd "autocmd!")
  (vim.cmd "autocmd ColorScheme * lua require'lightspeed'.init_highlight()")
  (vim.cmd "augroup end"))

(add-highlight-autocmds)


; Expects 0,0-indexed args; `endcol` is exclusive.
(fn highlight-area-between [[startline startcol] [endline endcol] hl-group]
  (let [add-hl (partial hl:add-hl hl-group)]
    (if (= startline endline)
      (add-hl startline startcol endcol)
      (do (add-hl startline startcol -1)
          (for [line (inc startline) (dec endline)] (add-hl line 0 -1))
          (add-hl endline 0 endcol)))))


(fn grey-out-search-area [reverse?]
  (let [[curline curcol] (vim.tbl_map dec (get-current-pos))
        [win-top win-bot] [(dec (vim.fn.line "w0")) (dec (vim.fn.line "w$"))]
        [startpos endpos] (if reverse?
                            [[win-top 0] [curline curcol]]  ; endpos has exclusive col
                            [[curline (inc curcol)] [win-bot -1]])]
    (highlight-area-between startpos endpos hl.group.greywash)))

; }}}
; Common {{{

(fn echo-no-prev-search [] (echo "no previous search"))
(fn echo-not-found [s] (echo (.. "not found: " s)))


(fn get-char []
  (let [ch (vim.fn.getchar)]
    (if (= (type ch) :number) (vim.fn.nr2char ch) ch)))


(fn force-statusline-update []
  ; Heartfelt thanks: https://vi.stackexchange.com/a/17876
  (set vim.o.statusline vim.o.statusline))


(fn push-cursor! [direction]
  "Push cursor 1 character to the left or right, possibly beyond EOL."
  (vim.fn.search "\\_." (match direction :fwd "W" :bwd "bW") ?stopline))


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
      (local [line col &as from-pos] (get-current-pos))
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
  (let [[line col &as pos] (or ?pos (get-current-pos))
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
    (-> (replace-vim-keycodes (.. "<C-\\><C-G>" ?right))  ; :h CTRL-\_CTRL-G
        (api.nvim_feedkeys :n true))))


; The primary purpose is not the wrapping of the interrupted-change
; handler, (it's just a bonus that we can hide that here to), but to
; enforce and encapsulate the requirement that the tail-positioned
; "exit" forms in the match blocks should always return nil. (Interop
; with side-effecting VimL functions can be dangerous, they might return
; 0 for example, like `feedkey`, and with that they can screw up Fennel
; match forms in a breeze, resulting in misterious bugs, so it's better
; to be paranoid.)
; Caveat: be sure _not_ to call this twice accidentally,
; `handle-interrupted-change-op!` might move the cursor twice then!
(macro exit-with [...]
  `(do (when (change-operation?) (handle-interrupted-change-op!))
       (do ,...)
       nil))


(fn get-input-and-clean-up []
  (let [(ok? res) (pcall get-char)]  ; Handling <C-c>.
    (hl:cleanup)  ; Cleaning up after every input religiously 
                  ; (trying to work in a more or less stateless manner).
    (if (and ok? (not= res (replace-vim-keycodes "<esc>"))) res  ; <esc> cleanly exits anytime.
        (exit-with nil))))


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
                     (replace-vim-keycodes "<c-r>.<esc>"))
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
           :prev-t-like? nil
           :prev-search nil
           :prev-dot-repeatable-search nil})

(fn ft.to [self reverse? t-like? dot-repeat?]
  "Entry point for 1-character search."
  (let [{: instant-repeat? : started-reverse?} self
        _ (when-not instant-repeat? (set self.started-reverse? reverse?))
        ; f/t always continue in the original direction (and F/T in the
        ; reverse of the original).
        reverse? (if instant-repeat?
                   (or (and (not reverse?) started-reverse?)
                       (and reverse? (not started-reverse?)))
                   reverse?)
        ; When instant-repeating t-like motion, we increment the count by one,
        ; else we would find the same target in front of us again and again,
        ; and be stuck.
        count (if (and instant-repeat? t-like?) (inc vim.v.count1) vim.v.count1)
        op-mode? (operator-pending-mode?)
        dot-repeatable-op? (dot-repeatable-operation?)
        motion (if (and (not t-like?) (not reverse?)) "f"
                   (and (not t-like?) reverse?) "F"
                   (and t-like? (not reverse?)) "t"
                   (and t-like? reverse?) "T")
        cmd-for-dot-repeat (.. (replace-vim-keycodes "<Plug>Lightspeed_repeat_") motion)]

    (when-not (or instant-repeat? dot-repeat?)
      (echo "") (highlight-cursor) (vim.cmd :redraw))

    (var repeat? nil)
    (match (if instant-repeat? self.prev-search
               dot-repeat? self.prev-dot-repeatable-search
               (match (get-input-and-clean-up)
                 "\r" (do (set repeat? true)
                          (or self.prev-search
                              (exit-with (echo-no-prev-search))))
                 in in))
      in1
      (let [new-search? (not (or repeat? instant-repeat? dot-repeat?))] 
        (when new-search?  ; endnote #1
          (if dot-repeatable-op?
            (do (set self.prev-dot-repeatable-search in1)
                (set-dot-repeat cmd-for-dot-repeat count))
            (do (set self.prev-search in1)
                (set self.prev-t-like? t-like?))))
        (var i 0)
        (var target-pos nil)
        (each [[line col &as pos] 
               (let [pattern (.. "\\V" (in1:gsub "\\" "\\\\"))
                     limit (when opts.limit_ft_matches (+ count opts.limit_ft_matches))]
                 (onscreen-match-positions pattern reverse? {:ft-search? true : limit}))]
          (++ i)
          (if (<= i count) (set target-pos pos)
              (when-not op-mode?
                (hl:add-hl hl.group.one-char-match (dec line) (dec col) col))))
        (if (= i 0) (exit-with (echo-not-found in1))  ; note: no highlight to clean up if no match found
            (do
              (when-not instant-repeat? (vim.cmd "norm! m`"))  ; save start position on jumplist (endnote #2)
              (vim.fn.cursor target-pos)
              (when t-like? (push-cursor! (if reverse? :fwd :bwd)))
              (when (and op-mode? (not reverse?)) (push-cursor! :fwd))  ; endnote #3
              ; Set instant-repeat.
              (when-not op-mode?
                (highlight-cursor) (vim.cmd :redraw)
                (local (ok? in2) (pcall get-char))  ; pcall for handling <C-c>
                (set self.instant-repeat?
                     (and ok? (string.match (vim.fn.maparg in2) "<Plug>Lightspeed_[fFtT]")))
                (vim.fn.feedkeys (if ok? in2 (replace-vim-keycodes "<esc>")) :i))
              (hl:cleanup)))))))

; }}}
; 2-character search {{{

(fn get-labels []
  (or opts.labels
      (if opts.jump_to_first_match
        ["s" "f" "n" "/" "u" "t" "q" "S" "F" "G" "H" "L" "M" "N" "?" "U" "R" "Z" "T" "Q"]
        ["f" "j" "d" "k" "s" "l" "a" ";" "e" "i" "w" "o" "g" "h" "v" "n" "c" "m" "z" "."])))


(fn get-cycle-keys []
  [(replace-vim-keycodes
     (or opts.cycle_group_fwd_key (if opts.jump_to_first_match "<tab>" "<space>")))
   (replace-vim-keycodes
     (or opts.cycle_group_bwd_key (if opts.jump_to_first_match "<s-tab>" "<tab>")))])


(fn get-match-map-for [ch1 reverse?]
  "Return a map that stores the positions of all on-screen pairs starting
with `ch1` in separate ordered lists, keyed by the succeeding char."
  (let [match-map {}  ; {str [[1,1,bool]]} i.e. {successor-char [[line,col,partially-covered?]]}
        prefix "\\V\\C"                   ; force matching case (for the moment)
        input (ch1:gsub "\\" "\\\\")      ; backslash still needs to be escaped for \V
        pattern (.. prefix input "\\.")]  ; match anything except EOL after it
    (var match-count 0)
    ; Saving some of the search state locally, in order to discover overlaps.
    (var prev {})
    (each [[line col &as pos] (onscreen-match-positions pattern reverse? {})]
      (let [overlap-with-prev? (and (= line prev.line)
                                    (= col ((if reverse? dec inc) prev.col)))
            ch2 (char-at-pos pos {:char-offset 1})
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


(fn set-beacon-at [[line col partially-covered? &as pos] field1-ch field2-ch
                   {: init-round? : repeat? : distant? : unlabeled? : shortcut?}]
  (let [; When repeating, there is no initial round, i.e., no overlaps
        ; possible (triplets of the same character are _always_ skipped).
        partially-covered? (when-not repeat? partially-covered?)
        ; Similar situation with shortcuts.
        shortcut? (when-not repeat? shortcut?)
        label-hl (if shortcut? hl.group.shortcut
                     distant? hl.group.label-distant 
                     hl.group.label)
        overlapped-label-hl (if distant? hl.group.label-distant-overlapped
                                (if shortcut? hl.group.shortcut-overlapped
                                    hl.group.label-overlapped))
        ; TODO: We should refactor the following so that we always start
        ;       the extmark in the first column, and adjust the virtual
        ;       text accordingly - this is very confusing now.
        [col chunk1 ?chunk2]
        (if unlabeled?  ; a first ("autojumpable") match
            ; `unlabeled?` presupposes `init-round?` (and excludes `repeat?`,
            ; logically), since it means we will (would) just jump there after
            ; the next input (that is why it doesn't get a label in the first
            ; place).
            (if partially-covered?
              [(inc col) [field2-ch hl.group.unlabeled-match] nil]
              [col [field1-ch hl.group.unlabeled-match] [field2-ch hl.group.unlabeled-match]])

            partially-covered?  ; labeled
            (if init-round?
              [(inc col) [field2-ch overlapped-label-hl] nil]
              ; The full beacon is shown now in the 2nd round, but the label
              ; keeps the same special highlight. (It is important for a label
              ; to stay unchanged once shown up, if possible, else the eye might
              ; get confused, which kinda beats the purpose.)
              [col [field1-ch hl.group.masked-ch] [field2-ch overlapped-label-hl]])

            ; `repeat?` is mutually exclusive both with `unlabeled?` and
            ; `partially-covered?` (since only the second round takes place).
            ; Obviously, there is no need for a ch2-reminder in the first field.
            repeat?
            [(inc col) [field2-ch label-hl] nil]

            ; Common case: labeled, fully visible match, new invocation.
            :else [col [field1-ch hl.group.masked-ch] [field2-ch label-hl]])]
      (hl:set-extmark (dec line) (dec col) {:end_col col
                                            :virt_text [chunk1 ?chunk2]
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
                        (set-beacon-at pos ch2 label {: init-round? : distant?
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
        (ok? input) (pcall get-char)]
    (when-not (and (= input char-to-ignore) (< (os.clock) (+ start timeout-secs)))
      (when ok? (vim.fn.feedkeys input :i)))))


; State for 2-character search that is persisted between invocations.
(local s {:prev-search {:in1 nil :in2 nil}
          :prev-dot-repeatable-search {:in1 nil :in2 nil :in3 nil :full-incl? nil}})

(fn s.to [self reverse? dot-repeat?]
  "Entry point for 2-character search."
  (let [op-mode? (operator-pending-mode?)
        change-op? (change-operation?)
        delete-op? (delete-operation?)
        dot-repeatable-op? (dot-repeatable-operation?)
        full-inclusive-prefix-key (replace-vim-keycodes opts.full_inclusive_prefix_key)
        [cycle-fwd-key cycle-bwd-key] (get-cycle-keys)
        labels (get-labels)
        label-indexes (reverse-lookup labels)
        ; We _never_ want to autojump in OP mode, since that would execute
        ; the operation without allowing us to select a labeled target.
        jump-to-first? (and opts.jump_to_first_match (not op-mode?))
        cmd-for-dot-repeat (replace-vim-keycodes
                             (.. "<Plug>Lightspeed_repeat_" (if reverse? "S" "s")))]

    (macro with-hl-chores [...]
      `(do (when opts.grey_out_search_area (grey-out-search-area reverse?))
           (do ,...)
           (highlight-cursor)
           (vim.cmd :redraw)))

    (fn save-state-for [{: repeat : dot-repeat}]
      ; Arbitrary choice: let dot-repeat _not_ update the previous
      ; normal/visual/yank search - this seems more useful.
      (if dot-repeatable-op?
        (set self.prev-dot-repeatable-search dot-repeat)
        (set self.prev-search repeat)))

    ; `first-jump?` should only be persisted inside `to` (i.e. the lifetime is
    ; one invocation) and should be managed by the function itself (it is
    ; error-prone if we have to set a flag manually), so setting up a closure
    ; here.
    (local jump-to!
      (do (var first-jump? true)
          (fn [pos full-incl?]
            (when (and dot-repeatable-op? (not dot-repeat?))
              (set-dot-repeat cmd-for-dot-repeat))
            ; When jumping to a labeled target _after_ an autojump, do not
            ; register the intermediate step on the jumplist.
            (when first-jump?
              (vim.cmd "norm! m`")  ; save start position on jumplist (endnote #2)
              (set first-jump? false))
            (vim.fn.cursor pos)
            (when (and full-incl? (not reverse?))
              (push-cursor! :fwd) (when op-mode? (push-cursor! :fwd))))))  ; endnote #3

    (fn jump-and-ignore-ch2-until-timeout! [[line col _ &as pos] full-incl? new-search? ch2]
      (let [from-pos (get-current-pos)]
        (jump-to! pos full-incl?)
        (when new-search?
          ; Jumping based on partial input is nice, but in case operators, it's
          ; annoying that we don't see the operation executed right away, so
          ; here are a couple of hacks:
          (when-not change-op?
            ; In OP-mode, the cursor always ends up at the beginning of the
            ; area - in the reverse direction, that means the jump target.
            (highlight-cursor (when (and op-mode? (not reverse?)) from-pos)))
          (when op-mode?
            (let [[from-pos to-pos] [(vim.tbl_map dec from-pos) [(dec line) (dec col)]]
                  [startpos endpos] (if reverse? [to-pos from-pos] [from-pos to-pos])
                  hl-group (if (or change-op? delete-op?)
                             hl.group.pending-change-op-area
                             hl.group.pending-op-area)]
                ; The column in `endpos` is exclusive, but that's OK, since the
                ; operations are exclusive themselves, and we do not want to
                ; include the target position in the highlight.
                (highlight-area-between startpos endpos hl-group)))
          (vim.cmd :redraw)
          (ignore-char-until-timeout ch2)
          ; Mitigate blink on the command line (see also `handle-interrupted-change-op!`).
          (when change-op? (echo ""))
          (hl:cleanup))))

    (fn cycle-through-match-groups [in2 positions-to-label shortcuts repeat?]
      (var ret nil)
      (var group-offset 0)
      (var loop? true)
      (while loop? 
        (match (or (when dot-repeat? self.prev-dot-repeatable-search.in3)
                   (get-input-and-clean-up)
                   ; Beware of calling `exit-with` again, after
                   ; `get-input-and-clean-up`. (As of now, it calls
                   ; `handle-interrupted-change-op!` automatically.)
                   (do (set loop? false) (set ret nil)))  ; <esc> should exit the loop
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
                                   {: group-offset : repeat?}))))))
      ret)

    ; After all the stage-setting, here comes the main action you've all been
    ; waiting for:

    (when-not dot-repeat?
      (echo "")  ; Clean up the command line.
      (with-hl-chores
        (when opts.highlight_unique_chars (highlight-unique-chars reverse?))))

    (var repeat? nil)
    (var new-search? nil)
    (var full-incl? nil)

    ; A note on a design decision: when a function encapsulates an inherently
    ; complex flow of logic, it is most important to get a good overview of the
    ; happy path as quickly as possible. Matched forms seem a good place to hide
    ; any kind of error-handling/teardown/afterthoughts inside them, at the cost
    ; of being more obscure themselves. However, the advantage is that whenever
    ; we get something (non-nil) out of a form, we can be sure that we have a
    ; valid input and a clean state that we can continue to work with, simple as
    ; that.

    (match (if dot-repeat?
             (do (set full-incl? self.prev-dot-repeatable-search.full-incl?)
                 self.prev-dot-repeatable-search.in1)
             (match (get-input-and-clean-up)
               ; Here we can handle any other modifier keys as "zeroth" input,
               ; if the need arises (e.g. regex search).
               in0 (do (set repeat? (= in0 "\r"))  ; User hit <enter> right away: repeat previous search.
                       (set new-search? (not (or repeat? dot-repeat?)))
                       (set full-incl? (= in0 full-inclusive-prefix-key))
                       (if repeat? (or self.prev-search.in1
                                       (exit-with (echo-no-prev-search)))
                           full-incl? (get-input-and-clean-up)  ; Get the "true" first input.
                           in0))))
      in1
      (match (or (get-match-map-for in1 reverse?)
                 (exit-with (echo-not-found 
                              (if repeat? (.. in1 self.prev-search.in2)
                                  dot-repeat? (.. in1 self.prev-dot-repeatable-search.in2)
                                  in1))))
        [ch2 pos]
        ; Successful exit, option #1: jump to a unique character right after the first input.
        (if (or new-search?
                (and repeat? (= ch2 self.prev-search.in2))
                (and dot-repeat? (= ch2 self.prev-dot-repeatable-search.in2)))
          (do (when new-search? 
                (save-state-for {:repeat {: in1 :in2 ch2}
                                 :dot-repeat {: in1 :in2 ch2 :in3 (. labels 1) : full-incl?}}))
              (jump-and-ignore-ch2-until-timeout! pos full-incl? new-search? ch2))
          (exit-with (echo-not-found (.. in1 ch2))))

        match-map
        (let [shortcuts (get-shortcuts match-map labels reverse? jump-to-first?)]
          (when new-search?
            ; Initial round of setting beacons, for all possible targets.
            ; (Assigning labels for each list of positions independently.)
            (with-hl-chores
              (each [ch2 positions (pairs match-map)]
                (let [[first & rest] positions]
                  ; If `rest` is empty (only one match for `ch2`), we will jump anyway.
                  (when (or jump-to-first? (empty? rest))  ; Fennel gotcha: empty rest = [], _not_ nil
                    ; Highlight these pairs with a "direct route" differently.
                    (set-beacon-at first in1 ch2 {:init-round? true :unlabeled? true}))
                  (when-not (empty? rest)
                    (let [positions-to-label (if jump-to-first? rest positions)]
                      (set-beacon-groups ch2 positions-to-label labels shortcuts
                                         {:init-round? true})))))))
          (match (if repeat? self.prev-search.in2
                     dot-repeat? self.prev-dot-repeatable-search.in2
                     (get-input-and-clean-up))
            in2
            (match (when new-search? (. shortcuts in2))
              ; Successful exit, option #2: selecting a shortcut-label.
              [pos ch2] (do (save-state-for {:repeat {: in1 :in2 ch2}  ; implicit `new-search?`
                                             :dot-repeat {: in1 :in2 ch2 :in3 in2 : full-incl?}})
                            (jump-to! pos full-incl?))
              nil  ; no shortcut found
              (do
                (when new-search?  ; endnote #1
                  (save-state-for {:repeat {: in1 : in2}
                                   ; For the moment, set the first match as the target.
                                   ; (Food for thought: is there a reason _not_ to save
                                   ; dot-repeat state too for a possibly unsuccesful
                                   ; search, once we have the full search pattern?)
                                   :dot-repeat {: in1 : in2 :in3 (. labels 1) : full-incl?}}))
                (match (or (. match-map in2)
                           (exit-with (echo-not-found (.. in1 in2))))
                  positions
                  (let [[first & rest] positions]
                    (when (or jump-to-first? (empty? rest))
                      ; Succesful exit, option #3: jumping to the only match automatically.
                      (jump-to! first full-incl?)
                      (when jump-to-first? (force-statusline-update)))
                    (when-not (empty? rest)
                      ; Else lighting up beacons again, now only for pairs with `in2`
                      ; as second character.
                      (let [positions-to-label (if jump-to-first? rest positions)]
                        ; Operations that spanned multiple groups are dot-repeated as
                        ; <enter>-repeat, i.e., only the search pattern is saved then
                        ; (endnote #4).
                        (when-not (and dot-repeat? self.prev-dot-repeatable-search.in3)
                          (with-hl-chores
                            (set-beacon-groups in2 positions-to-label labels shortcuts
                                               {: repeat?})))
                        (match (or (cycle-through-match-groups
                                     ; Potential state change (highlight), but cleans up after itself.
                                     in2 positions-to-label shortcuts repeat?)
                                   (exit-with nil))
                          [group-offset in3]
                          (do (when (and dot-repeatable-op? (not dot-repeat?))
                                ; Reminder: above we have already set this to the character
                                ; of the first label, as a default. (We might had only one
                                ; match, and jumped automatically, not reaching this point.)
                                (set self.prev-dot-repeatable-search.in3
                                     ; If the operation spanned multiple groups, we are
                                     ; switching dot-repeat to <enter>-repeat (endnote #4).
                                     (if (= group-offset 0) in3 nil)))
                              (match (or (-?>> (. label-indexes in3)  ; Valid label...
                                               (+ (* group-offset (length labels)))
                                               (. positions-to-label))  ; ...currently in use?
                                         ; When "autojump" is on, fall through with any other key,
                                         ; so that we can continue editing right away.
                                         (exit-with (when jump-to-first? (vim.fn.feedkeys in3 :i))))
                                ; Succesful exit, option #4: selecting a valid label.
                                pos (jump-to! pos full-incl?))))))))))))))))

; }}}
; Mappings {{{

(local plug-mappings
   ; params of `s:to`: reverse? [dot-repeat?]
  [[:n "<Plug>Lightspeed_s" "s:to(false)"]
   [:n "<Plug>Lightspeed_S" "s:to(true)"] 
   [:x "<Plug>Lightspeed_s" "s:to(false)"]
   [:x "<Plug>Lightspeed_S" "s:to(true)"]
   [:o "<Plug>Lightspeed_s" "s:to(false)"]
   [:o "<Plug>Lightspeed_S" "s:to(true)"] 
   [:o "<Plug>Lightspeed_repeat_s" "s:to(false, true)"]
   [:o "<Plug>Lightspeed_repeat_S" "s:to(true, true)"]

   ; params of `ft:to`: reverse? t-like? [dot-repeat?]
   [:n "<Plug>Lightspeed_f" "ft:to(false, false)"]
   [:n "<Plug>Lightspeed_F" "ft:to(true, false)"]
   [:n "<Plug>Lightspeed_t" "ft:to(false, true)"]
   [:n "<Plug>Lightspeed_T" "ft:to(true, true)"]

   [:x "<Plug>Lightspeed_f" "ft:to(false, false)"]
   [:x "<Plug>Lightspeed_F" "ft:to(true, false)"]
   [:x "<Plug>Lightspeed_t" "ft:to(false, true)"]
   [:x "<Plug>Lightspeed_T" "ft:to(true, true)"]

   [:o "<Plug>Lightspeed_f" "ft:to(false, false)"]
   [:o "<Plug>Lightspeed_F" "ft:to(true, false)"]
   [:o "<Plug>Lightspeed_t" "ft:to(false, true)"]
   [:o "<Plug>Lightspeed_T" "ft:to(true, true)"]

   [:o "<Plug>Lightspeed_repeat_f" "ft:to(false, false, true)"]
   [:o "<Plug>Lightspeed_repeat_F" "ft:to(true, false, true)"]
   [:o "<Plug>Lightspeed_repeat_t" "ft:to(false, true, true)"]
   [:o "<Plug>Lightspeed_repeat_T" "ft:to(true, true, true)"]])

(each [_ [mode lhs rhs-call] (ipairs plug-mappings)]
  (api.nvim_set_keymap mode lhs (.. "<cmd>lua require'lightspeed'." rhs-call "<cr>")
                       {:noremap true :silent true}))


(fn add-default-mappings []
  (local default-mappings
    [[:n "s" "<Plug>Lightspeed_s"]
     [:n "S" "<Plug>Lightspeed_S"]
     [:x "s" "<Plug>Lightspeed_s"]
     [:x "S" "<Plug>Lightspeed_S"]
     [:o "z" "<Plug>Lightspeed_s"]
     [:o "Z" "<Plug>Lightspeed_S"]

     [:n "f" "<Plug>Lightspeed_f"]
     [:n "F" "<Plug>Lightspeed_F"]
     [:n "t" "<Plug>Lightspeed_t"]
     [:n "T" "<Plug>Lightspeed_T"]
     
     [:x "f" "<Plug>Lightspeed_f"]
     [:x "F" "<Plug>Lightspeed_F"]
     [:x "t" "<Plug>Lightspeed_t"]
     [:x "T" "<Plug>Lightspeed_T"]
     
     [:o "f" "<Plug>Lightspeed_f"]
     [:o "F" "<Plug>Lightspeed_F"]
     [:o "t" "<Plug>Lightspeed_t"]
     [:o "T" "<Plug>Lightspeed_T"]])

  (each [_ [mode lhs rhs] (ipairs default-mappings)]
    (when (and 
            ; User has not mapped (a keyseq starting with) `lhs` to something else.
            (= (vim.fn.mapcheck lhs mode) "")
            ; User has not already mapped something to the <Plug> key.
            (= (vim.fn.hasmapto rhs mode) 0))
      (api.nvim_set_keymap mode lhs rhs {:silent true}))))

(add-default-mappings)

; }}}
; Endnotes {{{

; (1) These should be saved right here, because the repeated search
;     might have a match anyway. 

; (2) <C-o> will unfortunately ignore this if the line has not changed.
;     https://github.com/neovim/neovim/issues/9874

; (3) For operator-pending mode, yet another push needed, to even out
;     that the motion is interpreted as exclusive.

; (4) It makes no practical sense to dot-repeat an operation spanning
;     multiple groups exactly as it went ("delete again till the 27th
;     match..."?). The most intuitive/logical behaviour is repeating as
;     <enter>-repeat in these cases, prompting for a target label again.

; }}}

{:opts opts
 :setup setup
 :init_highlight init-highlight
 :ft ft
 :s s
 :add_default_mappings add-default-mappings}

; vim:foldmethod=marker
