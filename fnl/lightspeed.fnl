; Imports & aliases ///1

(local api vim.api)
(local contains? vim.tbl_contains)
(local empty? vim.tbl_isempty)
(local map vim.tbl_map)
(local {: abs : ceil : max : min : pow} math)


; Fennel utils ///1

(macro ++ [x] `(set ,x (+ ,x 1)))

(macro one-of? [x ...]
  "Expands to an `or` form, like (or (= x y1) (= x y2) ...)"
  `(or ,(unpack
          (icollect [_ y (ipairs [...])]
            `(= ,x ,y)))))

(macro when-not [cond ...]
  `(when (not ,cond) ,...))

(fn inc [x] (+ x 1))
(fn dec [x] (- x 1))

(fn clamp [val min max]
  (if (< val min) min
      (> val max) max
      :else val))

(fn last [tbl] (. tbl (length tbl)))


; Nvim utils ///1

(fn echo [msg]
  (vim.cmd :redraw) (api.nvim_echo [[msg]] false []))

(fn replace-keycodes [s]
  (api.nvim_replace_termcodes s true false true))

(local <backspace> (replace-keycodes "<bs>"))
(local <ctrl-v> (replace-keycodes "<c-v>"))

(fn get-motion-force [mode]
  (match (when (mode:match :o) (mode:sub -1))
    last-ch (when (one-of? last-ch <ctrl-v> :V :v) last-ch)))

(fn operator-pending-mode? []
  (-> (api.nvim_get_mode) (. :mode) (string.match :o)))

(fn change-operation? []
  (and (operator-pending-mode?) (= vim.v.operator :c)))

(fn get-cursor-pos [] [(vim.fn.line ".") (vim.fn.col ".")])

(fn same-pos? [[l1 c1] [l2 c2]] (and (= l1 l2) (= c1 c2)))


(fn char-at-pos [[line byte-col] {: char-offset}]  ; expects (1,1)-indexed input
  "Get character at the given position in a multibyte-aware manner.
An optional offset argument can be given to get the nth-next screen
character instead."
  (let [line-str (vim.fn.getline line)
        char-idx (vim.fn.charidx line-str (dec byte-col))  ; charidx expects 0-indexed col
        char-nr (vim.fn.strgetchar line-str (+ char-idx (or char-offset 0)))]
    (when (not= char-nr -1)
      (vim.fn.nr2char char-nr))))


(fn get-fold-edge [lnum reverse?]
  (match ((if reverse? vim.fn.foldclosed vim.fn.foldclosedend) lnum)
    -1 nil
    fold-edge fold-edge))


(fn maparg-expr [name mode]
  "Like vim.fn.maparg, but returns the rhs of <expr> mappings evaluated."
  (let [rhs (vim.fn.maparg name mode)
        ; Note: We could use `maparg` with the `dict` arg, and check the `expr`
        ; field, but this works as well.
        (ok? eval-rhs) (pcall vim.fn.eval rhs)]
    (if (and ok? (= (type eval-rhs) :string)) eval-rhs rhs)))


; Glossary ///1

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


; Setup ///1

(var opts
     (do
       (local safe-labels
              ["s" "f" "n"
               "u" "t"
               "/" "F" "L" "N" "H" "G" "M" "U" "T" "?" "Z"])
       (local labels
              ["s" "f" "n"
               "j" "k" "l" "o" "d" "w" "e" "h" "m" "v" "g"
               "u" "t"
               "c" "." "z"
               "/" "F" "L" "N" "H" "G" "M" "U" "T" "?" "Z"])
       {:ignore_case false
        :exit_after_idle_msecs {:labeled nil :unlabeled 1000}
        ; s/x
        :jump_to_unique_chars {:safety_timeout 400}
        :match_only_the_start_of_same_char_seqs true
        :substitute_chars {"\r" "¬"}  ; 0x00AC
        :force_beacons_into_match_width false
        :safe_labels safe-labels
        :labels labels
        :special_keys {:next_match_group "<space>"
                       :prev_match_group "<tab>"}
        ; f/t
        :limit_ft_matches 4
        :repeat_ft_with_target_char false}))


(local removed-opts [:jump_to_first_match
                     :instant_repeat_fwd_key
                     :instant_repeat_bwd_key
                     :x_mode_prefix_key
                     :full_inclusive_prefix_key
                     :grey_out_search_area
                     :highlight_unique_chars
                     :jump_on_partial_input_safety_timeout
                     :cycle_group_fwd_key
                     :cycle_group_bwd_key])


(fn get-warning-msg [arg-fields]
  (let [msg [["ligthspeed.nvim\n" :Question]
             ["The following fields in the "] ["opts" :Visual]
             [" table has been renamed or removed:\n\n"]]

        field-names (icollect [_ field (ipairs arg-fields)]
                      [(.. "\t" field "\n")])

        msg-for-jump-to-first-match
        [["The plugin implements \"smart\" auto-jump now, that you can fine-tune via "]
         ["opts.labels" :Visual] [" and "] ["opts.safe_labels" :Visual] [". See "]
         [":h lightspeed-config" :Visual] [" for details."]]

        msg-for-instant-repeat-keys
        [["There are dedicated "] ["<Plug>" :Visual] [" keys available for native-like "]
         [";" :Visual] [" and "] ["," :Visual] [" functionality now, "]
         ["that can also be used for instant repeat only, if you prefer. See "]
         [":h lightspeed-custom-mappings" :Visual] ["."]]

        msg-for-x-prefix
        [["Use "] ["<Plug>Lightspeed_x" :Visual] [" and "] ["<Plug>Lightspeed_X" :Visual]
         [" instead."]]

        msg-for-grey-out
        [["This flag has been removed. To turn the 'greywash' feature off, "]
         ["just set all attributes of the corresponding highlight group to 'none': "]
         [":hi LightspeedGreywash guifg=none guibg=none ..." :Visual]]

        msg-for-hl-unique-chars
        [["Use "] ["jump_to_unique_chars" :Visual] [" instead. See "]
         [":h lightspeed-config" :Visual] [" for details."]]

        msg-for-cycle-keys
        [["Use the "] ["opts.special_keys" :Visual] [" table instead. See "]
         [":h lightspeed-config" :Visual] [" for details."]]

        spec-messages
        {:jump_to_first_match msg-for-jump-to-first-match
         :instant_repeat_fwd_key msg-for-instant-repeat-keys
         :instant_repeat_bwd_key msg-for-instant-repeat-keys
         :x_mode_prefix_key msg-for-x-prefix
         :full_inclusive_prefix_key msg-for-x-prefix
         :grey_out_search_area msg-for-grey-out
         :highlight_unique_chars msg-for-hl-unique-chars
         :jump_on_partial_input_safety_timeout msg-for-hl-unique-chars
         :cycle_group_fwd_key msg-for-cycle-keys
         :cycle_group_bwd_key msg-for-cycle-keys}]
    (each [_ field-name-chunk (ipairs field-names)]
      (table.insert msg field-name-chunk))
    (table.insert msg ["\n"])
    (each [field spec-msg (pairs spec-messages)]
      (when (contains? arg-fields field)
        (table.insert msg [(.. field "\n") :IncSearch])
        (each [_ chunk (ipairs spec-msg)]
          (table.insert msg chunk))
        (table.insert msg ["\n\n"])))
   msg))


; Prevent setting or accessing removed fields directly.
(let [guard (fn [t k]
              (when (contains? removed-opts k)
                (api.nvim_echo (get-warning-msg [k]) true {})))]
  (setmetatable opts {:__index guard
                      :__newindex guard}))


; Prevent setting removed fields via the `setup` function.
(fn normalize-opts [opts]
  (let [removed-arg-opts []]
    (each [k v (pairs opts)]
      (when (contains? removed-opts k)
        (table.insert removed-arg-opts k)
        (tset opts k nil)))
    (when-not (empty? removed-arg-opts)
      (api.nvim_echo (get-warning-msg removed-arg-opts) true {}))
    opts))


(fn setup [user-opts]
  (set opts (-> (normalize-opts user-opts)
                (setmetatable {:__index opts}))))


; Highlight ///1

(local hl
  {:group {:label                    "LightspeedLabel"
           :label-distant            "LightspeedLabelDistant"
           :shortcut                 "LightspeedShortcut"
           :masked-ch                "LightspeedMaskedChar"
           :unlabeled-match          "LightspeedUnlabeledMatch"
           :one-char-match           "LightspeedOneCharMatch"
           :unique-ch                "LightspeedUniqueChar"
           :pending-op-area          "LightspeedPendingOpArea"
           :greywash                 "LightspeedGreyWash"
           :cursor                   "LightspeedCursor"}
   :priority {:cursor 65535 :label 65534 :greywash 65533}
   :ns (api.nvim_create_namespace "")
   :cleanup (fn [self ?target-windows]
              (when ?target-windows
                (each [_ w (ipairs ?target-windows)]
                  (api.nvim_buf_clear_namespace w.bufnr self.ns (dec w.topline) w.botline)))
              ; We need to clean up the cursor highlight in the current window anyway.
              (api.nvim_buf_clear_namespace 0 self.ns
                                            (dec (vim.fn.line "w0"))
                                            (vim.fn.line "w$")))})


(fn init-highlight [force?]
  (local bg vim.o.background)
  (local groupdefs
    {hl.group.label                    {:guifg (match bg :light "#f02077" _ "#ff2f87")
                                        :ctermfg "Red"
                                        :guibg :NONE :ctermbg :NONE
                                        :gui "bold,underline"
                                        :cterm "bold,underline"}
     hl.group.label-distant            {:guifg (match bg :light "#399d9f" _ "#99ddff")
                                        :ctermfg (match bg :light "Blue" _ "Cyan")
                                        :guibg :NONE :ctermbg :NONE
                                        :gui "bold,underline"
                                        :cterm "bold,underline"}
     hl.group.shortcut                 {:guibg "#f00077" :ctermbg "Red"  ; ~inverse of label
                                        :guifg "#ffffff" :ctermfg "White"
                                        :gui "bold" :cterm "bold"}
     hl.group.masked-ch                {:guifg (match bg :light "#cc9999" _ "#b38080")
                                        :ctermfg "DarkGrey"
                                        :guibg :NONE :ctermbg :NONE
                                        :gui :NONE :cterm :NONE}
     hl.group.unlabeled-match          {:guifg (match bg :light "#272020" _ "#f3ecec")
                                        :ctermfg (match bg :light "Black" _ "White")
                                        :guibg :NONE :ctermbg :NONE
                                        :gui "bold"
                                        :cterm "bold"}
     hl.group.greywash                 {:guifg "#777777" :ctermfg "Grey"
                                        :guibg :NONE :ctermbg :NONE
                                        :gui :NONE :cterm :NONE}})
  ; Defining groups.
  (each [name hl-def-map (pairs groupdefs)]
    (let [attrs-str (-> (icollect [k v (pairs hl-def-map)] (.. k "=" v))
                        (table.concat " "))]
      ; "default" = do not override any existing definition for the group.
      (vim.cmd (.. "highlight " (if force? "" "default ") name " " attrs-str))))
  ; Setting linked groups.
  (each [from-group to-group
         (pairs {hl.group.unique-ch hl.group.unlabeled-match
                 hl.group.one-char-match hl.group.shortcut
                 hl.group.pending-op-area :IncSearch
                 hl.group.cursor :Cursor})]
    (vim.cmd (.. "highlight" (if force? "! " " default ")
                 "link " from-group " " to-group))))


(fn grey-out-search-area [reverse? ?target-windows omni?]
  (if (or ?target-windows omni?)
      (each [_ win (ipairs (or ?target-windows
                               [(. (vim.fn.getwininfo (vim.fn.win_getid)) 1)]))]
        (vim.highlight.range win.bufnr hl.ns hl.group.greywash
                             [(dec win.topline) 0] [(dec win.botline) -1]
                             {:priority hl.priority.greywash}))
      (let [[curline curcol] (map dec (get-cursor-pos))
            [win-top win-bot] [(dec (vim.fn.line "w0")) (dec (vim.fn.line "w$"))]
            [start finish] (if reverse?
                               [[win-top 0] [curline curcol]]
                               [[curline (inc curcol)] [win-bot -1]])]
        ; Expects 0,0-indexed args; `finish` is exclusive.
        (vim.highlight.range 0 hl.ns hl.group.greywash start finish
                             {:priority hl.priority.greywash}))))


(fn highlight-range [hl-group
                     [startline startcol &as start]
                     [endline endcol &as end]
                     {: motion-force : inclusive-motion?}]
  "A wrapper around `vim.highlight.range` that handles forced motion
types properly."
  (let [hl-range (fn [start end end-inclusive?]
                   (vim.highlight.range 0 hl.ns hl-group start end
                                        {:inclusive end-inclusive?
                                         :priority hl.priority.label}))]
    (match motion-force
      <ctrl-v> (let [[startcol endcol] [(min startcol endcol)
                                        (max startcol endcol)]]
                 (for [line startline endline]
                   ; Blockwise operations make the motion inclusive on
                   ; both ends, unconditionally.
                   (hl-range [line startcol] [line endcol] true)))
      :V (hl-range [startline 0] [endline -1])
      ; We are in OP mode, doing chairwise motion, so 'v' _flips_ its
      ; inclusive/exclusive behaviour (:h o_v).
      :v (hl-range start end (not inclusive-motion?))
      nil (hl-range start end inclusive-motion?))))


; Common ///1

(fn echo-no-prev-search [] (echo "no previous search"))

(fn echo-not-found [s] (echo (.. "not found: " s)))


(fn push-cursor! [direction]
  "Push cursor 1 character to the left or right, possibly beyond EOL."
  (vim.fn.search "\\_." (match direction :fwd "W" :bwd "bW")))


; Jump ///

(fn cursor-before-eof? []
  (and (= (vim.fn.line ".") (vim.fn.line "$"))
       (= (vim.fn.virtcol ".") (dec (vim.fn.virtcol "$")))))


(fn push-beyond-eof! []
  (local saved vim.o.virtualedit)
  (set vim.o.virtualedit :onemore)
  ; Note: No need to undo this afterwards, the cursor will be
  ; moved to the end of the operated area anyway.
  (vim.cmd "norm! l")
  (api.nvim_create_autocmd
    [:CursorMoved :WinLeave :BufLeave :InsertEnter :CmdlineEnter :CmdwinEnter]
    {:callback #(set vim.o.virtualedit saved)
     :once true}))


(fn simulate-inclusive-op! [mode]
  "When applied after an exclusive motion (like setting the cursor via
the API), make the motion appear to behave as an inclusive one."
  (match (vim.fn.matchstr mode "^no\\zs.")  ; get forcing modifier
    ; In the normal case (no modifier), we should push the cursor
    ; forward. (The EOF edge case requires some hackery though.)
    "" (if (cursor-before-eof?) (push-beyond-eof!) (push-cursor! :fwd))
    ; We also want the `v` modifier to behave in the native way, that
    ; is, to toggle between inclusive/exclusive if applied to a charwise
    ; motion (:h o_v). As `v` will change our (technically) exclusive
    ; motion to inclusive, we should push the cursor back to undo that.
    :v (push-cursor! :bwd)
    ; Blockwise (<c-v>) itself makes the motion inclusive, do nothing in
    ; that case.
    ))


(fn force-matchparen-refresh []
  ; HACK: :DoMatchParen turns matchparen on simply by triggering
  ; CursorMoved events (see matchparen.vim). We can do the same, which
  ; is cleaner for us than calling :DoMatchParen directly, since that
  ; would wrap this in a `windo`, and might visit another buffer,
  ; breaking our visual selection (and thus also dot-repeat,
  ; apparently). (See :h visual-start, and the discussion at #38.)
  ; Programming against the API would be more robust of course, but in
  ; the unlikely case that the implementation details would change, this
  ; still cannot do any damage on our side if called with pcall (the
  ; feature just ceases to work then).
  (pcall api.nvim_exec_autocmds "CursorMoved" {:group "matchparen"})
  ; If vim-matchup is installed, it can similarly be forced to refresh
  ; by triggering a CursorMoved event. (The same caveats apply.)
  (pcall api.nvim_exec_autocmds "CursorMoved" {:group "matchup_matchparen"}))


(fn jump-to!* [target {: mode : reverse? : inclusive-motion?
                       : add-to-jumplist? : adjust}]
  (local op-mode? (string.match mode :o))
  ; Note: <C-o> will ignore this if the line has not changed (neovim#9874).
  (when add-to-jumplist? (vim.cmd "norm! m`"))
  (vim.fn.cursor target)
  ; Adjust position after the jump (for t-mode or x-mode).
  (adjust)
  ; We should get this before the (possible) hacks below.
  (local adjusted-pos (get-cursor-pos))
  ; Since Vim interprets our jump as an exclusive motion (:h exclusive),
  ; we need custom tweaks to behave as an inclusive one. (This is only
  ; relevant in the forward direction, as inclusiveness applies to the
  ; end of the selection.)
  (when (and op-mode? inclusive-motion? (not reverse?))
    (simulate-inclusive-op! mode))
  (when-not op-mode? (force-matchparen-refresh))
  adjusted-pos)

; //> Jump


(fn highlight-cursor [?pos]
  "The cursor is down on the command line during `getchar`,
so we set a temporary highlight on it to see where we are."
  (let [[line col &as pos] (or ?pos (get-cursor-pos))
        ; nil means the cursor is on an empty line.
        ch-at-curpos (or (char-at-pos pos {}) " ")]  ; char-at-pos needs 1,1-idx
    ; (Ab)using extmarks even here, to be able to highlight the cursor on empty lines too.
    (api.nvim_buf_set_extmark 0 hl.ns (dec line) (dec col)
                              {:virt_text [[ch-at-curpos hl.group.cursor]]
                               :virt_text_pos "overlay"
                               :hl_mode "combine"
                               :priority hl.priority.cursor})))


(fn handle-interrupted-change-op! []
  "Return to Normal mode and restore the cursor position after an
interrupted change operation."
  (let [seq (.. "<C-\\><C-G>"  ; :h CTRL-\_CTRL-G
                (if (> (vim.fn.col ".") 1) "<RIGHT>" ""))]
    (api.nvim_feedkeys (replace-keycodes seq) :n true)))


(fn exec-user-autocmds [pattern]
  (api.nvim_exec_autocmds "User" {: pattern :modeline false}))


(fn enter [mode]
  (exec-user-autocmds :LightspeedEnter)
  (match mode
    :ft (exec-user-autocmds :LightspeedFtEnter)
    :sx (exec-user-autocmds :LightspeedSxEnter)))


; Note: One of the main purpose of these macros, besides wrapping cleanup stuff,
; is to enforce and encapsulate the requirement that tail-positioned "exit"
; forms in `match` blocks should always return nil. (Interop with side-effecting
; VimL functions can be dangerous, they might return 0 for example, like
; `feedkey`, and with that they can screw up Fennel match forms in a breeze,
; resulting in misterious bugs, so it's better to be paranoid.)
(macro exit-template [search-mode early-exit? ...]
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
     ,(match search-mode
        :ft `(exec-user-autocmds :LightspeedFtLeave)
        :sx `(exec-user-autocmds :LightspeedSxLeave))
     (exec-user-autocmds :LightspeedLeave)
     nil))


(fn get-input [?timeout]
  (let [char-available? #(not= "" (vim.fn.getcharstr true))
        getchar-timeout #(when (vim.wait ?timeout char-available? 100)
                           (vim.fn.getcharstr false))
        ; pcall for handling <C-c>.
        (ok? ch) (pcall (if ?timeout getchar-timeout vim.fn.getcharstr))]
    ; <esc> should cleanly exit anytime.
    (when (and ok? (not= ch (replace-keycodes "<esc>")))
      ch)))


(fn ignore-input-until-timeout [input-to-ignore timeout]
    (match (get-input timeout)
      input (when (not= input input-to-ignore)
              (vim.fn.feedkeys input :i))))


; repeat.vim support
; (see the docs in the script:
; https://github.com/tpope/vim-repeat/blob/master/autoload/repeat.vim)
(fn set-dot-repeat [cmd ?count]
  ; Note: dot-repeatable (i.e. non-yank) operation is assumed, we're not
  ; checking it here.
  (let [op vim.v.operator
        ; We cannot getreg('.') at this point, since the change has not
        ; happened yet - therefore the below hack (thx Sneak).
        change (when (= op :c) (replace-keycodes "<c-r>.<esc>"))
        seq (.. op (or ?count "") cmd (or change ""))]
    ; Using pcall, since vim-repeat might not be installed.
    ; Use the same register for the repeated operation.
    (pcall vim.fn.repeat#setreg seq vim.v.register)
    ; Note: we're feeding count inside the seq itself.
    (pcall vim.fn.repeat#set seq -1)))


(fn get-plug-key [search-mode reverse? x/t? repeat-invoc]
  (.. "<Plug>Lightspeed_"
      (match repeat-invoc :dot "dotrepeat_" _ "")
      ; Forcing to bools with not-not, as those values can be nils.
      (match [search-mode (not (not reverse?)) (not (not x/t?))]
        [:ft false false] "f"
        [:ft true  false] "F"
        [:ft false true ] "t"
        [:ft true  true ] "T"
        [:sx false false] "s"
        [:sx true  false] "S"
        [:sx false true ] "x"
        [:sx true  true ] "X")))


; TODO: Handle <a-?> keys, i.e., those with multibyte representation
; (`maparg` will not work with them, and we cannot convert `in` _to_
; a keycode(-sequence), so it's not trivial. Related: Vim #1810.)
(fn get-repeat-action [in search-mode x/t? instant-repeat?
                       from-reverse-cold-repeat? ?target-char]
  (let [mode (if (= (vim.fn.mode) :n) :n :x)  ; vim-cutlass compat (#28)
                                              ; (note: non-OP mode assumed)
        in-mapped-to (maparg-expr in mode)
        repeat-plug-key (.. "<Plug>Lightspeed_;_" search-mode)
        revert-plug-key (.. "<Plug>Lightspeed_,_" search-mode)]
    (if (or (= in <backspace>)
            (and (= search-mode :ft) opts.repeat_ft_with_target_char (= in ?target-char))
            (one-of? in-mapped-to
              (get-plug-key search-mode false x/t?)
              (if from-reverse-cold-repeat? revert-plug-key repeat-plug-key)))
        :repeat

        (and instant-repeat?
             (or (= in "\t")
                 (one-of? in-mapped-to
                   (get-plug-key search-mode true x/t?)
                   (if from-reverse-cold-repeat? repeat-plug-key revert-plug-key))))
        :revert)))


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
(local ft {:state {:dot {:in nil}  ; `reverse?` & `t-mode?` are hardcoded into
                                   ; the dot-repeat command
                   :cold {:in nil
                          :reverse? nil
                          :t-mode? nil}}})

(fn ft.go [self {: reverse? : t-mode? : repeat-invoc}]
  "Entry point for 1-character search."
  (let [mode (. (api.nvim_get_mode) :mode)  ; endnote #4
        op-mode? (mode:match :o)
        dot-repeatable-op? (and op-mode? (not= vim.v.operator :y))
        instant-repeat? (= (type repeat-invoc) :table)
        instant-state (when instant-repeat? repeat-invoc)
        reverted-instant-repeat? (?. instant-state :reverted?)
        cold-repeat? (= repeat-invoc :cold)
        dot-repeat? (= repeat-invoc :dot)
        invoked-as-reverse? reverse?
        ; The actual (absolute) search direction.
        reverse? (if cold-repeat? (#(if invoked-as-reverse? (not $) $)
                                    self.state.cold.reverse?)
                     reverse?)
        t-mode? (if cold-repeat? self.state.cold.t-mode? t-mode?)
        ; After a reverted repeat , we highlight the next n matches as always,
        ; as per `limit_ft_matches`, but _stay_ where we are. (We have already
        ; moved the cursor back to the previous position on the stack!)
        count (if reverted-instant-repeat? 0 vim.v.count1)
        ; In case of instant-repeating t/T (this includes reverting), we have to
        ; skip the first match, else we would find the same target in front of
        ; us again and again, and be stuck. (Instant-repeat implies that we are
        ; right before a target, so it's fine to simply increment `count` here.)
        count (if (and instant-repeat? t-mode?) (inc count) count)]

    (macro exit [...] `(exit-template :ft false ,...))
    (macro exit-early [...] `(exit-template :ft true ,...))

    (macro with-highlight-cleanup [...]
      `(let [res# (do ,...)]
         (api.nvim_buf_clear_namespace 0 hl.ns 0 -1)
         res#))

    (fn match-positions [pattern reverse? limit]
      (let [view (vim.fn.winsaveview)
            cleanup #(do (vim.fn.winrestview view) nil)]
        (var match-count 0)
        (fn []
          (if (and limit (>= match-count limit))
              (cleanup)
              (match (vim.fn.searchpos pattern (if reverse? "bW" "W"))
                [0 _] (cleanup)
                [line col &as pos] (do (++ match-count) pos))))))

    ; When instant-repeating, keep highlighting the same one group of matches,
    ; and do not shift until reaching the end of the group - it is less
    ; disorienting if the "snake" does not move continuously, on every repeat.
    (fn get-num-of-matches-to-be-highlighted []
      (match opts.limit_ft_matches
        (where group-limit (> group-limit 0))
        (let [matches-left-behind (or (-?> instant-state (. :stack) (length)) 0)
              ; Leaving behind a match = eating one from the highlighted group.
              ; [] | [2 3 4 ...]  ->  [1] | [3 4 ...]
              eaten-up (% matches-left-behind group-limit)
              remaining (- group-limit eaten-up)]
          ; Switch to next group if no remaining matches.
          (if (= remaining 0) group-limit remaining))

        _ 0))

    ;;;

    (when-not instant-repeat?
      (enter :ft))
    (when-not repeat-invoc
      (echo "")
      (highlight-cursor)
      (vim.cmd :redraw))

    (match (if instant-repeat? instant-state.in
               dot-repeat? self.state.dot.in
               cold-repeat? self.state.cold.in
               (match (or (with-highlight-cleanup (get-input))
                          (exit-early))
                 <backspace> (or self.state.cold.in
                                 (exit-early (echo-no-prev-search)))
                 in in))
      in1
      (do
        (local to-eol? (= in1 "\r"))
        (when-not repeat-invoc
          (set self.state.cold {:in in1 : reverse? : t-mode?}))  ; endnote #1
        (var jump-pos nil)
        (var match-count 0)
        (let [next-pos (vim.fn.searchpos "\\_." (if reverse? :nWb :nW))
              pattern (if to-eol? "\\n"
                          (.. "\\V" (if opts.ignore_case "\\c" "\\C")
                              (in1:gsub "\\" "\\\\")))
              limit (+ count (get-num-of-matches-to-be-highlighted))]
          (each [[line col &as pos] (match-positions pattern reverse? limit)]
            ; If we've started cold-repeating t/T from right before a match,
            ; then skip that match (endnote #2).
            (when-not (and (= match-count 0) cold-repeat? t-mode? (same-pos? pos next-pos))
              (if (<= match-count (dec count)) (set jump-pos pos)
                  (when-not op-mode?
                    (let [ch (or (char-at-pos pos {}) "\r")
                          ch (or (?. opts.substitute_chars ch) ch)]
                      (api.nvim_buf_set_extmark 0 hl.ns (dec line) (dec col)
                                                {:virt_text [[ch hl.group.one-char-match]]
                                                 :virt_text_pos "overlay"
                                                 :priority hl.priority.label}))))
              (++ match-count))))
        (if (and (not reverted-instant-repeat?)
                 (or (= match-count 0)
                     ; Just the character in front of us, but no more matches.
                     (and (= match-count 1) instant-repeat? t-mode?)))
            (exit-early (echo-not-found in1))
            (do
              (when-not reverted-instant-repeat?
                (jump-to!* jump-pos
                           {: mode : reverse?
                            :inclusive-motion? true  ; just like the native f/t
                            :add-to-jumplist? (not instant-repeat?)
                            :adjust #(when t-mode?
                                       (push-cursor! (if reverse? :fwd :bwd))
                                       (when (and to-eol? (not reverse?) (mode:match :n))
                                         (push-cursor! :fwd)))}))
              (if op-mode?
                  (exit (when dot-repeatable-op?
                          (set self.state.dot {:in in1})
                          (set-dot-repeat (replace-keycodes
                                            (get-plug-key :ft reverse? t-mode? :dot))
                                          count)))
                  (do
                    (highlight-cursor)
                    (vim.cmd :redraw)
                    (match (or (with-highlight-cleanup
                                 (get-input opts.exit_after_idle_msecs.unlabeled))
                               (exit))
                      in2
                      (let [stack (or (?. instant-state :stack) [])
                            ; Then we would want to continue (repeat) with the reverse key,
                            ; anc vice versa.
                            from-reverse-cold-repeat?
                            (if instant-repeat? instant-state.from-reverse-cold-repeat?
                                (and cold-repeat? invoked-as-reverse?))]
                        (match (get-repeat-action in2 :ft t-mode? instant-repeat?
                                                  from-reverse-cold-repeat? in1)
                          :repeat (do (table.insert stack (get-cursor-pos))
                                      (ft:go {: reverse? : t-mode?
                                              :repeat-invoc {:in in1 : stack :reverted? false
                                                             : from-reverse-cold-repeat?}}))
                          :revert (do (-?> (table.remove stack) (vim.fn.cursor))  ; jump!
                                      (ft:go {: reverse? : t-mode?
                                              :repeat-invoc {:in in1 : stack :reverted? true
                                                             : from-reverse-cold-repeat?}}))
                          _ (exit (vim.fn.feedkeys in2 :i)))))))))))))


; 2-character search ///1

; Helpers ///

(fn get-horizontal-bounds []
  (let [match-width 2
        textoff (. (vim.fn.getwininfo (vim.fn.win_getid)) 1 :textoff)
        offset-in-win (dec (vim.fn.wincol))
        offset-in-editable-win (- offset-in-win textoff)
        ; I.e., screen-column of the first visible column in the editable area.
        left-bound (- (vim.fn.virtcol ".") offset-in-editable-win)
        window-width (api.nvim_win_get_width 0)
        right-edge (+ left-bound (dec (- window-width textoff)))
        right-bound (- right-edge (dec match-width))]  ; the whole match should be visible
    [left-bound right-bound]))  ; screen columns


(fn onscreen-match-positions [pattern reverse? {: cross-window? : to-eol?}]
  "Returns an iterator streaming the return values of `searchpos` for
the given pattern, stopping at the window edge; in case of 2-character
search, folds and offscreen parts of non-wrapped lines are skipped too.
Caveat: side-effects take place here (cursor movement, &cpo), and the
clean-up happens only when the iterator is exhausted, so be careful with
early termination in loops."
  (let [view (vim.fn.winsaveview)
        cpo vim.o.cpo
        opts (if reverse? "b" "")
        wintop (vim.fn.line "w0")
        winbot (vim.fn.line "w$")
        stopline (if reverse? wintop winbot)
        cleanup #(do (vim.fn.winrestview view) (set vim.o.cpo cpo) nil)
        [left-bound right-bound] (get-horizontal-bounds)]

    ; HACK: vim.fn.cursor expects bytecol, but we want to put the cursor
    ; to `right-bound` as virtcol (screen col); so simply start crawling
    ; to the right, checking the virtcol... (When targeting the left
    ; bound, we might undershoot too - the virtcol of a position is
    ; always <= the bytecol of it -, but in that case it's no problem,
    ; just some unnecessary work afterwards, as we're still outside the
    ; on-screen area).
    (fn reach-right-bound []
      (while (and (< (vim.fn.virtcol ".") right-bound)
                  (not (>= (vim.fn.col ".") (dec (vim.fn.col "$")))))  ; reached EOL
        (vim.cmd "norm! l")))

    (fn skip-to-fold-edge! []
      (match ((if reverse? vim.fn.foldclosed vim.fn.foldclosedend)
              (vim.fn.line "."))
        -1 :not-in-fold
        fold-edge (do (vim.fn.cursor fold-edge 0)
                      (vim.fn.cursor 0 (if reverse? 1 (vim.fn.col "$")))
                      ; ...regardless of whether it _actually_ moved
                      :moved-the-cursor)))

    (fn skip-to-next-in-window-pos! []
      ; virtcol = like `col`, starting from the beginning of the line in the
      ; buffer, but every char counts as the #of screen columns it occupies
      ; (or would occupy), instead of the #of bytes.
      (local [line virtcol &as from-pos] [(vim.fn.line ".") (vim.fn.virtcol ".")])
      (match (if (< virtcol left-bound)
                 (if reverse?
                     (when (>= (dec line) stopline)
                       [(dec line) right-bound])
                     [line left-bound])

                 (> virtcol right-bound)
                 (if reverse?
                     [line right-bound]
                     (when (<= (inc line) stopline)
                       [(inc line) left-bound])))
        to-pos (when (not= from-pos to-pos)
                 (vim.fn.cursor to-pos)
                 (when reverse? (reach-right-bound))
                 :moved-the-cursor)))

    ; Do not skip overlapping matches.
    (set vim.o.cpo (cpo:gsub "c" ""))
    ; To be able to match the top-left or bottom-right corner (see below).
    (var win-enter? nil)
    (var match-count 0)

    (when cross-window?
      (set win-enter? true)
      (vim.fn.cursor (if reverse? [winbot right-bound] [wintop left-bound]))
      (when reverse? (reach-right-bound)))

    (fn recur [match-at-curpos?]
      (local match-at-curpos? (or match-at-curpos?
                                  (when win-enter? (set win-enter? false) true)))
      (if (and limit (>= match-count limit)) (cleanup)
          (match (vim.fn.searchpos
                   pattern (.. opts (if match-at-curpos? "c" "")) stopline)
            [0 _] (cleanup)
            [line col &as pos]
            (match (skip-to-fold-edge!)
              :moved-the-cursor (recur false)
              :not-in-fold
              (if (or vim.wo.wrap
                      (<= left-bound col right-bound)
                      to-eol?)  ; then we want the offscreen matches too
                (do (++ match-count) [line col left-bound right-bound])
                (match (skip-to-next-in-window-pos!)
                  ; Arg = true, as we might be _on_ a match.
                  :moved-the-cursor (recur true)
                  _ (cleanup)))))))))


(fn user-forced-autojump? []
  (or (not opts.labels) (empty? opts.labels)))


(fn user-forced-no-autojump? []
  (or (not opts.safe_labels) (empty? opts.safe_labels)))


(fn get-targetable-windows [reverse? omni?]
  (let [curr-win-id (vim.fn.win_getid)
        ; HACK!! The output of vim.fn.winlayout looks sg like:
        ; ['col', [['leaf', 1002], ['row', [['leaf', 1003], ['leaf', 1001]]], ['leaf', 1000]]]
        ; Instead of doing an in-order traversal of the window tree ourselves,
        ; we simply split this _string_ on the current window id, and extract
        ; the rest of the id-s, depending on the search direction.
        [left right] (-> (vim.fn.string (vim.fn.winlayout))
                         (vim.split (tostring curr-win-id)))
        ids (string.gmatch (if omni? (.. left right)
                               reverse? left
                               right)
                           "%d+")
        ; TODO: filter on certain window types?
        visual-or-OP-mode? (not= (vim.fn.mode) :n)
        buf api.nvim_win_get_buf
        ids (icollect [id ids]
              (when-not (and visual-or-OP-mode?
                             (not= (buf id) (buf curr-win-id)))
                id))
        ids (if reverse? (vim.fn.reverse ids) ids)]
    (map #(. (vim.fn.getwininfo $) 1) ids)))


(fn get-onscreen-lines [{: get-full-window? : reverse? : skip-folds?}]
  (let [lines {}  ; {lnum : line-str}
        wintop (vim.fn.line "w0")
        winbot (vim.fn.line "w$")]
    (var lnum (if get-full-window? (if reverse? winbot wintop)
                  (vim.fn.line ".")))
    (while (if reverse? (>= lnum wintop) (<= lnum winbot))
      (local fold-edge (get-fold-edge lnum reverse?))
      (if (and skip-folds? fold-edge)
          (set lnum ((if reverse? dec inc) fold-edge))
          (do (tset lines lnum (vim.fn.getline lnum))
              (set lnum ((if reverse? dec inc) lnum)))))
    lines))


; TODO: multibyte issues?
(fn get-unique-chars [reverse? ?target-windows omni?]
  (let [unique-chars {}  ; {key-ch : [lnum col wininfo ch-on-screen]}
        curr-w (. (vim.fn.getwininfo (vim.fn.win_getid)) 1)
        [curline curcol] (get-cursor-pos)]
    (each [_ w (ipairs (or ?target-windows [curr-w]))]
      (when ?target-windows
        (api.nvim_set_current_win w.winid))
      (let [[left-bound right-bound] (get-horizontal-bounds {:match-width 2})
            lines (get-onscreen-lines {:get-full-window? (or ?target-windows omni?)
                                       : reverse? :skip-folds? true})]
        (each [lnum line (pairs lines)]
          (let [startcol (if (and (= lnum curline) (not reverse?)
                                  (not ?target-windows))
                             (inc curcol)
                             1)
                endcol (if (and (= lnum curline) reverse?
                                (not ?target-windows))
                           (dec curcol)
                           (length line))]
            (for [col startcol endcol]
              (when (or vim.wo.wrap (and (>= col left-bound) (<= col right-bound)))
                (let [orig-ch (line:sub col col)
                      ch (if opts.ignore_case (orig-ch:lower) orig-ch)]
                  (tset unique-chars ch (match (. unique-chars ch)
                                          nil [lnum col w orig-ch]
                                          _ false)))))))))
    (when ?target-windows
      (api.nvim_set_current_win curr-w.winid))
    (icollect [k v (pairs unique-chars)]
      (match v
        ; A subset of the target interface (see `get-targets*`), enough
        ; for `light-up-beacons`.
        [lnum col w orig-ch] {:pos [lnum col]
                              :wininfo w
                              :beacon [0 [[orig-ch hl.group.unique-ch]]]}))))


(fn get-targets* [input reverse? ?wininfo ?targets]
  "Return a table that will store the positions and other metadata of
all on-screen pairs that start with `input`, in the order of discovery
(i.e., distance from cursor).

A target element in its final form has the following fields (the latter
ones might be set by subsequent functions):

   pos         : [line col]
   pair        : [char char]
  ?wininfo     : `vim.fn.getwininfo` dict
  ?squeezed?   : bool
  ?overlapped? : bool
  ?label       : char
  ?label-state : 'active-primary' | 'active-secondary' | 'inactive'
  ?beacon      : [col-offset [[char hl-group]]]
"
  (local targets (or ?targets []))
  (local to-eol? (= input "\r"))
  (local winid (vim.fn.win_getid))
  (var prev-match {})
  (var added-prev-match? nil)
  (let [pattern (if to-eol? "\\n"  ; we should send in a literal \n, for searchpos
                    (.. "\\V"
                        (if opts.ignore_case "\\c" "\\C")
                        (input:gsub "\\" "\\\\")  ; backslash still needs to be escaped for \V
                        "\\_."))]                 ; match anything (including EOL) after it
    (each [[line col &as pos] (onscreen-match-positions pattern reverse?
                                                        {: to-eol?
                                                         :cross-window? ?wininfo})]
      (local target {: pos :wininfo ?wininfo})
      (if to-eol? (do (tset target :pair ["\n" ""])
                      (table.insert targets target))
          (let [ch1 (char-at-pos pos {})  ; not necessarily = `input` (if case-insensitive)
                ch2 (or (char-at-pos pos {:char-offset 1})
                        ; <enter> is the expected input for line breaks, so
                        ; let's return the key for the sublist right away.
                        "\r")
                to-pre-eol? (= ch2 "\r")
                overlaps-prev-match? (and (= line prev-match.line)
                                          (= col ((if reverse? dec inc) prev-match.col)))
                same-char-triplet? (and overlaps-prev-match? (= ch2 prev-match.ch2))
                overlaps-prev-target? (and overlaps-prev-match? added-prev-match?)]
            (set prev-match {: line : col : ch2})
            (if (and same-char-triplet?
                     (or added-prev-match?  ; the 2nd 'xx' in 'xxx' is _always_ skipped
                         opts.match_only_the_start_of_same_char_seqs))
                (set added-prev-match? false)
                (let [_ (tset target :pair [ch1 ch2])
                      prev-target (last targets)
                      ; Experience shows that a beacon "touching" an
                      ; unhighlighted match can confuse the eye...
                      ; [a][b][label1][d][e][label2]
                      ; ...so it's better to be avoided, whenever possible.
                      ; A 4-column delta as a condition forces a gap between the
                      ; beacon and the next one, when the former is not
                      ; "squeezed" back into its 2-column box, i.e., when the
                      ; label is displayed over position 'c':
                      ; [a][b][label1][_][e][f][label2]
                      min-delta-to-prevent-squeezing 4
                      close-to-prev-target?
                      (match prev-target
                        {:pos [prev-line prev-col]}
                        (and (= line prev-line)
                             (let [col-delta (if reverse?
                                                 (- prev-col col)
                                                 (- col prev-col))]
                               (< col-delta min-delta-to-prevent-squeezing))))]
                  (when to-pre-eol? (tset target :squeezed? true))
                  (when close-to-prev-target?
                    (tset (if reverse? target prev-target) :squeezed? true))
                  (when overlaps-prev-target?
                    ; Just the opposite: the _label_ should remain visible
                    ; in any case.
                    (tset (if reverse? prev-target target) :overlapped? true))
                  (table.insert targets target)
                  (set added-prev-match? true))))))
    (when (next targets) targets)))


(fn distance [[line1 col1] [line2 col2] vertical-only?]
  (let [editor-grid-aspect-ratio 0.3  ; arbitrary (make it configurable? get it programmatically?)
        [dx dy] [(abs (- col1 col2)) (abs (- line1 line2))]
         dx (* dx editor-grid-aspect-ratio (if vertical-only? 0 1))]
    (pow (+ (pow dx 2) (pow dy 2)) 0.5)))


; TODO: DRY!
; I've had no mental energy to refactor this yet.
(fn get-targets [input reverse? ?target-windows omni?]
  (local to-eol? (= input "\r"))
  ; TODO: performance: vim.fn.screenpos is very costly for a large number of targets
  ; - only get them when at least one line is actually wrapped?
  ; - some FFI magic?
  (fn calculate-screen-positions? [targets]
    (and vim.wo.wrap (< (length targets) 200)))

  (if ?target-windows
      (let [curr-w (. (vim.fn.getwininfo (vim.fn.win_getid)) 1)
            cursor-positions {}
            targets []]
        (each [_ w (ipairs ?target-windows)]
          (api.nvim_set_current_win w.winid)
          (tset cursor-positions w.winid (get-cursor-pos))
          (get-targets* input reverse? w targets))
        (api.nvim_set_current_win curr-w.winid)
        (when (next targets)
          (when omni?  ; sort targets by screen distance
            (let [calculate-screen-positions? (calculate-screen-positions? targets)]
              (when calculate-screen-positions?
                (each [winid [line col] (pairs cursor-positions)]
                  (let [screenpos (vim.fn.screenpos winid line col)]
                    (tset cursor-positions winid [screenpos.row screenpos.col]))))
              (each [_ {:pos [line col] :wininfo {: winid} &as t} (ipairs targets)]
                (when calculate-screen-positions?
                  (let [screenpos (vim.fn.screenpos winid line col)]  ; perf. bottleneck
                    (tset t :screenpos [screenpos.row screenpos.col])))
                (let [cursor-pos (. cursor-positions winid)
                      pos (or t.screenpos t.pos)]
                  (tset t :rank (distance pos cursor-pos to-eol?))))
              (table.sort targets #(< (. $1 :rank) (. $2 :rank)))))
          targets))
    
      omni?
      (match (->> (get-targets* input false)      ; fwd targets
                  (get-targets* input true nil))  ; fwd + bwd targets
        targets
        (let [winid (vim.fn.win_getid)
              calculate-screen-positions? (calculate-screen-positions? targets)
              ; screenrow() & screencol() would return the _current_ position of
              ; the cursor (on the command line).
              [curline curcol &as curpos] (get-cursor-pos)
              curscreenpos (vim.fn.screenpos winid curline curcol)
              cursor-pos (if calculate-screen-positions?
                             [curscreenpos.row curscreenpos.col]
                             curpos)]
          (each [_ {:pos [line col] &as t} (ipairs targets)]
            (when calculate-screen-positions?
              (let [screenpos (vim.fn.screenpos winid line col)]
                (tset t :screenpos [screenpos.row screenpos.col])))
            (let [pos (or t.screenpos t.pos)]
              (tset t :rank (distance pos cursor-pos to-eol?))))
          (table.sort targets #(< (. $1 :rank) (. $2 :rank)))
          targets))
    
      (get-targets* input reverse?)))


(fn populate-sublists [targets]
  "Populate a sub-table in `targets` containing lists that allow for
easy iteration through each subset of targets with a given successor
char separately."
  (tset targets :sublists {})
  (when opts.ignore_case
    (setmetatable targets.sublists
                  {:__index (fn [self k]
                              (rawget self (k:lower)))
                   :__newindex (fn [self k v]
                                 (rawset self (k:lower) v))}))
  (each [_ {:pair [_ ch2] &as target} (ipairs targets)]
    (when-not (. targets :sublists ch2)
      (tset targets :sublists ch2 []))
    (table.insert (. targets :sublists ch2) target)))


(fn set-autojump [sublist to-eol?]
  "Set a flag indicating whether we should autojump to the first target
if selecting `sublist` with the 2nd input character.
Note that there is no one-to-one correspondence between this flag and
the `label-set` field set by `attach-label-set`. No-autojump might be
forced implicitly, regardless of using safe labels."
  (tset sublist :autojump?
        ; In operator-pending mode we never want to autojump, since that
        ; would execute the operation without allowing us to select a
        ; labeled target.
        (and (not (or (user-forced-no-autojump?)
                      to-eol?
                      (operator-pending-mode?)))
             (or (user-forced-autojump?)
                 (>= (length opts.safe_labels)
                     (dec (length sublist)))))))  ; skipping the first if autojumping


(fn attach-label-set [sublist]
  "Set a field referencing the target label set to be used for
`sublist`. `set-autojump` should be called before this function."
  (tset sublist :label-set
        (if (user-forced-autojump?) opts.safe_labels
            (user-forced-no-autojump?) opts.labels
            sublist.autojump? opts.safe_labels
            opts.labels)))


(fn set-sublist-attributes [targets to-eol?]
  (each [_ sublist (pairs targets.sublists)]
    (set-autojump sublist to-eol?)
    (attach-label-set sublist)))


(fn set-labels [targets to-eol?]
  "Assign label characters to each target, by going through the sublists
one by one, using the given sublist's `label-set` repeated indefinitely,
and skipping the first target if `autojump?` is set.
Note: `label` is a once and for all fixed attribute - whether and how it
should actually be displayed depends on the `label-state` flag."
  (each [_ sublist (pairs targets.sublists)]
    (when (> (length sublist) 1)  ; else we'll jump automatically anyway
      ; Note: We could also get `to-eol?` by checking the sublist key (ch2).
      (let [autojump? sublist.autojump?
            labels sublist.label-set]
        (each [i target (ipairs sublist)]
          (tset target :label
                (when-not (and autojump? (= i 1))
                  ; In case of `autojump?`, the i-th label is assigned
                  ; to the i+1th position (we skipped the first one).
                  (match (% (if autojump? (dec i) i) (length labels))
                    ; 1-indexing is not a great match for modulo arithmetic.
                    0 (last labels)
                    n (. labels n)))))))))


(fn set-label-states [sublist {: group-offset}]
  (let [labels sublist.label-set
        |labels| (length labels)
        offset (* group-offset |labels|)
        primary-start (+ offset (if sublist.autojump? 2 1))
        primary-end (+ primary-start (dec |labels|))
        secondary-end (+ primary-end |labels|)]
    (each [i target (ipairs sublist)]
      (when target.label
        (tset target :label-state
              (if (or (< i primary-start) (> i secondary-end)) :inactive
                  (<= i primary-end) :active-primary
                  :active-secondary))))))


(fn set-initial-label-states [targets]
  (each [_ sublist (pairs targets.sublists)]
    (set-label-states sublist {:group-offset 0})))


(fn set-shortcuts-and-populate-shortcuts-map [targets]
  "Set the `shortcut?` attribute of those targets where the label can be
used right after the first input (see Glossary), while populating a
sub-table containing label-target key-value pairs for these targets."
  (tset targets :shortcuts {})
  (let [potential-2nd-inputs (collect [ch2 _ (pairs targets.sublists)]
                               (values ch2 true))
        labels-used-up-as-shortcut {}]
    (each [_ {: label : label-state &as target} (ipairs targets)]
      ; Shortcutting only makes sense for the first match group,
      ; we're ignoring the distant one(s).
      (when (= label-state :active-primary)
        (when-not (or (. potential-2nd-inputs label)
                      (. labels-used-up-as-shortcut label))
          (tset target :shortcut? true)
          (tset targets.shortcuts label target)
          (tset labels-used-up-as-shortcut label true))))))


; The first principle of Lightspeed's interface is that after a beacon appears
; on screen, it should not change in appearance unless strictly necessary. That
; is because the brain has to be given as much time as possible to familiarize
; itself with the beacon, and any sudden change would only be confusing and
; ultimately counterproductive.
; Therefore, labels will not change into "shortcuts" after the second input,
; even though, in a way, it would be logical. If a label was part of an
; overlapped beacon, it will not get transformed back into a regular label when
; the first column gets uncovered. For the same reason, the masked characters
; will not disappear before the labels in the second round. The look of a beacon
; only changes with group switching, when its active/passive or
; primary/secondary state changes.
(fn set-beacon [{:pos [_ col left-bound right-bound] :pair [ch1 ch2]
                 : label : label-state : squeezed? : overlapped? : shortcut?
                 &as target}
                repeat]
  (let [to-eol? (and (= ch1 "\n") (= ch2 ""))
        ch1 (if to-eol? "\r" ch1)  ; to trigger substitute_chars
        [ch1 ch2] (map #(or (?. opts.substitute_chars $) $) [ch1 ch2])
        squeezed? (or opts.force_beacons_into_match_width squeezed?)
        onscreen? (or vim.wo.wrap (and (<= col right-bound) (>= col left-bound)))
        left-off? (< col left-bound)
        right-off? (> col right-bound)
        hg hl.group
        masked-char$ [ch2 hg.masked-ch]
        label$ [label hg.label]
        shortcut$ [label hg.shortcut]
        distant-label$ [label hg.label-distant]]
    ; The `beacon` field looks like: [col-offset [[char hl-group]]]
    (set target.beacon
         (if
           (= repeat :instant-unsafe) [0 [[(.. ch1 ch2) hg.one-char-match]]]
           (match label-state
             ; Note: there should be no unlabeled matches when repeating, as we
             ; have the full input sequence available then, and we will have
             ; jumped to the first match already, if it was on the "winning"
             ; sublist.
             nil  ; match w/o label-state = unlabeled
             (when-not (or repeat to-eol?)
               (if overlapped?
                   [1 [[ch2 hg.unlabeled-match]]]
                   [0 [[(.. ch1 ch2) hg.unlabeled-match]]]))

             ; Note: `repeat` is also mutually exclusive with both
             ; `overlapped?` and `shortcut?`.
             :active-primary
             (if to-eol? (if onscreen? [0 [shortcut$]]
                             left-off? [0 [["<" hg.one-char-match] shortcut$]
                                        :left-off]
                             right-off? [(dec (- right-bound col))
                                         [shortcut$ [">" hg.one-char-match]]])
                 repeat [(if squeezed? 1 2) [shortcut$]]
                 shortcut? (if squeezed?
                               [0 [masked-char$ shortcut$]]
                               [(if overlapped? 1 2) [shortcut$]])
                 squeezed? [0 [masked-char$ label$]]
                 [(if overlapped? 1 2) [label$]])

             ; TODO: New hl group (~ no-underline distant label).
             :active-secondary
             (if to-eol? (if onscreen? [0 [distant-label$]]
                             left-off? [0 [["<" hg.unlabeled-match] distant-label$]
                                        :left-off]
                             right-off? [(dec (- right-bound col))
                                         [distant-label$ [">" hg.unlabeled-match]]])
                 repeat [(if squeezed? 1 2) [distant-label$]]
                 squeezed? [0 [masked-char$ distant-label$]]
                 [(if overlapped? 1 2) [distant-label$]])

             :inactive nil)))))


(fn set-beacons [target-list {: repeat}]
  (each [_ target (ipairs target-list)]
    (set-beacon target repeat)))


(fn light-up-beacons [target-list ?start-idx]
  (for [i (or ?start-idx 1) (length target-list)]
    (let [{:pos [line col] &as target} (. target-list i)]
      (match target.beacon  ; might be nil, if the state is inactive
        [offset chunks ?left-off?]
        (api.nvim_buf_set_extmark (or (?. target.wininfo :bufnr) 0) hl.ns
                                  (dec line) (dec (+ col offset))
                                  {:virt_text chunks
                                   :virt_text_pos "overlay"
                                   :virt_text_win_col (when ?left-off? 0)
                                   :priority hl.priority.label})))))


(fn get-target-with-active-primary-label [target-list input]
  (var res nil)
  (each [_ {: label : label-state &as target} (ipairs target-list)
         :until res]
    (when (and (= label input) (= label-state :active-primary))
      (set res target)))
  res)

; //> Helpers

; State for 2-character search that is persisted between invocations.
; (Note: we don't need `reverse?` and `x-mode?` for the dot state, since we
; hardcode them into the dot-repeat command.)
(local sx {:state {:dot {:in1 nil
                         :in2 nil
                         :in3 nil}
                   :cold {:in1 nil
                          :in2 nil
                          :reverse? nil
                          :x-mode? nil}}})

(fn sx.go [self {: reverse? : x-mode? : repeat-invoc : cross-window? : omni?}]
  "Entry point for 2-character search."
  (let [mode (. (api.nvim_get_mode) :mode)  ; endnote #4
        linewise? (= (mode:sub -1) :V)
        op-mode? (mode:match :o)
        change-op? (and op-mode? (= vim.v.operator :c))
        delete-op? (and op-mode? (= vim.v.operator :d))
        dot-repeatable-op? (and op-mode? (not omni?) (not= vim.v.operator :y))
        ; TODO: DRY
        instant-repeat? (= (type repeat-invoc) :table)
        instant-state (when instant-repeat? repeat-invoc)
        cold-repeat? (= repeat-invoc :cold)
        dot-repeat? (= repeat-invoc :dot)
        invoked-as-reverse? reverse?
        reverse? (if cold-repeat? (#(if invoked-as-reverse? (not $) $)
                                    self.state.cold.reverse?)
                     reverse?)
        x-mode? (if cold-repeat? self.state.cold.x-mode? x-mode?)
        ?target-windows (or (when cross-window?
                              (get-targetable-windows reverse? omni?))
                            (when instant-repeat? instant-state.target-windows))
        spec-keys (setmetatable {} {:__index
                                    (fn [_ k] (replace-keycodes
                                                (. opts.special_keys k)))})]

    ; Top-level vars

    (var new-search? (not repeat-invoc))
    (var backspace-repeat? nil)
    (var to-eol? nil)
    (var to-pre-eol? nil)

    ; Helpers ///

    (macro exit [...]
      `(exit-template :sx false
                      (do
                        (when dot-repeatable-op?
                          (set-dot-repeat
                            (replace-keycodes
                              (get-plug-key :sx reverse? x-mode? :dot))))
                        ,...)))

    (macro exit-early [...] `(exit-template :sx true ,...))

    (macro with-highlight-chores [...]
      `(do (when-not (or cold-repeat? instant-repeat?)
             (grey-out-search-area reverse? ?target-windows omni?))
           (do ,...)
           (highlight-cursor)
           (vim.cmd :redraw)))

    ; TODO: DRY
    (macro with-highlight-cleanup [...]
      `(let [res# (do ,...)]
         (hl:cleanup ?target-windows)
         res#))

    (fn get-first-input []
      (if instant-repeat? instant-state.in1
          dot-repeat? self.state.dot.in1
          cold-repeat? self.state.cold.in1
          (match (or (with-highlight-cleanup (get-input))
                     (exit-early))
            ; Here we can handle any other modifier key as "zeroth" input,
            ; if the need arises (e.g. regex search).
            (where "\t" (not omni?))
            (do (sx:go {:reverse? (not reverse?) : x-mode? : cross-window?}) nil)

            <backspace> (do (set backspace-repeat? true)
                            (set new-search? false)
                            (or self.state.cold.in1
                                (exit-early (echo-no-prev-search))))
            in in)))

    ; No need to pass in `in1` every time once we have it, so let's curry this.
    (fn update-state* [in1]
      (fn [{: cold : dot}]
        (when new-search?  ; not dot-repeat? / cold-repeat? / backspace-repeat?
          (when cold
            (set self.state.cold (doto cold
                                   (tset :in1 in1)
                                   (tset :x-mode? x-mode?)
                                   (tset :reverse? reverse?))))
          (when dot
            (when dot-repeatable-op?
              (set self.state.dot (doto dot
                                    (tset :in1 in1)
                                    (tset :x-mode? x-mode?))))))))

    ; `first-jump?` should only be persisted inside `to` (i.e. the
    ; lifetime is one invocation), and better be managed by the function
    ; itself, so setting up a closure here.
    (local jump-to!
           (do (var first-jump? true)
               (fn [target ?to-pre-eol? ?save-winview?]
                 (when target.wininfo
                   (api.nvim_set_current_win target.wininfo.winid)
                   ; If we move on to another window, we'll have to restore
                   ; the cursor etc. in the one we have just visited briefly.
                   (when ?save-winview?
                     (tset target :winview (vim.fn.winsaveview))))
                 (let [to-pre-eol? (or ?to-pre-eol? to-pre-eol?)
                       adjusted-pos
                       (jump-to!* target.pos
                                  {: mode : reverse?
                                   :inclusive-motion? (and x-mode? (not reverse?))
                                   :add-to-jumplist? (and first-jump?
                                                          (not instant-repeat?))
                                   :adjust #(if to-eol?
                                                (when op-mode? (push-cursor! :fwd))

                                                to-pre-eol?
                                                (when (and op-mode? x-mode?)
                                                  (push-cursor! :fwd))

                                                x-mode?
                                                (do (push-cursor! :fwd)
                                                    (when reverse?
                                                      (push-cursor! :fwd))))})]
                  (set first-jump? false)
                  adjusted-pos))))

    ; Jumping based on partial input is nice, but it's annoying that we
    ; don't see the actual changes right away (we are staying in the main
    ; function, waiting for another input, so that we can introduce a safety
    ; timespan to ignore the character in the next column). Therefore we need
    ; to provide visual feedback, to tell the user that the target has been
    ; found, and they can continue editing.
    (fn highlight-new-curpos-and-op-area [from-pos to-pos]  ; 1,1
      (let [motion-force (get-motion-force mode)
            blockwise? (= motion-force <ctrl-v>)
            ; Preliminary boundaries of the highlighted - operated - area
            ; (motion-force might affect these).
            [startline startcol &as start] (if reverse? to-pos from-pos)
            [_ endcol &as end] (if reverse? from-pos to-pos)
            top-left [startline (min startcol endcol)]
            ; In OP-mode, the cursor always ends up at the beginning of the
            ; operated area, that might differ from the targeted position!
            ; (Caveat: linewise works as if there would be no forcing modifier.)
            new-curpos (if op-mode? (if blockwise? top-left start) to-pos)]
        (when-not change-op?  ; then we're entering insert mode anyway (couldn't move away)
          (highlight-cursor new-curpos))
        (when op-mode?
          (highlight-range hl.group.pending-op-area
                           (map dec start)
                           (map dec end)
                           {: motion-force
                            :inclusive-motion? (and x-mode? (not reverse?))}))
        (vim.cmd :redraw)))

    (fn get-sublist [targets ch]
      (match (. targets.sublists ch)  ; note: if not nil, a sublist is never []
        sublist
        ; Handling cold-repeating backward x-motion. (The same problem as with
        ; instant-repeating t/T - we might have to skip the first target. In
        ; case of x, this is irrelevant in the forward direction, since in
        ; OP-mode - when we would land right before the target - we always have
        ; to choose a label.)
        (let [[{:pos [line col]} & rest] sublist
              target-tail [line (inc col)]
              prev-pos (vim.fn.searchpos "\\_." :nWb)
              cursor-touches-first-target? (same-pos? target-tail prev-pos)]
          (if (and cold-repeat? x-mode? reverse? cursor-touches-first-target?)
              (when-not (empty? rest) rest)
              sublist))))

    (fn get-last-input [sublist start-idx]
      (fn recur [group-offset initial-invoc?]
        (set-beacons sublist
                     {:repeat (if (or cold-repeat? backspace-repeat?) :cold
                                  instant-repeat? (if sublist.autojump? :instant
                                                      :instant-unsafe))})
        (with-highlight-chores
          (light-up-beacons sublist start-idx))
        (match (with-highlight-cleanup
                 (get-input (when initial-invoc?
                              opts.exit_after_idle_msecs.labeled)))
          input
          (if (and sublist.autojump? (not (user-forced-autojump?)))
              ; If auto-jump has been set heuristically (not forced), it
              ; implies that there are no subsequent groups.
              [input 0]

              (and (one-of? input
                     spec-keys.next_match_group
                     spec-keys.prev_match_group)
                   (not instant-repeat?))
              (let [labels sublist.label-set
                    num-of-groups (ceil (/ (length sublist) (length labels)))
                    max-offset (dec num-of-groups)
                    group-offset* (-> group-offset
                                      ((match input
                                         spec-keys.next_match_group inc
                                         _ dec))
                                      (clamp 0 max-offset))]
                (set-label-states sublist {:group-offset group-offset*})
                (recur group-offset*))

              [input group-offset])))
      (recur 0 true))

    ; TODO: Handle instant-repeat sequences too.
    (fn restore-view-on-winleave [curr-target next-target]
      (when (and (not instant-repeat?)
                 (not= (?. curr-target :wininfo :winid)
                       (?. next-target :wininfo :winid)))
        (when curr-target.winview
          (vim.fn.winrestview curr-target.winview))))

    ; //> Helpers

    ; After all the stage-setting, here comes the main action you've all been
    ; waiting for:

    (when-not instant-repeat?
      (enter :sx))
    (when-not repeat-invoc
      (echo "")  ; clean up the command line
      (with-highlight-chores
        (when opts.jump_to_unique_chars
          (-> (get-unique-chars reverse? ?target-windows omni?)
              (light-up-beacons)))))

    (match (get-first-input)
      in1
      (let [_ (set to-eol? (= in1 "\r"))
            from-pos (get-cursor-pos)
            update-state (update-state* in1)
            prev-in2 (if instant-repeat? instant-state.in2
                         (or cold-repeat? backspace-repeat?) self.state.cold.in2
                         dot-repeat? self.state.dot.in2)]
        (match (or (?. instant-state :sublist)
                   (get-targets in1 reverse? ?target-windows omni?)
                   (exit-early (echo-not-found (.. in1 (or prev-in2 "")))))
          (where [{:pair [_ ch2] &as only} nil]
                 opts.jump_to_unique_chars)
          (if (or new-search? (= ch2 prev-in2))
              (exit (update-state  ; endnote #5
                      {:cold {:in2 ch2} :dot {:in2 ch2 :in3 (. opts.labels 1)}})
                    (local to-pos (jump-to! only (= ch2 "\r")))
                    (when new-search?  ; i.e. user is actually typing the pattern
                      (with-highlight-cleanup
                        (highlight-new-curpos-and-op-area from-pos to-pos)
                        (match opts.jump_to_unique_chars
                          {:safety_timeout timeout}
                          (ignore-input-until-timeout ch2 timeout)))))
              (exit-early (echo-not-found (.. in1 prev-in2))))

          targets
          (do
            (when-not instant-repeat?
              (doto targets
                (populate-sublists)
                (set-sublist-attributes to-eol?)  ; autojump + label set used
                (set-labels to-eol?)
                (set-initial-label-states)))
            (when (and new-search? (not to-eol?))
              (doto targets
                (set-shortcuts-and-populate-shortcuts-map)
                (set-beacons {:repeat nil}))
              (with-highlight-chores
                (light-up-beacons targets)))
            (match (or prev-in2
                       (when to-eol? "")
                       (with-highlight-cleanup (get-input))
                       (exit-early))
              in2
              (match (?. targets.shortcuts in2)
                {:pair [_ ch2] &as shortcut}
                (exit (update-state {:cold {:in2 ch2} :dot {:in2 ch2 :in3 in2}})
                      (jump-to! shortcut (= ch2 "\r")))

                _
                (do
                  (set to-pre-eol? (= in2 "\r"))
                  (update-state {:cold {: in2}})  ; endnote #1
                  (match (or (?. instant-state :sublist)
                             (get-sublist targets in2)
                             (exit-early (echo-not-found (.. in1 in2))))
                    [only nil]
                    (exit (update-state
                            ; TODO: What if the user sets a different char to
                            ; labels[1] and safe_labels[1]? This whole approach
                            ; of mindlessly replaying a key sequence for repeat
                            ; has its flaws, obviously...
                            {:dot {: in2 :in3 (. (or opts.labels opts.safe_labels) 1)}})
                          (jump-to! only))

                    [first &as sublist]
                    (let [autojump? sublist.autojump?
                          curr-idx (or (?. instant-state :idx)
                                       (if autojump? 1 0))
                          from-reverse-cold-repeat? (if instant-repeat?
                                                        instant-state.from-reverse-cold-repeat?
                                                        (and cold-repeat? invoked-as-reverse?))]
                      ; If instant-repeating, we have already done the jump,
                      ; before descending into the recursive call (see below).
                      (when (and autojump? (not instant-repeat?))
                        ; Saves the view into a :winview field of `first`.
                        ; (We need to restore it if we happen to move on later.)
                        (jump-to! first nil true))
                      (match (or (when (and dot-repeat? self.state.dot.in3)  ; endnote #3
                                   [self.state.dot.in3 0])
                                 (get-last-input sublist (inc curr-idx))
                                 (exit-early))
                        [in3 group-offset]
                        (match (when-not (or op-mode? (> group-offset 0))
                                 (get-repeat-action in3 :sx x-mode? instant-repeat?
                                                    from-reverse-cold-repeat?))
                          action (let [idx (match action
                                             :repeat (min (inc curr-idx) (length targets))
                                             :revert (max (dec curr-idx) 1))
                                       neighbor (. sublist idx)]
                                   (restore-view-on-winleave first neighbor)
                                   (jump-to! neighbor)
                                   (sx:go {: reverse? : x-mode?
                                           :repeat-invoc {: in1 : in2 : sublist : idx
                                                          : from-reverse-cold-repeat?
                                                          :target-windows ?target-windows}}))
                          _ (match (when-not (and instant-repeat? (not autojump?)) ; = no safe label set
                                     (get-target-with-active-primary-label sublist in3))
                              target (exit (update-state
                                             {:dot {: in2 :in3 (if (> group-offset 0) nil in3)}})  ; endnote #3
                                           (restore-view-on-winleave first target)
                                           (jump-to! target))
                              _ (if (or autojump? instant-repeat?)
                                    (exit (vim.fn.feedkeys in3 :i))
                                    (exit-early))))))))))))))))


; Handling editor options ///1

; We will probably expose this table in the future, as an `opts` field.
(local temporary-editor-opts {:vim.wo.conceallevel 0
                              :vim.wo.scrolloff 0
                              :vim.wo.sidescrolloff 0
                              :vim.o.scrolloff 0
                              :vim.o.sidescrolloff 0
                              :vim.bo.modeline false})  ; #81

(local saved-editor-opts {})


(fn save-editor-opts []
  (each [opt _ (pairs temporary-editor-opts)]
    (let [[_ scope name] (vim.split opt "." true)]
      (tset saved-editor-opts
            opt
            ; Workaround for Nvim #13964.
            (if (= opt :vim.wo.scrolloff) (api.nvim_eval "&l:scrolloff")
                (= opt :vim.wo.sidescrolloff) (api.nvim_eval "&l:sidescrolloff")
                (= opt :vim.o.scrolloff) (api.nvim_eval "&scrolloff")
                (= opt :vim.o.sidescrolloff) (api.nvim_eval "&sidescrolloff")
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

; Just for our convenience, to be used here in the script.
(each [_ [lhs rhs]
       (ipairs
         [["<Plug>Lightspeed_dotrepeat_s" #(sx:go {:repeat-invoc "dot"})]
          ["<Plug>Lightspeed_dotrepeat_S" #(sx:go {:repeat-invoc "dot" :reverse? true})]
          ["<Plug>Lightspeed_dotrepeat_x" #(sx:go {:repeat-invoc "dot" :x-mode? true})]
          ["<Plug>Lightspeed_dotrepeat_X" #(sx:go {:repeat-invoc "dot" :reverse? true :x-mode? true})]

          ["<Plug>Lightspeed_dotrepeat_f" #(ft:go {:repeat-invoc "dot"})]
          ["<Plug>Lightspeed_dotrepeat_F" #(ft:go {:repeat-invoc "dot" :reverse? true})]
          ["<Plug>Lightspeed_dotrepeat_t" #(ft:go {:repeat-invoc "dot" :t-mode? true})]
          ["<Plug>Lightspeed_dotrepeat_T" #(ft:go {:repeat-invoc "dot" :reverse? true :t-mode? true})]])]
  (vim.keymap.set :o lhs rhs {:silent true}))


; Init ///1

(init-highlight)

(api.nvim_create_augroup "LightspeedDefault" {})

; Colorscheme plugins might clear out our highlight definitions, without
; defining their own, so we re-init the highlight on every change.
(api.nvim_create_autocmd "ColorScheme"
                         {:callback #(init-highlight)
                          :group "LightspeedDefault"})

(api.nvim_create_autocmd "User"
                         {:pattern "LightspeedEnter"
                          :callback #(do (save-editor-opts)
                                         (set-temporary-editor-opts))
                          :group "LightspeedDefault"})

(api.nvim_create_autocmd "User"
                         {:pattern "LightspeedLeave"
                          :callback restore-editor-opts
                          :group "LightspeedDefault"})


; Endnotes ///1

; (1) This should be saved right here, because the repeated search might
;     have a match anyway.

; (2) This is in fact coupled with `onscreen-match-positions`, so it's
;     _much_ cleaner to implement the logic here than in `count`. In
;     that case, we would have to duplicate the whole logic of
;     transforming the input to the actual pattern (that might get
;     arbitrarily complex with future enhancements).

; (3) If the operation spanned beyond the first group, we clear
;     self.state.dot.in3, and will ask for input. It makes no practical
;     sense to dot-repeat such an operation exactly as it went ("delete
;     again till the 27th match..."?). The most intuitive/logical
;     behaviour is repeating as <backspace>-repeat in these cases,
;     prompting for a target label again.
;     Note: `save-state-for-repeat` only executes on new searches - if
;     we're currently dot-repeating, then it won't overwrite the state,
;     we can safely get `self.state.dot.in3` for the previous value.

; (4) We need to save the mode here, because the `:normal` command in
;     `jump-to!*` can change the state. Related: vim/vim#9332.

; (5) In OP mode, we _always_ use `opts.labels` (no autojump), so the
;     problem of non-deterministic label assignment does not arise -
;     that is, for dot-repeat, we can safely save either an item from
;     `opts.labels` or the actual user input from here on.


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
