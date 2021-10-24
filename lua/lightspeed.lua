local api = vim.api
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local min = math.min
local max = math.max
local floor = math.floor
local function inc(x)
  return (x + 1)
end
local function dec(x)
  return (x - 1)
end
local function clamp(val, min0, max0)
  if (val < min0) then
    return min0
  elseif (val > max0) then
    return max0
  elseif "else" then
    return val
  end
end
local function last(tbl)
  return tbl[#tbl]
end
local function replace_keycodes(s)
  return api.nvim_replace_termcodes(s, true, false, true)
end
local function echo(msg)
  vim.cmd("redraw")
  return api.nvim_echo({{msg}}, false, {})
end
local function operator_pending_mode_3f()
  return string.match(api.nvim_get_mode().mode, "o")
end
local function is_current_operation_3f(op_ch)
  return (operator_pending_mode_3f() and (vim.v.operator == op_ch))
end
local function change_operation_3f()
  return is_current_operation_3f("c")
end
local function delete_operation_3f()
  return is_current_operation_3f("d")
end
local function dot_repeatable_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator ~= "y"))
end
local function get_cursor_pos()
  return {vim.fn.line("."), vim.fn.col(".")}
end
local function getchar_as_str()
  local ok_3f, ch = pcall(vim.fn.getchar)
  local function _2_()
    if (type(ch) == "number") then
      return vim.fn.nr2char(ch)
    else
      return ch
    end
  end
  return ok_3f, _2_()
end
local function char_at_pos(_3_, _5_)
  local _arg_4_ = _3_
  local line = _arg_4_[1]
  local byte_col = _arg_4_[2]
  local _arg_6_ = _5_
  local char_offset = _arg_6_["char-offset"]
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
local opts = {cycle_group_bwd_key = nil, cycle_group_fwd_key = nil, grey_out_search_area = true, highlight_unique_chars = true, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, jump_to_first_match = true, labels = nil, limit_ft_matches = 5, match_only_the_start_of_same_char_seqs = true, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local hl
local function _8_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _9_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _10_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _8_, ["set-extmark"] = _9_, cleanup = _10_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _12_
  do
    local _11_ = bg
    if (_11_ == "light") then
      _12_ = "#f02077"
    else
      local _ = _11_
      _12_ = "#ff2f87"
    end
  end
  local _17_
  do
    local _16_ = bg
    if (_16_ == "light") then
      _17_ = "#ff4090"
    else
      local _ = _16_
      _17_ = "#e01067"
    end
  end
  local _22_
  do
    local _21_ = bg
    if (_21_ == "light") then
      _22_ = "Blue"
    else
      local _ = _21_
      _22_ = "Cyan"
    end
  end
  local _27_
  do
    local _26_ = bg
    if (_26_ == "light") then
      _27_ = "#399d9f"
    else
      local _ = _26_
      _27_ = "#99ddff"
    end
  end
  local _32_
  do
    local _31_ = bg
    if (_31_ == "light") then
      _32_ = "Cyan"
    else
      local _ = _31_
      _32_ = "Blue"
    end
  end
  local _37_
  do
    local _36_ = bg
    if (_36_ == "light") then
      _37_ = "#59bdbf"
    else
      local _ = _36_
      _37_ = "#79bddf"
    end
  end
  local _42_
  do
    local _41_ = bg
    if (_41_ == "light") then
      _42_ = "#cc9999"
    else
      local _ = _41_
      _42_ = "#b38080"
    end
  end
  local _47_
  do
    local _46_ = bg
    if (_46_ == "light") then
      _47_ = "Black"
    else
      local _ = _46_
      _47_ = "White"
    end
  end
  local _52_
  do
    local _51_ = bg
    if (_51_ == "light") then
      _52_ = "#272020"
    else
      local _ = _51_
      _52_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _12_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _17_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _22_, gui = "bold,underline", guibg = "NONE", guifg = _27_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _32_, gui = "underline", guifg = _37_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _42_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _47_, gui = "bold", guibg = "NONE", guifg = _52_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _56_ in ipairs(groupdefs) do
    local _each_57_ = _56_
    local group = _each_57_[1]
    local attrs = _each_57_[2]
    local attrs_str
    local _58_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _58_ = tbl_12_auto
    end
    attrs_str = table.concat(_58_, " ")
    local _59_
    if force_3f then
      _59_ = ""
    else
      _59_ = "default "
    end
    vim.cmd(("highlight " .. _59_ .. group .. " " .. attrs_str))
  end
  for _, _61_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_62_ = _61_
    local from_group = _each_62_[1]
    local to_group = _each_62_[2]
    local _63_
    if force_3f then
      _63_ = ""
    else
      _63_ = "default "
    end
    vim.cmd(("highlight " .. _63_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_65_ = map(dec, get_cursor_pos())
  local curline = _let_65_[1]
  local curcol = _let_65_[2]
  local _let_66_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_66_[1]
  local win_bot = _let_66_[2]
  local function _68_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_67_ = _68_()
  local start = _let_67_[1]
  local finish = _let_67_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _69_, _71_, _73_)
  local _arg_70_ = _69_
  local startline = _arg_70_[1]
  local startcol = _arg_70_[2]
  local start = _arg_70_
  local _arg_72_ = _71_
  local endline = _arg_72_[1]
  local endcol = _arg_72_[2]
  local _end = _arg_72_
  local _arg_74_ = _73_
  local forced_motion = _arg_74_["forced-motion"]
  local inclusive_motion_3f = _arg_74_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _75_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _75_
  local _76_ = forced_motion
  if (_76_ == ctrl_v) then
    local _let_77_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_77_[1]
    local endcol0 = _let_77_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_76_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_76_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _76_
    return hl_range(start, _end, inclusive_motion_3f)
  end
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local function _80_()
    local _79_ = direction
    if (_79_ == "fwd") then
      return "W"
    elseif (_79_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _80_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_horizontal_bounds()
  local non_editable_width = dec(leftmost_editable_wincol())
  local col_in_edit_area = (vim.fn.wincol() - non_editable_width)
  local left_bound = (vim.fn.col(".") - dec(col_in_edit_area))
  local window_width = api.nvim_win_get_width(0)
  local right_bound = (left_bound + dec((window_width - non_editable_width - 1)))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _82_)
  local _arg_83_ = _82_
  local ft_search_3f = _arg_83_["ft-search?"]
  local limit = _arg_83_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _85_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_85_())
  local cleanup
  local function _86_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _86_
  local _let_87_ = get_horizontal_bounds()
  local left_bound = _let_87_[1]
  local right_bound = _let_87_[2]
  local function skip_to_fold_edge_21()
    local _88_
    local _89_
    if reverse_3f then
      _89_ = vim.fn.foldclosed
    else
      _89_ = vim.fn.foldclosedend
    end
    _88_ = _89_(vim.fn.line("."))
    if (_88_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _88_) then
      local fold_edge = _88_
      vim.fn.cursor(fold_edge, 0)
      local function _91_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _91_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_93_ = get_cursor_pos()
    local line = _local_93_[1]
    local col = _local_93_[2]
    local from_pos = _local_93_
    local _94_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _94_ = {dec(line), right_bound}
        else
        _94_ = nil
        end
      else
        _94_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _94_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _94_ = {inc(line), left_bound}
        else
        _94_ = nil
        end
      end
    else
    _94_ = nil
    end
    if (nil ~= _94_) then
      local to_pos = _94_
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
      local _102_
      local _103_
      if match_at_curpos_3f then
        _103_ = "c"
      else
        _103_ = ""
      end
      _102_ = vim.fn.searchpos(pattern, (opts0 .. _103_), stopline)
      if ((type(_102_) == "table") and ((_102_)[1] == 0) and true) then
        local _ = (_102_)[2]
        return cleanup()
      elseif ((type(_102_) == "table") and (nil ~= (_102_)[1]) and (nil ~= (_102_)[2])) then
        local line = (_102_)[1]
        local col = (_102_)[2]
        local pos = _102_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _105_ = skip_to_fold_edge_21()
          if (_105_ == "moved-the-cursor") then
            return rec(false)
          elseif (_105_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_106_,_107_,_108_) return (_106_ <= _107_) and (_107_ <= _108_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _109_ = skip_to_next_in_window_pos_21()
              if (_109_ == "moved-the-cursor") then
                return rec(true)
              else
                local _ = _109_
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
local function highlight_cursor(_3fpos)
  local _let_116_ = (_3fpos or get_cursor_pos())
  local line = _let_116_[1]
  local col = _let_116_[2]
  local pos = _let_116_
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
  return api.nvim_feedkeys(replace_keycodes(("<C-\\><C-G>" .. _3fright)), "n", true)
end
local function doau_when_exists(event)
  if vim.fn.exists(("#User#" .. event)) then
    return vim.cmd(("doautocmd <nomodeline> User " .. event))
  end
end
local function enter(mode)
  doau_when_exists("LightspeedEnter")
  local _119_ = mode
  if (_119_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  elseif (_119_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  end
end
local function get_input_and_clean_up()
  local ok_3f, res = getchar_as_str()
  hl:cleanup()
  if (ok_3f and (res ~= replace_keycodes("<esc>"))) then
    return res
  end
end
local function set_dot_repeat(cmd, _3fcount)
  if operator_pending_mode_3f() then
    local op = vim.v.operator
    if (op ~= "y") then
      local change
      if (op == "c") then
        change = replace_keycodes("<c-r>.<esc>")
      else
      change = nil
      end
      local seq = (op .. (_3fcount or "") .. cmd .. (change or ""))
      pcall(vim.fn["repeat#setreg"], seq, vim.v.register)
      return pcall(vim.fn["repeat#set"], seq, -1)
    end
  end
end
local function get_plug_key(kind, reverse_3f, x_or_t_3f, repeat_invoc)
  local _126_
  do
    local _125_ = repeat_invoc
    if (_125_ == "dot") then
      _126_ = "dotrepeat_"
    else
      local _ = _125_
      _126_ = ""
    end
  end
  local _131_
  do
    local _130_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_130_) == "table") and ((_130_)[1] == "ft") and ((_130_)[2] == false) and ((_130_)[3] == false)) then
      _131_ = "f"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "ft") and ((_130_)[2] == true) and ((_130_)[3] == false)) then
      _131_ = "F"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "ft") and ((_130_)[2] == false) and ((_130_)[3] == true)) then
      _131_ = "t"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "ft") and ((_130_)[2] == true) and ((_130_)[3] == true)) then
      _131_ = "T"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "sx") and ((_130_)[2] == false) and ((_130_)[3] == false)) then
      _131_ = "s"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "sx") and ((_130_)[2] == false) and ((_130_)[3] == true)) then
      _131_ = "S"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "sx") and ((_130_)[2] == true) and ((_130_)[3] == false)) then
      _131_ = "x"
    elseif ((type(_130_) == "table") and ((_130_)[1] == "sx") and ((_130_)[2] == true) and ((_130_)[3] == true)) then
      _131_ = "X"
    else
    _131_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _126_ .. _131_)
end
local ft = {state = {cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}, dot = {["in"] = nil}, instant = {["in"] = nil, stack = nil}}}
ft.go = function(self, reverse_3f, t_mode_3f, repeat_invoc)
  local instant_repeat_3f = ((repeat_invoc == "instant") or (repeat_invoc == "reverted-instant"))
  local reverted_instant_repeat_3f = (repeat_invoc == "reverted-instant")
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local count
  if reverted_instant_repeat_3f then
    count = 0
  else
    count = vim.v.count1
  end
  local _let_142_ = map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_142_[1]
  local revert_key = _let_142_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("ft", reverse_3f, t_mode_3f, "dot"))
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _145_
  if instant_repeat_3f then
    _145_ = self.state.instant["in"]
  elseif dot_repeat_3f then
    _145_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _145_ = self.state.cold["in"]
  else
    local _146_
    local function _147_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _146_ = (get_input_and_clean_up() or _147_())
    if (_146_ == "\13") then
      local function _149_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_no_prev_search()
        end
        doau_when_exists("LightspeedFtLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _145_ = (self.state.cold["in"] or _149_())
    elseif (nil ~= _146_) then
      local in0 = _146_
      _145_ = in0
    else
    _145_ = nil
    end
  end
  if (nil ~= _145_) then
    local in1 = _145_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f, ["t-mode?"] = t_mode_3f}
    end
    local function _155_()
      if reverse_3f then
        return "nWb"
      else
        return "nW"
      end
    end
    local _local_154_ = vim.fn.searchpos("\\_.", _155_())
    local next_line = _local_154_[1]
    local next_col = _local_154_[2]
    local match_pos = nil
    local i = 0
    local function _158_()
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit
      if opts.limit_ft_matches then
        limit = (count + opts.limit_ft_matches)
      else
      limit = nil
      end
      return onscreen_match_positions(pattern, reverse_3f, {["ft-search?"] = true, limit = limit})
    end
    for _156_ in _158_() do
      local _each_159_ = _156_
      local line = _each_159_[1]
      local col = _each_159_[2]
      local pos = _each_159_
      if not (repeat_invoc and t_mode_3f and (i == 0) and (line == next_line) and (col == next_col)) then
        i = (i + 1)
        if (i <= count) then
          match_pos = pos
        else
          if not op_mode_3f then
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
          end
        end
      end
    end
    if ((count > 0) and not match_pos) then
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        echo_not_found(in1)
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    else
      if not reverted_instant_repeat_3f then
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if not instant_repeat_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(match_pos)
        if t_mode_3f then
          local function _165_()
            if reverse_3f then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_165_())
        end
        if (op_mode_3f_4_auto and not reverse_3f and true) then
          local _167_ = string.sub(vim.fn.mode("t"), -1)
          if (_167_ == "v") then
            push_cursor_21("bwd")
          elseif (_167_ == "o") then
            if not cursor_before_eof_3f() then
              push_cursor_21("fwd")
            else
              vim.cmd("set virtualedit=onemore")
              vim.cmd("norm! l")
              vim.cmd(restore_virtualedit_autocmd_5_auto)
            end
          end
        end
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        end
      end
      if op_mode_3f then
        do
          if dot_repeatable_op_3f then
            self.state.dot = {["in"] = in1}
            set_dot_repeat(cmd_for_dot_repeat, count)
          end
        end
        doau_when_exists("LightspeedFtLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      else
        highlight_cursor()
        vim.cmd("redraw")
        local _174_
        local function _175_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _174_ = (get_input_and_clean_up() or _175_())
        if (nil ~= _174_) then
          local in2 = _174_
          local mode
          if (vim.fn.mode() == "n") then
            mode = "n"
          else
            mode = "x"
          end
          local repeat_3f = ((in2 == repeat_key) or string.match(vim.fn.maparg(in2, mode), get_plug_key("ft", false, t_mode_3f)))
          local revert_3f = ((in2 == revert_key) or string.match(vim.fn.maparg(in2, mode), get_plug_key("ft", true, t_mode_3f)))
          local do_instant_repeat_3f = (repeat_3f or revert_3f)
          if do_instant_repeat_3f then
            if not instant_repeat_3f then
              self.state.instant = {["in"] = in1, stack = {}}
            end
            if revert_3f then
              local _178_ = table.remove(self.state.instant.stack)
              if (nil ~= _178_) then
                local old_pos = _178_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(self.state.instant.stack, get_cursor_pos())
            end
            local function _181_()
              if revert_3f then
                return "reverted-instant"
              else
                return "instant"
              end
            end
            return ft:go(reverse_3f, t_mode_3f, _181_())
          else
            do
              vim.fn.feedkeys(in2, "i")
            end
            doau_when_exists("LightspeedFtLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
        end
      end
    end
  end
end
do
  local deprec_msg = {{"ligthspeed.nvim", "Question"}, {": You're trying to access deprecated fields in the lightspeed.ft table.\n"}, {"There are dedicated <Plug> keys available for native-like "}, {";", "Visual"}, {" and "}, {",", "Visual"}, {" functionality now.\n"}, {"See "}, {":h lightspeed-custom-mappings", "Visual"}, {"."}}
  local function _187_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _187_})
end
local function get_labels()
  local function _189_()
    if opts.jump_to_first_match then
      return {"f", "s", "n", "u", "t", "/", "q", "F", "S", "G", "H", "L", "M", "N", "U", "R", "T", "Z", "?", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "a", ";", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "z", "."}
    end
  end
  return (opts.labels or _189_())
end
local function get_cycle_keys()
  local function _190_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _191_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return map(replace_keycodes, {(opts.cycle_group_fwd_key or _190_()), (opts.cycle_group_bwd_key or _191_())})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_192_ = get_horizontal_bounds()
  local left_bound = _let_192_[1]
  local right_bound = _let_192_[2]
  local _let_193_ = get_cursor_pos()
  local curline = _let_193_[1]
  local curcol = _let_193_[2]
  local top
  if reverse_3f then
    top = vim.fn.line("w0")
  else
    top = curline
  end
  local bot
  if reverse_3f then
    bot = curline
  else
    bot = vim.fn.line("w$")
  end
  local lines = api.nvim_buf_get_lines(0, dec(top), bot, true)
  for i, line in ipairs(lines) do
    local line_offset = dec(i)
    local on_curline_3f = (line_offset == (curline - top))
    local startcol
    if (on_curline_3f and not reverse_3f) then
      startcol = inc(curcol)
    else
      startcol = 1
    end
    local endcol
    if (on_curline_3f and reverse_3f) then
      endcol = dec(curcol)
    else
      endcol = #line
    end
    for col = startcol, endcol do
      if (vim.wo.wrap or ((col >= left_bound) and (col <= right_bound))) then
        local ch = line:sub(col, col)
        local pos = {(top + line_offset), col}
        local _199_
        do
          local _198_ = unique_chars[ch]
          if (nil ~= _198_) then
            local pos_already_there = _198_
            _199_ = false
          else
            local _ = _198_
            _199_ = pos
          end
        end
        unique_chars[ch] = _199_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _204_ = pos
    if ((type(_204_) == "table") and (nil ~= (_204_)[1]) and (nil ~= (_204_)[2])) then
      local line = (_204_)[1]
      local col = (_204_)[2]
      hl["add-hl"](hl, hl.group["unique-ch"], dec(line), dec(col), col)
    end
  end
  return nil
end
local function get_targets(ch1, reverse_3f)
  local targets = {}
  local prev_match = {}
  local added_prev_match_3f = nil
  local pattern = ("\\V\\C" .. ch1:gsub("\\", "\\\\") .. "\\_.")
  for _206_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_207_ = _206_
    local line = _each_207_[1]
    local col = _each_207_[2]
    local pos = _each_207_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local overlaps_prev_match_3f
    local _208_
    if reverse_3f then
      _208_ = dec
    else
      _208_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _208_(prev_match.col)))
    local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
    local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
    prev_match = {ch2 = ch2, col = col, line = line}
    if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
      added_prev_match_3f = false
    else
      local target = {pair = {ch1, ch2}, pos = pos}
      if overlaps_prev_target_3f then
        local _210_
        if reverse_3f then
          _210_ = last(targets)
        else
          _210_ = target
        end
        _210_["overlapped?"] = true
      end
      table.insert(targets, target)
      added_prev_match_3f = true
    end
  end
  if next(targets) then
    return targets
  end
end
local function populate_sublists(targets)
  targets["sublists"] = {}
  for _, _215_ in ipairs(targets) do
    local _each_216_ = _215_
    local target = _each_216_
    local _each_217_ = _each_216_["pair"]
    local _0 = _each_217_[1]
    local ch2 = _each_217_[2]
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function set_labels(targets, jump_to_first_3f)
  local labels = get_labels()
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      for i, target in ipairs(sublist) do
        local _219_
        if not (jump_to_first_3f and (i == 1)) then
          local _220_
          local _222_
          if jump_to_first_3f then
            _222_ = dec(i)
          else
            _222_ = i
          end
          _220_ = (_222_ % #labels)
          if (_220_ == 0) then
            _219_ = last(labels)
          elseif (nil ~= _220_) then
            local n = _220_
            _219_ = labels[n]
          else
          _219_ = nil
          end
        else
        _219_ = nil
        end
        target["label"] = _219_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(target_list, _229_)
  local _arg_230_ = _229_
  local group_offset = _arg_230_["group-offset"]
  local jump_to_first_3f = _arg_230_["jump-to-first?"]
  local labels = get_labels()
  local _7clabels_7c = #labels
  local base
  if jump_to_first_3f then
    base = 2
  else
    base = 1
  end
  local offset = (group_offset * _7clabels_7c)
  local primary_start = (base + offset)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(target_list) do
    local _232_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _232_ = "inactive"
      elseif (i <= primary_end) then
        _232_ = "active-primary"
      else
        _232_ = "active-secondary"
      end
    else
    _232_ = nil
    end
    target["label-state"] = _232_
  end
  return nil
end
local function set_label_states(targets, jump_to_first_3f)
  for _, sublist in pairs(targets.sublists) do
    set_label_states_for_sublist(sublist, {["group-offset"] = 0, ["jump-to-first?"] = jump_to_first_3f})
  end
  return nil
end
local function set_shortcuts_and_populate_shortcuts_map(targets)
  targets["shortcuts"] = {}
  local potential_2nd_inputs
  do
    local tbl_9_auto = {}
    for ch2, _ in pairs(targets.sublists) do
      local _235_, _236_ = ch2, true
      if ((nil ~= _235_) and (nil ~= _236_)) then
        local k_10_auto = _235_
        local v_11_auto = _236_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _238_ in ipairs(targets) do
    local _each_239_ = _238_
    local target = _each_239_
    local label = _each_239_["label"]
    local label_state = _each_239_["label-state"]
    if (label_state == "active-primary") then
      if not ((potential_2nd_inputs)[label] or labels_used_up_as_shortcut[label]) then
        target["shortcut?"] = true
        targets.shortcuts[label] = target
        labels_used_up_as_shortcut[label] = true
      end
    end
  end
  return nil
end
local function set_beacon(_242_, repeat_3f)
  local _arg_243_ = _242_
  local target = _arg_243_
  local label = _arg_243_["label"]
  local label_state = _arg_243_["label-state"]
  local overlapped_3f = _arg_243_["overlapped?"]
  local _arg_244_ = _arg_243_["pair"]
  local ch1 = _arg_244_[1]
  local ch2 = _arg_244_[2]
  local _arg_245_ = _arg_243_["pos"]
  local _ = _arg_245_[1]
  local col = _arg_245_[2]
  local shortcut_3f = _arg_243_["shortcut?"]
  local function _247_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_246_ = map(_247_, {ch1, ch2})
  local ch10 = _let_246_[1]
  local ch20 = _let_246_[2]
  local function _249_(_241)
    return (not repeat_3f and _241)
  end
  local _let_248_ = map(_249_, {overlapped_3f, shortcut_3f})
  local overlapped_3f0 = _let_248_[1]
  local shortcut_3f0 = _let_248_[2]
  local unlabeled_hl = hl.group["unlabeled-match"]
  local function _253_()
    if shortcut_3f0 then
      return {hl.group.shortcut, hl.group["shortcut-overlapped"]}
    else
      local _251_ = label_state
      if (_251_ == "active-secondary") then
        return {hl.group["label-distant"], hl.group["label-distant-overlapped"]}
      elseif (_251_ == "active-primary") then
        return {hl.group.label, hl.group["label-overlapped"]}
      else
        local _0 = _251_
        return {nil, nil}
      end
    end
  end
  local _let_250_ = _253_()
  local label_hl = _let_250_[1]
  local overlapped_label_hl = _let_250_[2]
  local _254_
  if not label then
    if overlapped_3f0 then
      _254_ = {inc(col), {ch20, unlabeled_hl}}
    else
      _254_ = {col, {ch10, unlabeled_hl}, {ch20, unlabeled_hl}}
    end
  elseif (label_state == "inactive") then
    _254_ = nil
  elseif overlapped_3f0 then
    _254_ = {inc(col), {label, overlapped_label_hl}}
  elseif repeat_3f then
    _254_ = {inc(col), {label, label_hl}}
  else
    _254_ = {col, {ch20, hl.group["masked-ch"]}, {label, label_hl}}
  end
  target["beacon"] = _254_
  return nil
end
local function set_beacons(target_list, _257_)
  local _arg_258_ = _257_
  local repeat_3f = _arg_258_["repeat?"]
  for _, target in ipairs(target_list) do
    set_beacon(target, repeat_3f)
  end
  return nil
end
local function light_up_beacons(target_list)
  for _, _259_ in ipairs(target_list) do
    local _each_260_ = _259_
    local beacon = _each_260_["beacon"]
    local _each_261_ = _each_260_["pos"]
    local line = _each_261_[1]
    local _0 = _each_261_[2]
    local _262_ = beacon
    if ((type(_262_) == "table") and (nil ~= (_262_)[1]) and (nil ~= (_262_)[2]) and true) then
      local startcol = (_262_)[1]
      local chunk1 = (_262_)[2]
      local _3fchunk2 = (_262_)[3]
      hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _264_ in ipairs(target_list) do
    local _each_265_ = _264_
    local target = _each_265_
    local label = _each_265_["label"]
    local label_state = _each_265_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_char_until_timeout(char_to_ignore)
  local start = os.clock()
  local timeout_secs = (opts.jump_on_partial_input_safety_timeout / 1000)
  local ok_3f, input = getchar_as_str()
  if not ((input == char_to_ignore) and (os.clock() < (start + timeout_secs))) then
    if ok_3f then
      return vim.fn.feedkeys(input, "i")
    end
  end
end
local sx = {state = {cold = {["reverse?"] = nil, ["x-mode?"] = nil, in1 = nil, in2 = nil}, dot = {["x-mode?"] = nil, in1 = nil, in2 = nil, in3 = nil}}}
sx.go = function(self, reverse_3f, invoked_in_x_mode_3f, repeat_invoc)
  local dot_repeat_3f = (repeat_invoc == "dot")
  local cold_repeat_3f = (repeat_invoc == "cold")
  local op_mode_3f = operator_pending_mode_3f()
  local change_op_3f = change_operation_3f()
  local delete_op_3f = delete_operation_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
  local _let_269_ = get_cycle_keys()
  local cycle_fwd_key = _let_269_[1]
  local cycle_bwd_key = _let_269_[2]
  local labels = get_labels()
  local jump_to_first_3f = (opts.jump_to_first_match and not op_mode_3f)
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("sx", reverse_3f, invoked_in_x_mode_3f, "dot"))
  local x_mode_3f = invoked_in_x_mode_3f
  local enter_repeat_3f = nil
  local new_search_3f = nil
  local function get_first_input()
    if dot_repeat_3f then
      x_mode_3f = self.state.dot["x-mode?"]
      return self.state.dot.in1
    elseif cold_repeat_3f then
      return self.state.cold.in1
    else
      local _270_
      local function _271_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _270_ = (get_input_and_clean_up() or _271_())
      if (nil ~= _270_) then
        local in0 = _270_
        do
          local _273_ = in0
          if (_273_ == "\13") then
            enter_repeat_3f = true
          elseif (_273_ == x_mode_prefix_key) then
            x_mode_3f = true
          end
        end
        local res = in0
        if (x_mode_3f and not invoked_in_x_mode_3f) then
          local _275_
          local function _276_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _275_ = (get_input_and_clean_up() or _276_())
          if (_275_ == "\13") then
            enter_repeat_3f = true
          elseif (nil ~= _275_) then
            local in0_2a = _275_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or enter_repeat_3f)
        if enter_repeat_3f then
          local function _280_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
              echo_no_prev_search()
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          return (self.state.cold.in1 or _280_())
        else
          return res
        end
      end
    end
  end
  local function save_state_for_repeat_2a(in1)
    local function _287_(_285_)
      local _arg_286_ = _285_
      local cold = _arg_286_["cold"]
      local dot = _arg_286_["dot"]
      if new_search_3f then
        if cold then
          local _288_ = cold
          _288_["in1"] = in1
          _288_["x-mode?"] = x_mode_3f
          _288_["reverse?"] = reverse_3f
          self.state.cold = _288_
        end
        if (dot_repeatable_op_3f and dot) then
          do
            local _290_ = dot
            _290_["in1"] = in1
            _290_["x-mode?"] = x_mode_3f
            self.state.dot = _290_
          end
          return nil
        end
      end
    end
    return _287_
  end
  local jump_wrapped_21
  do
    local first_jump_3f = true
    local function _293_(target)
      do
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if first_jump_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target)
        if x_mode_3f then
          push_cursor_21("fwd")
          if reverse_3f then
            push_cursor_21("fwd")
          end
        end
        if (op_mode_3f_4_auto and not reverse_3f and (x_mode_3f and not reverse_3f)) then
          local _297_ = string.sub(vim.fn.mode("t"), -1)
          if (_297_ == "v") then
            push_cursor_21("bwd")
          elseif (_297_ == "o") then
            if not cursor_before_eof_3f() then
              push_cursor_21("fwd")
            else
              vim.cmd("set virtualedit=onemore")
              vim.cmd("norm! l")
              vim.cmd(restore_virtualedit_autocmd_5_auto)
            end
          end
        end
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        end
      end
      if dot_repeatable_op_3f then
        set_dot_repeat(cmd_for_dot_repeat)
      end
      first_jump_3f = false
      return nil
    end
    jump_wrapped_21 = _293_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_303_, ch2)
    local _arg_304_ = _303_
    local target_line = _arg_304_[1]
    local target_col = _arg_304_[2]
    local from_pos = map(dec, get_cursor_pos())
    jump_wrapped_21({target_line, target_col})
    if new_search_3f then
      local ctrl_v = replace_keycodes("<c-v>")
      local forward_x_3f = (x_mode_3f and not reverse_3f)
      local backward_x_3f = (x_mode_3f and reverse_3f)
      local forced_motion = string.sub(vim.fn.mode("t"), -1)
      local to_col
      if backward_x_3f then
        to_col = inc(inc(target_col))
      elseif forward_x_3f then
        to_col = inc(target_col)
      else
        to_col = target_col
      end
      local to_pos = map(dec, {target_line, to_col})
      local function _307_()
        if reverse_3f then
          return to_pos
        else
          return from_pos
        end
      end
      local _let_306_ = _307_()
      local startline = _let_306_[1]
      local startcol = _let_306_[2]
      local start = _let_306_
      local function _309_()
        if reverse_3f then
          return from_pos
        else
          return to_pos
        end
      end
      local _let_308_ = _309_()
      local _ = _let_308_[1]
      local endcol = _let_308_[2]
      local _end = _let_308_
      local _3fhighlight_cursor_at
      if op_mode_3f then
        local function _310_()
          if (forced_motion == ctrl_v) then
            return {startline, min(startcol, endcol)}
          elseif not reverse_3f then
            return from_pos
          end
        end
        _3fhighlight_cursor_at = map(inc, _310_())
      else
      _3fhighlight_cursor_at = nil
      end
      if not change_op_3f then
        highlight_cursor(_3fhighlight_cursor_at)
      end
      if op_mode_3f then
        highlight_range(hl.group["pending-op-area"], start, _end, {["forced-motion"] = forced_motion, ["inclusive-motion?"] = forward_x_3f})
      end
      vim.cmd("redraw")
      ignore_char_until_timeout(ch2)
      if change_op_3f then
        echo("")
      end
      return hl:cleanup()
    end
  end
  local function handle_cold_repeating_X(sublist)
    local _let_316_ = sublist
    local _let_317_ = _let_316_[1]
    local first = _let_317_
    local _let_318_ = _let_317_["pos"]
    local line = _let_318_[1]
    local col = _let_318_[2]
    local rest = {(table.unpack or unpack)(_let_316_, 2)}
    local cursor_right_before_first_target_3f
    do
      local _let_319_ = vim.fn.searchpos("\\_.", "nWb")
      local line_2a = _let_319_[1]
      local col_2a = _let_319_[2]
      do local _ = (line == line_2a) end
      cursor_right_before_first_target_3f = (col == dec(col_2a))
    end
    local skip_one_target_3f = (cold_repeat_3f and x_mode_3f and reverse_3f and cursor_right_before_first_target_3f)
    if skip_one_target_3f then
      local _let_320_ = rest
      local first_rest = _let_320_[1]
      local rest_rest = {(table.unpack or unpack)(_let_320_, 2)}
      return {first_rest, rest_rest, rest}
    else
      return {first, rest, sublist}
    end
  end
  local function after_cold_repeat(target_list)
    if not op_mode_3f then
      do
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f)
        end
        do
          for _, _323_ in ipairs(target_list) do
            local _each_324_ = _323_
            local _each_325_ = _each_324_["pos"]
            local line = _each_325_[1]
            local col = _each_325_[2]
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), inc(col))
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      do
        vim.fn.feedkeys((get_input_and_clean_up() or ""), "i")
      end
      doau_when_exists("LightspeedSxLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
  end
  local function select_match_group(target_list)
    local function rec(group_offset)
      set_beacons(target_list, {["repeat?"] = enter_repeat_3f})
      do
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f)
        end
        do
          light_up_beacons(target_list)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _328_ = get_input_and_clean_up()
      if (nil ~= _328_) then
        local input = _328_
        if ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          local _7cgroups_7c = floor((#target_list / #labels))
          local group_offset_2a
          local _330_
          do
            local _329_ = input
            if (_329_ == cycle_fwd_key) then
              _330_ = inc
            else
              local _ = _329_
              _330_ = dec
            end
          end
          group_offset_2a = clamp(_330_(group_offset), 0, _7cgroups_7c)
          set_label_states_for_sublist(target_list, {["group-offset"] = group_offset_2a, ["jump-to-first?"] = false})
          return rec(group_offset_2a)
        else
          return {input, group_offset}
        end
      end
    end
    return rec(0)
  end
  enter("sx")
  if not repeat_invoc then
    echo("")
    if (opts.grey_out_search_area and not cold_repeat_3f) then
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
  local _339_ = get_first_input()
  if (nil ~= _339_) then
    local in1 = _339_
    local save_state_for_repeat = save_state_for_repeat_2a(in1)
    local prev_in2
    if (cold_repeat_3f or enter_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
    prev_in2 = nil
    end
    local _341_
    local function _342_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        echo_not_found((in1 .. (prev_in2 or "")))
      end
      doau_when_exists("LightspeedSxLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _341_ = (get_targets(in1, reverse_3f) or _342_())
    if ((type(_341_) == "table") and ((type((_341_)[1]) == "table") and (nil ~= ((_341_)[1]).pos) and ((type(((_341_)[1]).pair) == "table") and true and (nil ~= (((_341_)[1]).pair)[2]))) and ((_341_)[2] == nil)) then
      local pos = ((_341_)[1]).pos
      local _ = (((_341_)[1]).pair)[1]
      local ch2 = (((_341_)[1]).pair)[2]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          save_state_for_repeat({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = labels[1]}})
          jump_and_ignore_ch2_until_timeout_21(pos, ch2)
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      else
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_not_found((in1 .. prev_in2))
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
    elseif (nil ~= _341_) then
      local targets = _341_
      do
        local _346_ = targets
        populate_sublists(_346_)
        set_labels(_346_, jump_to_first_3f)
        set_label_states(_346_, jump_to_first_3f)
      end
      if new_search_3f then
        do
          local _347_ = targets
          set_shortcuts_and_populate_shortcuts_map(_347_)
          set_beacons(_347_, {["repeat?"] = false})
        end
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f)
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _350_
      local function _351_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _350_ = (prev_in2 or get_input_and_clean_up() or _351_())
      if (nil ~= _350_) then
        local in2 = _350_
        local _353_
        if new_search_3f then
          _353_ = targets.shortcuts[in2]
        else
        _353_ = nil
        end
        if ((type(_353_) == "table") and (nil ~= (_353_).pos) and ((type((_353_).pair) == "table") and true and (nil ~= ((_353_).pair)[2]))) then
          local pos = (_353_).pos
          local _ = ((_353_).pair)[1]
          local ch2 = ((_353_).pair)[2]
          do
            save_state_for_repeat({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_wrapped_21(pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _353_
          save_state_for_repeat({cold = {in2 = in2}, dot = {in2 = in2, in3 = labels[1]}})
          local _355_
          local function _356_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
              echo_not_found((in1 .. in2))
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _355_ = (targets.sublists[in2] or _356_())
          if (nil ~= _355_) then
            local sublist = _355_
            local _let_358_ = handle_cold_repeating_X(sublist)
            local first = _let_358_[1]
            local rest = _let_358_[2]
            local sublist0 = _let_358_[3]
            local target_list
            if jump_to_first_3f then
              target_list = rest
            else
              target_list = sublist0
            end
            if (first and (empty_3f(rest) or cold_repeat_3f or jump_to_first_3f)) then
              jump_wrapped_21(first.pos)
            end
            if empty_3f(rest) then
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            elseif cold_repeat_3f then
              return after_cold_repeat(rest)
            else
              local _361_
              local function _362_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
              _361_ = ((dot_repeat_3f and self.state.dot.in3 and {self.state.dot.in3}) or select_match_group(target_list) or _362_())
              if ((type(_361_) == "table") and (nil ~= (_361_)[1]) and true) then
                local in3 = (_361_)[1]
                local _3fgroup_offset = (_361_)[2]
                if (not dot_repeat_3f and dot_repeatable_op_3f) then
                  if (_3fgroup_offset > 0) then
                    self.state.dot.in3 = nil
                  else
                    self.state.dot.in3 = in3
                  end
                end
                local _366_ = get_target_with_active_primary_label(target_list, in3)
                if ((type(_366_) == "table") and (nil ~= (_366_).pos)) then
                  local pos = (_366_).pos
                  do
                    jump_wrapped_21(pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _0 = _366_
                  if jump_to_first_3f then
                    do
                      vim.fn.feedkeys(in3, "i")
                    end
                    doau_when_exists("LightspeedSxLeave")
                    doau_when_exists("LightspeedLeave")
                    return nil
                  else
                    if change_operation_3f() then
                      handle_interrupted_change_op_21()
                    end
                    do
                    end
                    doau_when_exists("LightspeedSxLeave")
                    doau_when_exists("LightspeedLeave")
                    return nil
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
local temporary_editor_opts = {["vim.wo.conceallevel"] = 0, ["vim.wo.scrolloff"] = 0}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_377_ = vim.split(opt, ".", true)
    local _0 = _let_377_[1]
    local scope = _let_377_[2]
    local name = _let_377_[3]
    local _378_
    if (opt == "vim.wo.scrolloff") then
      _378_ = api.nvim_eval("&l:scrolloff")
    else
      _378_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _378_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_380_ = vim.split(opt, ".", true)
    local _ = _let_380_[1]
    local scope = _let_380_[2]
    local name = _let_380_[3]
    _G.vim[scope][name] = val
  end
  return nil
end
local function set_temporary_editor_opts()
  return set_editor_opts(temporary_editor_opts)
end
local function restore_editor_opts()
  return set_editor_opts(saved_editor_opts)
end
local function set_plug_keys()
  local plug_keys = {{"<Plug>Lightspeed_s", "sx:go(false)"}, {"<Plug>Lightspeed_S", "sx:go(true)"}, {"<Plug>Lightspeed_x", "sx:go(false, true)"}, {"<Plug>Lightspeed_X", "sx:go(true, true)"}, {"<Plug>Lightspeed_f", "ft:go(false)"}, {"<Plug>Lightspeed_F", "ft:go(true)"}, {"<Plug>Lightspeed_t", "ft:go(false, true)"}, {"<Plug>Lightspeed_T", "ft:go(true, true)"}, {"<Plug>Lightspeed_;_sx", "sx:go(require'lightspeed'.sx.state.cold['reverse?'], require'lightspeed'.sx.state.cold['x-mode?'], 'cold')"}, {"<Plug>Lightspeed_,_sx", "sx:go(not require'lightspeed'.sx.state.cold['reverse?'], require'lightspeed'.sx.state.cold['x-mode?'], 'cold')"}, {"<Plug>Lightspeed_;_ft", "ft:go(require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}, {"<Plug>Lightspeed_,_ft", "ft:go(not require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}, {"<Plug>Lightspeed_;", "ft:go(require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}, {"<Plug>Lightspeed_,", "ft:go(not require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}}
  for _, _381_ in ipairs(plug_keys) do
    local _each_382_ = _381_
    local lhs = _each_382_[1]
    local rhs_call = _each_382_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _383_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_384_ = _383_
    local lhs = _each_384_[1]
    local rhs_call = _each_384_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _385_ in ipairs(default_keymaps) do
    local _each_386_ = _385_
    local mode = _each_386_[1]
    local lhs = _each_386_[2]
    local rhs = _each_386_[3]
    if ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0)) then
      api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
    end
  end
  return nil
end
init_highlight()
set_plug_keys()
set_default_keymaps()
vim.cmd("augroup lightspeed_reinit_highlight\n   autocmd!\n   autocmd ColorScheme * lua require'lightspeed'.init_highlight()\n   augroup end")
vim.cmd("augroup lightspeed_editor_opts\n   autocmd!\n   autocmd User LightspeedEnter lua require'lightspeed'.save_editor_opts(); require'lightspeed'.set_temporary_editor_opts()\n   autocmd User LightspeedLeave lua require'lightspeed'.restore_editor_opts()\n   augroup end")
return {ft = ft, init_highlight = init_highlight, opts = opts, restore_editor_opts = restore_editor_opts, save_editor_opts = save_editor_opts, set_default_keymaps = set_default_keymaps, set_temporary_editor_opts = set_temporary_editor_opts, setup = setup, sx = sx}
