local api = vim.api
local function inc(x)
  return (x + 1)
end
local function dec(x)
  return (x - 1)
end
local function clamp(val, min, max)
  if (val < min) then
    return min
  elseif (val > max) then
    return max
  elseif "else" then
    return val
  end
end
local function last(tbl)
  return tbl[#tbl]
end
local empty_3f = vim.tbl_isempty
local function reverse_lookup(tbl)
  local tbl_9_auto = {}
  for k, v in ipairs(tbl) do
    local _2_, _3_ = v, k
    if ((nil ~= _2_) and (nil ~= _3_)) then
      local k_10_auto = _2_
      local v_11_auto = _3_
      tbl_9_auto[k_10_auto] = v_11_auto
    end
  end
  return tbl_9_auto
end
local function echo(msg)
  vim.cmd("redraw")
  return api.nvim_echo({{msg}}, false, {})
end
local function replace_vim_keycodes(s)
  return api.nvim_replace_termcodes(s, true, false, true)
end
local function operator_pending_mode_3f()
  return string.match(api.nvim_get_mode().mode, "o")
end
local function yank_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "y"))
end
local function change_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "c"))
end
local function delete_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "d"))
end
local function dot_repeatable_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator ~= "y"))
end
local function get_current_pos()
  return {vim.fn.line("."), vim.fn.col(".")}
end
local function char_at_pos(_5_, _7_)
  local _arg_6_ = _5_
  local line = _arg_6_[1]
  local byte_col = _arg_6_[2]
  local _arg_8_ = _7_
  local char_offset = _arg_8_["char-offset"]
  local line_str = vim.fn.getline(line)
  local char_idx = vim.fn.charidx(line_str, dec(byte_col))
  local char_nr = vim.fn.strgetchar(line_str, (char_idx + (char_offset or 0)))
  if (char_nr ~= -1) then
    return vim.fn.nr2char(char_nr)
  end
end
local function leftmost_editable_wincol()
  local view = vim.fn.winsaveview()
  vim.cmd("norm! 0")
  local wincol = vim.fn.wincol()
  vim.fn.winrestview(view)
  return wincol
end
local opts = {cycle_group_bwd_key = nil, cycle_group_fwd_key = nil, full_inclusive_prefix_key = "<c-x>", grey_out_search_area = true, highlight_unique_chars = false, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, jump_to_first_match = true, labels = nil, limit_ft_matches = 5, match_only_the_start_of_same_char_seqs = true}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local hl
local function _10_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _11_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _12_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _10_, ["set-extmark"] = _11_, cleanup = _12_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-change-op-area"] = "LightspeedPendingChangeOpArea", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight()
  local bg = vim.o.background
  local groupdefs
  local _14_
  do
    local _13_ = bg
    if (_13_ == "light") then
      _14_ = "#f02077"
    else
      local _ = _13_
      _14_ = "#ff2f87"
    end
  end
  local _19_
  do
    local _18_ = bg
    if (_18_ == "light") then
      _19_ = "#ff4090"
    else
      local _ = _18_
      _19_ = "#e01067"
    end
  end
  local _24_
  do
    local _23_ = bg
    if (_23_ == "light") then
      _24_ = "Blue"
    else
      local _ = _23_
      _24_ = "Cyan"
    end
  end
  local _29_
  do
    local _28_ = bg
    if (_28_ == "light") then
      _29_ = "#399d9f"
    else
      local _ = _28_
      _29_ = "#99ddff"
    end
  end
  local _34_
  do
    local _33_ = bg
    if (_33_ == "light") then
      _34_ = "Cyan"
    else
      local _ = _33_
      _34_ = "Blue"
    end
  end
  local _39_
  do
    local _38_ = bg
    if (_38_ == "light") then
      _39_ = "#59bdbf"
    else
      local _ = _38_
      _39_ = "#79bddf"
    end
  end
  local _44_
  do
    local _43_ = bg
    if (_43_ == "light") then
      _44_ = "Black"
    else
      local _ = _43_
      _44_ = "White"
    end
  end
  local _49_
  do
    local _48_ = bg
    if (_48_ == "light") then
      _49_ = "#272020"
    else
      local _ = _48_
      _49_ = "#f3ecec"
    end
  end
  local _54_
  do
    local _53_ = bg
    if (_53_ == "light") then
      _54_ = "#f02077"
    else
      local _ = _53_
      _54_ = "#ff2f87"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermfg = "Red", gui = "bold,underline", guifg = _14_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermfg = "Magenta", gui = "underline", guifg = _19_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermfg = _24_, gui = "bold,underline", guifg = _29_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _34_, gui = "underline", guifg = _39_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {ctermfg = "DarkGrey", guifg = "#cc9999"}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermfg = _44_, gui = "bold", guifg = _49_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["pending-change-op-area"], {cterm = "strikethrough", ctermfg = "Red", gui = "strikethrough", guifg = _54_}}, {hl.group.greywash, {ctermfg = "Grey", guifg = "#777777"}}}
  for _, _58_ in ipairs(groupdefs) do
    local _each_59_ = _58_
    local group = _each_59_[1]
    local attrs = _each_59_[2]
    local attrs_str
    local _60_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _60_ = tbl_12_auto
    end
    attrs_str = table.concat(_60_, " ")
    vim.cmd(("highlight default " .. group .. " " .. attrs_str))
  end
  for _, _61_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_62_ = _61_
    local from_group = _each_62_[1]
    local to_group = _each_62_[2]
    vim.cmd(("highlight default link " .. from_group .. " " .. to_group))
  end
  return nil
end
init_highlight()
local function add_highlight_autocmds()
  vim.cmd("augroup LightspeedInitHighlight")
  vim.cmd("autocmd!")
  vim.cmd("autocmd ColorScheme * lua require'lightspeed'.init_highlight()")
  return vim.cmd("augroup end")
end
add_highlight_autocmds()
local function grey_out_search_area(reverse_3f)
  local _let_63_ = vim.tbl_map(dec, get_current_pos())
  local curline = _let_63_[1]
  local curcol = _let_63_[2]
  local _let_64_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_64_[1]
  local win_bot = _let_64_[2]
  local function _66_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_65_ = _66_()
  local start = _let_65_[1]
  local finish = _let_65_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function get_char()
  local ch = vim.fn.getchar()
  if (type(ch) == "number") then
    return vim.fn.nr2char(ch)
  else
    return ch
  end
end
local function remove_matchparen_highlight()
  return vim.cmd(":3match")
end
local function force_matchparen_highlight()
  if (vim.fn.exists(":DoMatchParen") == 2) then
    return vim.cmd("DoMatchParen")
  end
end
local function push_cursor_21(direction)
  local _70_
  do
    local _69_ = direction
    if (_69_ == "fwd") then
      _70_ = "W"
    elseif (_69_ == "bwd") then
      _70_ = "bW"
    else
    _70_ = nil
    end
  end
  return vim.fn.search("\\_.", _70_, __fnl_global___3fstopline)
end
local function onscreen_match_positions(pattern, reverse_3f, _74_)
  local _arg_75_ = _74_
  local ft_search_3f = _arg_75_["ft-search?"]
  local limit = _arg_75_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _77_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_77_())
  local cleanup
  local function _78_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _78_
  local non_editable_width = dec(leftmost_editable_wincol())
  local col_in_edit_area = (vim.fn.wincol() - non_editable_width)
  local left_bound = (vim.fn.col(".") - dec(col_in_edit_area))
  local window_width = api.nvim_win_get_width(0)
  local right_bound = (left_bound + dec((window_width - non_editable_width - 1)))
  local function skip_to_fold_edge_21()
    local _79_
    local _80_
    if reverse_3f then
      _80_ = vim.fn.foldclosed
    else
      _80_ = vim.fn.foldclosedend
    end
    _79_ = _80_(vim.fn.line("."))
    if (_79_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _79_) then
      local fold_edge = _79_
      vim.fn.cursor(fold_edge, 0)
      local function _82_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _82_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_onscreen_pos_21()
    local _local_84_ = get_current_pos()
    local line = _local_84_[1]
    local col = _local_84_[2]
    local from_pos = _local_84_
    local _85_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _85_ = {dec(line), right_bound}
        else
        _85_ = nil
        end
      else
        _85_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _85_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _85_ = {inc(line), left_bound}
        else
        _85_ = nil
        end
      end
    else
    _85_ = nil
    end
    if (nil ~= _85_) then
      local to_pos = _85_
      if (from_pos ~= to_pos) then
        vim.fn.cursor(to_pos)
        return "moved-the-cursor"
      end
    end
  end
  vim.o.cpo = cpo:gsub("c", "")
  local match_count = 0
  local function rec(match_at_curpos_3f)
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _93_
      local _94_
      if match_at_curpos_3f then
        _94_ = "c"
      else
        _94_ = ""
      end
      _93_ = vim.fn.searchpos(pattern, (opts0 .. _94_), stopline)
      if ((type(_93_) == "table") and ((_93_)[1] == 0) and true) then
        local _ = (_93_)[2]
        return cleanup()
      elseif ((type(_93_) == "table") and (nil ~= (_93_)[1]) and (nil ~= (_93_)[2])) then
        local line = (_93_)[1]
        local col = (_93_)[2]
        local pos = _93_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _96_ = skip_to_fold_edge_21()
          if (_96_ == "moved-the-cursor") then
            return rec(false)
          elseif (_96_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_97_,_98_,_99_) return (_97_ <= _98_) and (_98_ <= _99_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _100_ = skip_to_next_onscreen_pos_21()
              if (_100_ == "moved-the-cursor") then
                return rec(true)
              else
                local _ = _100_
                return cleanup()
              end
            end
          end
        end
      end
    end
  end
  return rec
end
local function highlight_unique_chars(reverse_3f, ignorecase)
  local unique_chars = {}
  for pos in onscreen_match_positions("..", reverse_3f, {}) do
    local ch = char_at_pos(pos, {})
    local _108_
    do
      local _107_ = unique_chars[ch]
      if (_107_ == nil) then
        _108_ = pos
      else
        local _ = _107_
        _108_ = false
      end
    end
    unique_chars[ch] = _108_
  end
  for ch, pos_or_false in pairs(unique_chars) do
    if pos_or_false then
      local _let_112_ = pos_or_false
      local line = _let_112_[1]
      local col = _let_112_[2]
      hl["set-extmark"](hl, dec(line), dec(col), {virt_text = {{ch, hl.group["unique-ch"]}}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function highlight_cursor(_3fpos)
  local _let_114_ = (_3fpos or get_current_pos())
  local line = _let_114_[1]
  local col = _let_114_[2]
  local pos = _let_114_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return hl["set-extmark"](hl, dec(line), dec(col), {hl_mode = "combine", virt_text = {{ch_at_curpos, hl.group.cursor}}, virt_text_pos = "overlay"})
end
local function handle_interrupted_change_op_21()
  echo("")
  local curcol = vim.fn.col(".")
  local endcol = vim.fn.col("$")
  local _3fright
  if (not vim.o.insertmode and (curcol > 1) and (curcol < endcol)) then
    _3fright = "<RIGHT>"
  else
    _3fright = ""
  end
  return api.nvim_feedkeys(replace_vim_keycodes(("<C-\\><C-G>" .. _3fright)), "n", true)
end
local function get_input_and_clean_up()
  local ok_3f, res = pcall(get_char)
  hl:cleanup()
  if (ok_3f and (res ~= replace_vim_keycodes("<esc>"))) then
    return res
  else
    if change_operation_3f() then
      handle_interrupted_change_op_21()
    end
    do
    end
    return nil
  end
end
local function set_dot_repeat(cmd, _3fcount)
  if operator_pending_mode_3f() then
    local op = vim.v.operator
    if (op ~= "y") then
      local change
      if (op == "c") then
        change = replace_vim_keycodes("<c-r>.<esc>")
      else
      change = nil
      end
      local seq = (op .. (_3fcount or "") .. cmd .. (change or ""))
      pcall(vim.fn["repeat#setreg"], seq, vim.v.register)
      return pcall(vim.fn["repeat#set"], seq, -1)
    end
  end
end
local ft = {["instant-repeat?"] = nil, ["prev-dot-repeatable-search"] = nil, ["prev-reverse?"] = nil, ["prev-search"] = nil, ["prev-t-like?"] = nil, ["started-reverse?"] = nil}
ft.to = function(self, reverse_3f, t_like_3f, dot_repeat_3f)
  local _let_121_ = self
  local instant_repeat_3f = _let_121_["instant-repeat?"]
  local started_reverse_3f = _let_121_["started-reverse?"]
  local _
  if not instant_repeat_3f then
    self["started-reverse?"] = reverse_3f
    _ = nil
  else
  _ = nil
  end
  local reverse_3f0
  if instant_repeat_3f then
    reverse_3f0 = ((not reverse_3f and started_reverse_3f) or (reverse_3f and not started_reverse_3f))
  else
    reverse_3f0 = reverse_3f
  end
  local switched_directions_3f = ((reverse_3f0 and not self["prev-reverse?"]) or (not reverse_3f0 and self["prev-reverse?"]))
  local switched_f__3et_3f = (t_like_3f and not self["prev-t-like?"])
  local count
  if (instant_repeat_3f and t_like_3f and not (switched_f__3et_3f or switched_directions_3f)) then
    count = inc(vim.v.count1)
  else
    count = vim.v.count1
  end
  local _let_125_ = vim.tbl_map(replace_vim_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_fwd_key = _let_125_[1]
  local repeat_bwd_key = _let_125_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local motion
  if (not t_like_3f and not reverse_3f0) then
    motion = "f"
  elseif (not t_like_3f and reverse_3f0) then
    motion = "F"
  elseif (t_like_3f and not reverse_3f0) then
    motion = "t"
  elseif (t_like_3f and reverse_3f0) then
    motion = "T"
  else
  motion = nil
  end
  local cmd_for_dot_repeat = (replace_vim_keycodes("<Plug>Lightspeed_repeat_") .. motion)
  if not (instant_repeat_3f or dot_repeat_3f) then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local repeat_3f = nil
  local _128_
  if instant_repeat_3f then
    _128_ = self["prev-search"]
  elseif dot_repeat_3f then
    _128_ = self["prev-dot-repeatable-search"]
  else
    local _129_ = get_input_and_clean_up()
    if (_129_ == "\13") then
      repeat_3f = true
      local function _130_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_no_prev_search()
        end
        return nil
      end
      _128_ = (self["prev-search"] or _130_())
    elseif (nil ~= _129_) then
      local _in = _129_
      _128_ = _in
    else
    _128_ = nil
    end
  end
  if (nil ~= _128_) then
    local in1 = _128_
    local new_search_3f = not (repeat_3f or instant_repeat_3f or dot_repeat_3f)
    if new_search_3f then
      if dot_repeatable_op_3f then
        self["prev-dot-repeatable-search"] = in1
        set_dot_repeat(cmd_for_dot_repeat, count)
      else
        self["prev-search"] = in1
      end
    end
    self["prev-t-like?"] = t_like_3f
    self["prev-reverse?"] = reverse_3f0
    local i = 0
    local target_pos = nil
    local function _138_()
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit
      if opts.limit_ft_matches then
        limit = (count + opts.limit_ft_matches)
      else
      limit = nil
      end
      return onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit})
    end
    for _136_ in _138_() do
      local _each_139_ = _136_
      local line = _each_139_[1]
      local col = _each_139_[2]
      local pos = _each_139_
      i = (i + 1)
      if (i <= count) then
        target_pos = pos
      else
        if not op_mode_3f then
          hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
        end
      end
    end
    if (i == 0) then
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        echo_not_found(in1)
      end
      return nil
    else
      do
        remove_matchparen_highlight()
        if not instant_repeat_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target_pos)
        do
          if t_like_3f then
            local function _144_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_144_())
          end
          if (op_mode_3f and not reverse_3f0) then
            push_cursor_21("fwd")
          end
        end
        force_matchparen_highlight()
      end
      if (new_search_3f and dot_repeatable_op_3f) then
        set_dot_repeat(cmd_for_dot_repeat, count)
      end
      if not op_mode_3f then
        highlight_cursor()
        vim.cmd("redraw")
        local ok_3f, in2 = pcall(get_char)
        local custom_repeat_key_used_3f = ((in2 == repeat_fwd_key) or (in2 == repeat_bwd_key))
        self["instant-repeat?"] = (ok_3f and (custom_repeat_key_used_3f or string.match(vim.fn.maparg(in2), "<Plug>Lightspeed_[fFtT]")))
        if custom_repeat_key_used_3f then
          hl:cleanup()
          ft:to((in2 == repeat_bwd_key), t_like_3f)
        else
          local _148_
          if ok_3f then
            _148_ = in2
          else
            _148_ = replace_vim_keycodes("<esc>")
          end
          vim.fn.feedkeys(_148_, "i")
        end
      end
      return hl:cleanup()
    end
  end
end
local function get_labels()
  local function _154_()
    if opts.jump_to_first_match then
      return {"s", "f", "n", "/", "u", "t", "q", "S", "F", "G", "H", "L", "M", "N", "?", "U", "R", "Z", "T", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "a", ";", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "z", "."}
    end
  end
  return (opts.labels or _154_())
end
local function get_cycle_keys()
  local function _155_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _156_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return vim.tbl_map(replace_vim_keycodes, {(opts.cycle_group_fwd_key or _155_()), (opts.cycle_group_bwd_key or _156_())})
end
local function get_match_map_for(ch1, reverse_3f)
  local match_map = {}
  local prefix = "\\V\\C"
  local input = ch1:gsub("\\", "\\\\")
  local pattern = (prefix .. input .. "\\.")
  local match_count = 0
  local prev = {}
  for _157_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_158_ = _157_
    local line = _each_158_[1]
    local col = _each_158_[2]
    local pos = _each_158_
    local overlap_with_prev_3f
    local _159_
    if reverse_3f then
      _159_ = dec
    else
      _159_ = inc
    end
    overlap_with_prev_3f = ((line == prev.line) and (col == _159_(prev.col)))
    local ch2 = char_at_pos(pos, {["char-offset"] = 1})
    local same_pair_3f = (ch2 == prev.ch2)
    local function _161_()
      if not opts.match_only_the_start_of_same_char_seqs then
        return prev["skipped?"]
      end
    end
    if (_161_() or not (overlap_with_prev_3f and same_pair_3f)) then
      local partially_covered_3f = (overlap_with_prev_3f and not reverse_3f)
      if not match_map[ch2] then
        match_map[ch2] = {}
      end
      table.insert(match_map[ch2], {line, col, partially_covered_3f, __fnl_global___3fch3})
      if (overlap_with_prev_3f and reverse_3f) then
        last(match_map[prev.ch2])[3] = true
      end
      prev = {["skipped?"] = false, ch2 = ch2, col = col, line = line}
      match_count = (match_count + 1)
    else
      prev = {["skipped?"] = true, ch2 = ch2, col = col, line = line}
    end
  end
  local _165_ = match_count
  if (_165_ == 0) then
    return nil
  elseif (_165_ == 1) then
    local ch2 = vim.tbl_keys(match_map)[1]
    local pos = vim.tbl_values(match_map)[1][1]
    return {ch2, pos}
  else
    local _ = _165_
    return match_map
  end
end
local function set_beacon_at(_167_, field1_ch, field2_ch, _169_)
  local _arg_168_ = _167_
  local line = _arg_168_[1]
  local col = _arg_168_[2]
  local partially_covered_3f = _arg_168_[3]
  local pos = _arg_168_
  local _arg_170_ = _169_
  local distant_3f = _arg_170_["distant?"]
  local init_round_3f = _arg_170_["init-round?"]
  local repeat_3f = _arg_170_["repeat?"]
  local shortcut_3f = _arg_170_["shortcut?"]
  local unlabeled_3f = _arg_170_["unlabeled?"]
  local partially_covered_3f0
  if not repeat_3f then
    partially_covered_3f0 = partially_covered_3f
  else
  partially_covered_3f0 = nil
  end
  local shortcut_3f0
  if not repeat_3f then
    shortcut_3f0 = shortcut_3f
  else
  shortcut_3f0 = nil
  end
  local label_hl
  if shortcut_3f0 then
    label_hl = hl.group.shortcut
  elseif distant_3f then
    label_hl = hl.group["label-distant"]
  else
    label_hl = hl.group.label
  end
  local overlapped_label_hl
  if distant_3f then
    overlapped_label_hl = hl.group["label-distant-overlapped"]
  else
    if shortcut_3f0 then
      overlapped_label_hl = hl.group["shortcut-overlapped"]
    else
      overlapped_label_hl = hl.group["label-overlapped"]
    end
  end
  local function _179_()
    if unlabeled_3f then
      if partially_covered_3f0 then
        return {inc(col), {field2_ch, hl.group["unlabeled-match"]}, nil}
      else
        return {col, {field1_ch, hl.group["unlabeled-match"]}, {field2_ch, hl.group["unlabeled-match"]}}
      end
    elseif partially_covered_3f0 then
      if init_round_3f then
        return {inc(col), {field2_ch, overlapped_label_hl}, nil}
      else
        return {col, {field1_ch, hl.group["masked-ch"]}, {field2_ch, overlapped_label_hl}}
      end
    elseif repeat_3f then
      return {inc(col), {field2_ch, label_hl}, nil}
    elseif "else" then
      return {col, {field1_ch, hl.group["masked-ch"]}, {field2_ch, label_hl}}
    end
  end
  local _let_176_ = _179_()
  local col0 = _let_176_[1]
  local chunk1 = _let_176_[2]
  local _3fchunk2 = _let_176_[3]
  return hl["set-extmark"](hl, dec(line), dec(col0), {end_col = col0, virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
end
local function set_beacon_groups(ch2, positions, labels, shortcuts, _180_)
  local _arg_181_ = _180_
  local group_offset = _arg_181_["group-offset"]
  local init_round_3f = _arg_181_["init-round?"]
  local repeat_3f = _arg_181_["repeat?"]
  local group_offset0 = (group_offset or 0)
  local _7clabels_7c = #labels
  local set_group
  local function _182_(start, distant_3f)
    for i = start, dec((start + _7clabels_7c)) do
      if ((i < 1) or (i > #positions)) then break end
      local pos = positions[i]
      local label = (labels[(i % _7clabels_7c)] or labels[_7clabels_7c])
      local shortcut_3f
      if not distant_3f then
        shortcut_3f = shortcuts[pos]
      else
      shortcut_3f = nil
      end
      set_beacon_at(pos, ch2, label, {["distant?"] = distant_3f, ["init-round?"] = init_round_3f, ["repeat?"] = repeat_3f, ["shortcut?"] = shortcut_3f})
    end
    return nil
  end
  set_group = _182_
  local start = inc((group_offset0 * _7clabels_7c))
  local _end = dec((start + _7clabels_7c))
  set_group(start, false)
  return set_group((start + _7clabels_7c), true)
end
local function get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
  local collides_with_a_ch2_3f
  local function _184_(_241)
    return vim.tbl_contains(vim.tbl_keys(match_map), _241)
  end
  collides_with_a_ch2_3f = _184_
  local by_distance_from_cursor
  local function _191_(_185_, _188_)
    local _arg_186_ = _185_
    local _arg_187_ = _arg_186_[1]
    local l1 = _arg_187_[1]
    local c1 = _arg_187_[2]
    local _ = _arg_186_[2]
    local _0 = _arg_186_[3]
    local _arg_189_ = _188_
    local _arg_190_ = _arg_189_[1]
    local l2 = _arg_190_[1]
    local c2 = _arg_190_[2]
    local _1 = _arg_189_[2]
    local _2 = _arg_189_[3]
    if (l1 == l2) then
      if reverse_3f then
        return (c1 > c2)
      else
        return (c1 < c2)
      end
    else
      if reverse_3f then
        return (l1 > l2)
      else
        return (l1 < l2)
      end
    end
  end
  by_distance_from_cursor = _191_
  local shortcuts = {}
  for ch2, positions in pairs(match_map) do
    for i, pos in ipairs(positions) do
      local labeled_pos_3f = not ((#positions == 1) or (jump_to_first_3f and (i == 1)))
      if labeled_pos_3f then
        local _195_
        local _196_
        if jump_to_first_3f then
          _196_ = dec(i)
        else
          _196_ = i
        end
        _195_ = labels[_196_]
        if (nil ~= _195_) then
          local label = _195_
          if not collides_with_a_ch2_3f(label) then
            table.insert(shortcuts, {pos, label, ch2})
          end
        end
      end
    end
  end
  table.sort(shortcuts, by_distance_from_cursor)
  local lookup_by_pos
  do
    local labels_used_up = {}
    local tbl_9_auto = {}
    for _, _201_ in ipairs(shortcuts) do
      local _each_202_ = _201_
      local pos = _each_202_[1]
      local label = _each_202_[2]
      local ch2 = _each_202_[3]
      local _203_, _204_ = nil, nil
      if not labels_used_up[label] then
        labels_used_up[label] = true
        _203_, _204_ = pos, {label, ch2}
      else
      _203_, _204_ = nil
      end
      if ((nil ~= _203_) and (nil ~= _204_)) then
        local k_10_auto = _203_
        local v_11_auto = _204_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    lookup_by_pos = tbl_9_auto
  end
  local lookup_by_label
  do
    local tbl_9_auto = {}
    for pos, _207_ in pairs(lookup_by_pos) do
      local _each_208_ = _207_
      local label = _each_208_[1]
      local ch2 = _each_208_[2]
      local _209_, _210_ = label, {pos, ch2}
      if ((nil ~= _209_) and (nil ~= _210_)) then
        local k_10_auto = _209_
        local v_11_auto = _210_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    lookup_by_label = tbl_9_auto
  end
  return vim.tbl_extend("error", lookup_by_pos, lookup_by_label)
end
local function ignore_char_until_timeout(char_to_ignore)
  local start = os.clock()
  local timeout_secs = (opts.jump_on_partial_input_safety_timeout / 1000)
  local ok_3f, input = pcall(get_char)
  if not ((input == char_to_ignore) and (os.clock() < (start + timeout_secs))) then
    if ok_3f then
      return vim.fn.feedkeys(input, "i")
    end
  end
end
local s = {["prev-dot-repeatable-search"] = {["full-incl?"] = nil, in1 = nil, in2 = nil, in3 = nil}, ["prev-search"] = {in1 = nil, in2 = nil}}
s.to = function(self, reverse_3f, dot_repeat_3f)
  local op_mode_3f = operator_pending_mode_3f()
  local change_op_3f = change_operation_3f()
  local delete_op_3f = delete_operation_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local full_inclusive_prefix_key = replace_vim_keycodes(opts.full_inclusive_prefix_key)
  local _let_214_ = get_cycle_keys()
  local cycle_fwd_key = _let_214_[1]
  local cycle_bwd_key = _let_214_[2]
  local labels = get_labels()
  local label_indexes = reverse_lookup(labels)
  local jump_to_first_3f = (opts.jump_to_first_match and not op_mode_3f)
  local cmd_for_dot_repeat
  local _215_
  if reverse_3f then
    _215_ = "S"
  else
    _215_ = "s"
  end
  cmd_for_dot_repeat = replace_vim_keycodes(("<Plug>Lightspeed_repeat_" .. _215_))
  local function switch_off_scrolloff()
    if jump_to_first_3f then
      local _3floc
      if (api.nvim_eval("&l:scrolloff") ~= -1) then
        _3floc = "l:"
      else
        _3floc = ""
      end
      local saved_val = api.nvim_eval(("&" .. _3floc .. "scrolloff"))
      self["restore-scrolloff-cmd"] = ("let &" .. _3floc .. "scrolloff=" .. saved_val)
      return vim.cmd(("let &" .. _3floc .. "scrolloff=0"))
    end
  end
  local function restore_scrolloff()
    if jump_to_first_3f then
      return vim.cmd((self["restore-scrolloff-cmd"] or ""))
    end
  end
  local function cycle_through_match_groups(in2, positions_to_label, shortcuts, repeat_3f)
    local ret = nil
    local group_offset = 0
    local loop_3f = true
    while loop_3f do
      local _220_
      local function _221_()
        if dot_repeat_3f then
          return self["prev-dot-repeatable-search"].in3
        end
      end
      local function _222_()
        loop_3f = false
        restore_scrolloff()
        ret = nil
        return nil
      end
      _220_ = (_221_() or get_input_and_clean_up() or _222_())
      if (nil ~= _220_) then
        local input = _220_
        if not ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          loop_3f = false
          ret = {group_offset, input}
        else
          local max_offset = math.floor((#positions_to_label / #labels))
          local _224_
          do
            local _223_ = input
            if (_223_ == cycle_fwd_key) then
              _224_ = inc
            else
              local _ = _223_
              _224_ = dec
            end
          end
          group_offset = clamp(_224_(group_offset), 0, max_offset)
          if opts.grey_out_search_area then
            grey_out_search_area(reverse_3f)
          end
          do
            set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["group-offset"] = group_offset, ["repeat?"] = repeat_3f})
          end
          highlight_cursor()
          vim.cmd("redraw")
        end
      end
    end
    return ret
  end
  local repeat_3f = nil
  local new_search_3f = nil
  local full_incl_3f = nil
  local function save_state_for(_231_)
    local _arg_232_ = _231_
    local dot_repeat = _arg_232_["dot-repeat"]
    local _repeat = _arg_232_["repeat"]
    if new_search_3f then
      if dot_repeatable_op_3f then
        if dot_repeat then
          dot_repeat["full-incl?"] = full_incl_3f
          self["prev-dot-repeatable-search"] = dot_repeat
          return nil
        end
      elseif _repeat then
        self["prev-search"] = _repeat
        return nil
      end
    end
  end
  local jump_with_wrap_21
  do
    local first_jump_3f = true
    local function _236_(target)
      do
        remove_matchparen_highlight()
        if first_jump_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target)
        if (full_incl_3f and not reverse_3f) then
          push_cursor_21("fwd")
          if op_mode_3f then
            push_cursor_21("fwd")
          end
        end
        force_matchparen_highlight()
      end
      if dot_repeatable_op_3f then
        set_dot_repeat(cmd_for_dot_repeat)
      end
      first_jump_3f = false
      return nil
    end
    jump_with_wrap_21 = _236_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_241_, ch2)
    local _arg_242_ = _241_
    local line = _arg_242_[1]
    local col = _arg_242_[2]
    local _ = _arg_242_[3]
    local target = _arg_242_
    local orig_pos = get_current_pos()
    jump_with_wrap_21(target)
    if new_search_3f then
      if not change_op_3f then
        local function _243_()
          if (op_mode_3f and not reverse_3f) then
            return orig_pos
          end
        end
        highlight_cursor(_243_())
      end
      if op_mode_3f then
        local _let_245_ = {vim.tbl_map(dec, orig_pos), {dec(line), dec(col)}}
        local from_pos = _let_245_[1]
        local to_pos = _let_245_[2]
        local function _247_()
          if reverse_3f then
            return {to_pos, from_pos}
          else
            return {from_pos, to_pos}
          end
        end
        local _let_246_ = _247_()
        local start = _let_246_[1]
        local finish = _let_246_[2]
        local hl_group
        if (change_op_3f or delete_op_3f) then
          hl_group = hl.group["pending-change-op-area"]
        else
          hl_group = hl.group["pending-op-area"]
        end
        vim.highlight.range(0, hl.ns, hl_group, start, finish)
      end
      vim.cmd("redraw")
      ignore_char_until_timeout(ch2)
      if change_op_3f then
        echo("")
      end
      return hl:cleanup()
    end
  end
  if not dot_repeat_3f then
    echo("")
    if opts.grey_out_search_area then
      grey_out_search_area(reverse_3f)
    end
    do
      if opts.highlight_unique_chars then
        highlight_unique_chars(reverse_3f)
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _255_
  if dot_repeat_3f then
    full_incl_3f = self["prev-dot-repeatable-search"]["full-incl?"]
    _255_ = self["prev-dot-repeatable-search"].in1
  else
    local _256_ = get_input_and_clean_up()
    if (nil ~= _256_) then
      local in0 = _256_
      repeat_3f = (in0 == "\13")
      new_search_3f = not (repeat_3f or dot_repeat_3f)
      full_incl_3f = (in0 == full_inclusive_prefix_key)
      if repeat_3f then
        local function _257_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          end
          do
            echo_no_prev_search()
          end
          return nil
        end
        _255_ = (self["prev-search"].in1 or _257_())
      elseif full_incl_3f then
        _255_ = get_input_and_clean_up()
      else
        _255_ = in0
      end
    else
    _255_ = nil
    end
  end
  if (nil ~= _255_) then
    local in1 = _255_
    local _262_
    local function _263_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        local function _265_()
          if repeat_3f then
            return (in1 .. self["prev-search"].in2)
          elseif dot_repeat_3f then
            return (in1 .. self["prev-dot-repeatable-search"].in2)
          else
            return in1
          end
        end
        echo_not_found(_265_())
      end
      return nil
    end
    _262_ = (get_match_map_for(in1, reverse_3f) or _263_())
    if ((type(_262_) == "table") and (nil ~= (_262_)[1]) and (nil ~= (_262_)[2])) then
      local ch2 = (_262_)[1]
      local pos = (_262_)[2]
      if (new_search_3f or (repeat_3f and (ch2 == self["prev-search"].in2)) or (dot_repeat_3f and (ch2 == self["prev-dot-repeatable-search"].in2))) then
        save_state_for({["dot-repeat"] = {in1 = in1, in2 = ch2, in3 = labels[1]}, ["repeat"] = {in1 = in1, in2 = ch2}})
        return jump_and_ignore_ch2_until_timeout_21(pos, ch2)
      else
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_not_found((in1 .. ch2))
        end
        return nil
      end
    elseif (nil ~= _262_) then
      local match_map = _262_
      local shortcuts = get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
      if new_search_3f then
        if opts.grey_out_search_area then
          grey_out_search_area(reverse_3f)
        end
        do
          for ch2, positions in pairs(match_map) do
            local _let_269_ = positions
            local first = _let_269_[1]
            local rest = {(table.unpack or unpack)(_let_269_, 2)}
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest
            else
              positions_to_label = positions
            end
            if (jump_to_first_3f or empty_3f(rest)) then
              set_beacon_at(first, in1, ch2, {["init-round?"] = true, ["unlabeled?"] = true})
            end
            if not empty_3f(rest) then
              set_beacon_groups(ch2, positions_to_label, labels, shortcuts, {["init-round?"] = true})
            end
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _274_
      if repeat_3f then
        _274_ = self["prev-search"].in2
      elseif dot_repeat_3f then
        _274_ = self["prev-dot-repeatable-search"].in2
      else
        _274_ = get_input_and_clean_up()
      end
      if (nil ~= _274_) then
        local in2 = _274_
        local _276_
        if new_search_3f then
          _276_ = shortcuts[in2]
        else
        _276_ = nil
        end
        if ((type(_276_) == "table") and (nil ~= (_276_)[1]) and (nil ~= (_276_)[2])) then
          local pos = (_276_)[1]
          local ch2 = (_276_)[2]
          save_state_for({["dot-repeat"] = {in1 = in1, in2 = ch2, in3 = in2}, ["repeat"] = {in1 = in1, in2 = ch2}})
          return jump_with_wrap_21(pos)
        elseif (_276_ == nil) then
          save_state_for({["dot-repeat"] = {in1 = in1, in2 = in2, in3 = labels[1]}, ["repeat"] = {in1 = in1, in2 = in2}})
          local _278_
          local function _279_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
              echo_not_found((in1 .. in2))
            end
            return nil
          end
          _278_ = (match_map[in2] or _279_())
          if (nil ~= _278_) then
            local positions = _278_
            local _let_281_ = positions
            local first = _let_281_[1]
            local rest = {(table.unpack or unpack)(_let_281_, 2)}
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest
            else
              positions_to_label = positions
            end
            if (jump_to_first_3f or empty_3f(rest)) then
              jump_with_wrap_21(first)
            end
            if not empty_3f(rest) then
              switch_off_scrolloff()
              if not (dot_repeat_3f and self["prev-dot-repeatable-search"].in3) then
                if opts.grey_out_search_area then
                  grey_out_search_area(reverse_3f)
                end
                do
                  set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["repeat?"] = repeat_3f})
                end
                highlight_cursor()
                vim.cmd("redraw")
              end
              local _286_ = cycle_through_match_groups(in2, positions_to_label, shortcuts, repeat_3f)
              if ((type(_286_) == "table") and (nil ~= (_286_)[1]) and (nil ~= (_286_)[2])) then
                local group_offset = (_286_)[1]
                local in3 = (_286_)[2]
                if (dot_repeatable_op_3f and not dot_repeat_3f) then
                  if (group_offset == 0) then
                    self["prev-dot-repeatable-search"].in3 = in3
                  else
                    self["prev-dot-repeatable-search"].in3 = nil
                  end
                end
                local _289_
                local function _291_()
                  local _290_ = label_indexes[in3]
                  if _290_ then
                    local _292_ = ((group_offset * #labels) + _290_)
                    if _292_ then
                      return positions_to_label[_292_]
                    else
                      return _292_
                    end
                  else
                    return _290_
                  end
                end
                local function _295_()
                  if change_operation_3f() then
                    handle_interrupted_change_op_21()
                  end
                  do
                    if jump_to_first_3f then
                      restore_scrolloff()
                      vim.fn.feedkeys(in3, "i")
                    end
                  end
                  return nil
                end
                _289_ = (_291_() or _295_())
                if (nil ~= _289_) then
                  local pos = _289_
                  restore_scrolloff()
                  return jump_with_wrap_21(pos)
                end
              end
            end
          end
        end
      end
    end
  end
end
local plug_mappings = {{"n", "<Plug>Lightspeed_s", "s:to(false)"}, {"n", "<Plug>Lightspeed_S", "s:to(true)"}, {"x", "<Plug>Lightspeed_s", "s:to(false)"}, {"x", "<Plug>Lightspeed_S", "s:to(true)"}, {"o", "<Plug>Lightspeed_s", "s:to(false)"}, {"o", "<Plug>Lightspeed_S", "s:to(true)"}, {"o", "<Plug>Lightspeed_repeat_s", "s:to(false, true)"}, {"o", "<Plug>Lightspeed_repeat_S", "s:to(true, true)"}, {"n", "<Plug>Lightspeed_f", "ft:to(false, false)"}, {"n", "<Plug>Lightspeed_F", "ft:to(true, false)"}, {"n", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"n", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"x", "<Plug>Lightspeed_f", "ft:to(false, false)"}, {"x", "<Plug>Lightspeed_F", "ft:to(true, false)"}, {"x", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"x", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"o", "<Plug>Lightspeed_f", "ft:to(false, false)"}, {"o", "<Plug>Lightspeed_F", "ft:to(true, false)"}, {"o", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"o", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"o", "<Plug>Lightspeed_repeat_f", "ft:to(false, false, true)"}, {"o", "<Plug>Lightspeed_repeat_F", "ft:to(true, false, true)"}, {"o", "<Plug>Lightspeed_repeat_t", "ft:to(false, true, true)"}, {"o", "<Plug>Lightspeed_repeat_T", "ft:to(true, true, true)"}}
for _, _306_ in ipairs(plug_mappings) do
  local _each_307_ = _306_
  local mode = _each_307_[1]
  local lhs = _each_307_[2]
  local rhs_call = _each_307_[3]
  api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
end
local function add_default_mappings()
  local default_mappings = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _308_ in ipairs(default_mappings) do
    local _each_309_ = _308_
    local mode = _each_309_[1]
    local lhs = _each_309_[2]
    local rhs = _each_309_[3]
    if ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0)) then
      api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
    end
  end
  return nil
end
add_default_mappings()
return {add_default_mappings = add_default_mappings, ft = ft, init_highlight = init_highlight, opts = opts, s = s, setup = setup}
