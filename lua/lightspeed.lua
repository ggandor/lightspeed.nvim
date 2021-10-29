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
local function get_fold_edge(lnum, reverse_3f)
  local _8_
  local _9_
  if reverse_3f then
    _9_ = vim.fn.foldclosed
  else
    _9_ = vim.fn.foldclosedend
  end
  _8_ = _9_(lnum)
  if (_8_ == -1) then
    return nil
  elseif (nil ~= _8_) then
    local fold_edge = _8_
    return fold_edge
  end
end
local opts = {cycle_group_bwd_key = nil, cycle_group_fwd_key = nil, grey_out_search_area = true, highlight_unique_chars = true, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, jump_to_first_match = true, labels = nil, limit_ft_matches = 5, match_only_the_start_of_same_char_seqs = true, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local hl
local function _12_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _13_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _14_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _12_, ["set-extmark"] = _13_, cleanup = _14_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _16_
  do
    local _15_ = bg
    if (_15_ == "light") then
      _16_ = "#f02077"
    else
      local _ = _15_
      _16_ = "#ff2f87"
    end
  end
  local _21_
  do
    local _20_ = bg
    if (_20_ == "light") then
      _21_ = "#ff4090"
    else
      local _ = _20_
      _21_ = "#e01067"
    end
  end
  local _26_
  do
    local _25_ = bg
    if (_25_ == "light") then
      _26_ = "Blue"
    else
      local _ = _25_
      _26_ = "Cyan"
    end
  end
  local _31_
  do
    local _30_ = bg
    if (_30_ == "light") then
      _31_ = "#399d9f"
    else
      local _ = _30_
      _31_ = "#99ddff"
    end
  end
  local _36_
  do
    local _35_ = bg
    if (_35_ == "light") then
      _36_ = "Cyan"
    else
      local _ = _35_
      _36_ = "Blue"
    end
  end
  local _41_
  do
    local _40_ = bg
    if (_40_ == "light") then
      _41_ = "#59bdbf"
    else
      local _ = _40_
      _41_ = "#79bddf"
    end
  end
  local _46_
  do
    local _45_ = bg
    if (_45_ == "light") then
      _46_ = "#cc9999"
    else
      local _ = _45_
      _46_ = "#b38080"
    end
  end
  local _51_
  do
    local _50_ = bg
    if (_50_ == "light") then
      _51_ = "Black"
    else
      local _ = _50_
      _51_ = "White"
    end
  end
  local _56_
  do
    local _55_ = bg
    if (_55_ == "light") then
      _56_ = "#272020"
    else
      local _ = _55_
      _56_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _16_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _21_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _26_, gui = "bold,underline", guibg = "NONE", guifg = _31_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _36_, gui = "underline", guifg = _41_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _46_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _51_, gui = "bold", guibg = "NONE", guifg = _56_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _60_ in ipairs(groupdefs) do
    local _each_61_ = _60_
    local group = _each_61_[1]
    local attrs = _each_61_[2]
    local attrs_str
    local _62_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _62_ = tbl_12_auto
    end
    attrs_str = table.concat(_62_, " ")
    local _63_
    if force_3f then
      _63_ = ""
    else
      _63_ = "default "
    end
    vim.cmd(("highlight " .. _63_ .. group .. " " .. attrs_str))
  end
  for _, _65_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_66_ = _65_
    local from_group = _each_66_[1]
    local to_group = _each_66_[2]
    local _67_
    if force_3f then
      _67_ = ""
    else
      _67_ = "default "
    end
    vim.cmd(("highlight " .. _67_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_69_ = map(dec, get_cursor_pos())
  local curline = _let_69_[1]
  local curcol = _let_69_[2]
  local _let_70_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_70_[1]
  local win_bot = _let_70_[2]
  local function _72_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_71_ = _72_()
  local start = _let_71_[1]
  local finish = _let_71_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _73_, _75_, _77_)
  local _arg_74_ = _73_
  local startline = _arg_74_[1]
  local startcol = _arg_74_[2]
  local start = _arg_74_
  local _arg_76_ = _75_
  local endline = _arg_76_[1]
  local endcol = _arg_76_[2]
  local _end = _arg_76_
  local _arg_78_ = _77_
  local forced_motion = _arg_78_["forced-motion"]
  local inclusive_motion_3f = _arg_78_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _79_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _79_
  local _80_ = forced_motion
  if (_80_ == ctrl_v) then
    local _let_81_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_81_[1]
    local endcol0 = _let_81_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_80_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_80_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _80_
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
  local function _84_()
    local _83_ = direction
    if (_83_ == "fwd") then
      return "W"
    elseif (_83_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _84_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_onscreen_lines(_86_)
  local _arg_87_ = _86_
  local reverse_3f = _arg_87_["reverse?"]
  local skip_folds_3f = _arg_87_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _88_
    if reverse_3f then
      _88_ = (lnum >= wintop)
    else
      _88_ = (lnum <= winbot)
    end
    if not _88_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _90_
      if reverse_3f then
        _90_ = dec
      else
        _90_ = inc
      end
      lnum = _90_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _92_
      if reverse_3f then
        _92_ = dec
      else
        _92_ = inc
      end
      lnum = _92_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_95_)
  local _arg_96_ = _95_
  local match_width = _arg_96_["match-width"]
  local gutter_width = dec(leftmost_editable_wincol())
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - gutter_width)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - gutter_width)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _97_)
  local _arg_98_ = _97_
  local ft_search_3f = _arg_98_["ft-search?"]
  local limit = _arg_98_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _100_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_100_())
  local cleanup
  local function _101_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _101_
  local _103_
  if ft_search_3f then
    _103_ = 1
  else
    _103_ = 2
  end
  local _let_102_ = get_horizontal_bounds({["match-width"] = _103_})
  local left_bound = _let_102_[1]
  local right_bound = _let_102_[2]
  local function skip_to_fold_edge_21()
    local _105_
    local _106_
    if reverse_3f then
      _106_ = vim.fn.foldclosed
    else
      _106_ = vim.fn.foldclosedend
    end
    _105_ = _106_(vim.fn.line("."))
    if (_105_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _105_) then
      local fold_edge = _105_
      vim.fn.cursor(fold_edge, 0)
      local function _108_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _108_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_110_ = get_cursor_pos()
    local line = _local_110_[1]
    local col = _local_110_[2]
    local from_pos = _local_110_
    local _111_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _111_ = {dec(line), right_bound}
        else
        _111_ = nil
        end
      else
        _111_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _111_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _111_ = {inc(line), left_bound}
        else
        _111_ = nil
        end
      end
    else
    _111_ = nil
    end
    if (nil ~= _111_) then
      local to_pos = _111_
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
      local _119_
      local _120_
      if match_at_curpos_3f then
        _120_ = "c"
      else
        _120_ = ""
      end
      _119_ = vim.fn.searchpos(pattern, (opts0 .. _120_), stopline)
      if ((type(_119_) == "table") and ((_119_)[1] == 0) and true) then
        local _ = (_119_)[2]
        return cleanup()
      elseif ((type(_119_) == "table") and (nil ~= (_119_)[1]) and (nil ~= (_119_)[2])) then
        local line = (_119_)[1]
        local col = (_119_)[2]
        local pos = _119_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _122_ = skip_to_fold_edge_21()
          if (_122_ == "moved-the-cursor") then
            return rec(false)
          elseif (_122_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_123_,_124_,_125_) return (_123_ <= _124_) and (_124_ <= _125_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _126_ = skip_to_next_in_window_pos_21()
              if (_126_ == "moved-the-cursor") then
                return rec(true)
              else
                local _ = _126_
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
  local _let_133_ = (_3fpos or get_cursor_pos())
  local line = _let_133_[1]
  local col = _let_133_[2]
  local pos = _let_133_
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
  local _136_ = mode
  if (_136_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  elseif (_136_ == "ft") then
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
  local _143_
  do
    local _142_ = repeat_invoc
    if (_142_ == "dot") then
      _143_ = "dotrepeat_"
    else
      local _ = _142_
      _143_ = ""
    end
  end
  local _148_
  do
    local _147_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_147_) == "table") and ((_147_)[1] == "ft") and ((_147_)[2] == false) and ((_147_)[3] == false)) then
      _148_ = "f"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "ft") and ((_147_)[2] == true) and ((_147_)[3] == false)) then
      _148_ = "F"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "ft") and ((_147_)[2] == false) and ((_147_)[3] == true)) then
      _148_ = "t"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "ft") and ((_147_)[2] == true) and ((_147_)[3] == true)) then
      _148_ = "T"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "sx") and ((_147_)[2] == false) and ((_147_)[3] == false)) then
      _148_ = "s"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "sx") and ((_147_)[2] == false) and ((_147_)[3] == true)) then
      _148_ = "S"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "sx") and ((_147_)[2] == true) and ((_147_)[3] == false)) then
      _148_ = "x"
    elseif ((type(_147_) == "table") and ((_147_)[1] == "sx") and ((_147_)[2] == true) and ((_147_)[3] == true)) then
      _148_ = "X"
    else
    _148_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _143_ .. _148_)
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
  local _let_159_ = map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_159_[1]
  local revert_key = _let_159_[2]
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
  local _162_
  if instant_repeat_3f then
    _162_ = self.state.instant["in"]
  elseif dot_repeat_3f then
    _162_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _162_ = self.state.cold["in"]
  else
    local _163_
    local function _164_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _163_ = (get_input_and_clean_up() or _164_())
    if (_163_ == "\13") then
      local function _166_()
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
      _162_ = (self.state.cold["in"] or _166_())
    elseif (nil ~= _163_) then
      local in0 = _163_
      _162_ = in0
    else
    _162_ = nil
    end
  end
  if (nil ~= _162_) then
    local in1 = _162_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f, ["t-mode?"] = t_mode_3f}
    end
    local function _172_()
      if reverse_3f then
        return "nWb"
      else
        return "nW"
      end
    end
    local _local_171_ = vim.fn.searchpos("\\_.", _172_())
    local next_line = _local_171_[1]
    local next_col = _local_171_[2]
    local match_pos = nil
    local i = 0
    local function _175_()
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit
      if opts.limit_ft_matches then
        limit = (count + opts.limit_ft_matches)
      else
      limit = nil
      end
      return onscreen_match_positions(pattern, reverse_3f, {["ft-search?"] = true, limit = limit})
    end
    for _173_ in _175_() do
      local _each_176_ = _173_
      local line = _each_176_[1]
      local col = _each_176_[2]
      local pos = _each_176_
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
          local function _182_()
            if reverse_3f then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_182_())
        end
        if (op_mode_3f_4_auto and not reverse_3f and true) then
          local _184_ = string.sub(vim.fn.mode("t"), -1)
          if (_184_ == "v") then
            push_cursor_21("bwd")
          elseif (_184_ == "o") then
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
        local _191_
        local function _192_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _191_ = (get_input_and_clean_up() or _192_())
        if (nil ~= _191_) then
          local in2 = _191_
          local mode
          if (vim.fn.mode() == "n") then
            mode = "n"
          else
            mode = "x"
          end
          local repeat_3f = ((in2 == repeat_key) or (vim.fn.maparg(in2, mode) == get_plug_key("ft", false, t_mode_3f)))
          local revert_3f = ((in2 == revert_key) or (vim.fn.maparg(in2, mode) == get_plug_key("ft", true, t_mode_3f)))
          local do_instant_repeat_3f = (repeat_3f or revert_3f)
          if do_instant_repeat_3f then
            if not instant_repeat_3f then
              self.state.instant = {["in"] = in1, stack = {}}
            end
            if revert_3f then
              local _195_ = table.remove(self.state.instant.stack)
              if (nil ~= _195_) then
                local old_pos = _195_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(self.state.instant.stack, get_cursor_pos())
            end
            local function _198_()
              if revert_3f then
                return "reverted-instant"
              else
                return "instant"
              end
            end
            return ft:go(reverse_3f, t_mode_3f, _198_())
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
  local function _204_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _204_})
end
local function get_labels()
  local function _206_()
    if opts.jump_to_first_match then
      return {"f", "s", "n", "u", "t", "/", "q", "F", "S", "G", "H", "L", "M", "N", "U", "R", "T", "Z", "?", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "a", ";", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "z", "."}
    end
  end
  return (opts.labels or _206_())
end
local function get_cycle_keys()
  local function _207_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _208_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return map(replace_keycodes, {(opts.cycle_group_fwd_key or _207_()), (opts.cycle_group_bwd_key or _208_())})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_209_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_209_[1]
  local right_bound = _let_209_[2]
  local _let_210_ = get_cursor_pos()
  local curline = _let_210_[1]
  local curcol = _let_210_[2]
  for lnum, line in pairs(get_onscreen_lines({["reverse?"] = reverse_3f, ["skip-folds?"] = true})) do
    local on_curline_3f = (lnum == curline)
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
        local _214_
        do
          local _213_ = unique_chars[ch]
          if (nil ~= _213_) then
            local pos_already_there = _213_
            _214_ = false
          else
            local _ = _213_
            _214_ = {lnum, col}
          end
        end
        unique_chars[ch] = _214_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _219_ = pos
    if ((type(_219_) == "table") and (nil ~= (_219_)[1]) and (nil ~= (_219_)[2])) then
      local lnum = (_219_)[1]
      local col = (_219_)[2]
      hl["add-hl"](hl, hl.group["unique-ch"], dec(lnum), dec(col), col)
    end
  end
  return nil
end
local function get_targets(ch1, reverse_3f)
  local targets = {}
  local prev_match = {}
  local added_prev_match_3f = nil
  local pattern = ("\\V\\C" .. ch1:gsub("\\", "\\\\") .. "\\_.")
  for _221_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_222_ = _221_
    local line = _each_222_[1]
    local col = _each_222_[2]
    local pos = _each_222_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local overlaps_prev_match_3f
    local _223_
    if reverse_3f then
      _223_ = dec
    else
      _223_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _223_(prev_match.col)))
    local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
    local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
    prev_match = {ch2 = ch2, col = col, line = line}
    if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
      added_prev_match_3f = false
    else
      local target = {pair = {ch1, ch2}, pos = pos}
      if overlaps_prev_target_3f then
        local _225_
        if reverse_3f then
          _225_ = last(targets)
        else
          _225_ = target
        end
        _225_["overlapped?"] = true
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
  for _, _230_ in ipairs(targets) do
    local _each_231_ = _230_
    local target = _each_231_
    local _each_232_ = _each_231_["pair"]
    local _0 = _each_232_[1]
    local ch2 = _each_232_[2]
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
        local _234_
        if not (jump_to_first_3f and (i == 1)) then
          local _235_
          local _237_
          if jump_to_first_3f then
            _237_ = dec(i)
          else
            _237_ = i
          end
          _235_ = (_237_ % #labels)
          if (_235_ == 0) then
            _234_ = last(labels)
          elseif (nil ~= _235_) then
            local n = _235_
            _234_ = labels[n]
          else
          _234_ = nil
          end
        else
        _234_ = nil
        end
        target["label"] = _234_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(target_list, _244_)
  local _arg_245_ = _244_
  local group_offset = _arg_245_["group-offset"]
  local jump_to_first_3f = _arg_245_["jump-to-first?"]
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
    local _247_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _247_ = "inactive"
      elseif (i <= primary_end) then
        _247_ = "active-primary"
      else
        _247_ = "active-secondary"
      end
    else
    _247_ = nil
    end
    target["label-state"] = _247_
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
      local _250_, _251_ = ch2, true
      if ((nil ~= _250_) and (nil ~= _251_)) then
        local k_10_auto = _250_
        local v_11_auto = _251_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _253_ in ipairs(targets) do
    local _each_254_ = _253_
    local target = _each_254_
    local label = _each_254_["label"]
    local label_state = _each_254_["label-state"]
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
local function set_beacon(_257_, repeat_3f)
  local _arg_258_ = _257_
  local target = _arg_258_
  local label = _arg_258_["label"]
  local label_state = _arg_258_["label-state"]
  local overlapped_3f = _arg_258_["overlapped?"]
  local _arg_259_ = _arg_258_["pair"]
  local ch1 = _arg_259_[1]
  local ch2 = _arg_259_[2]
  local _arg_260_ = _arg_258_["pos"]
  local _ = _arg_260_[1]
  local col = _arg_260_[2]
  local shortcut_3f = _arg_258_["shortcut?"]
  local function _262_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_261_ = map(_262_, {ch1, ch2})
  local ch10 = _let_261_[1]
  local ch20 = _let_261_[2]
  local function _264_(_241)
    return (not repeat_3f and _241)
  end
  local _let_263_ = map(_264_, {overlapped_3f, shortcut_3f})
  local overlapped_3f0 = _let_263_[1]
  local shortcut_3f0 = _let_263_[2]
  local unlabeled_hl = hl.group["unlabeled-match"]
  local function _268_()
    if shortcut_3f0 then
      return {hl.group.shortcut, hl.group["shortcut-overlapped"]}
    else
      local _266_ = label_state
      if (_266_ == "active-secondary") then
        return {hl.group["label-distant"], hl.group["label-distant-overlapped"]}
      elseif (_266_ == "active-primary") then
        return {hl.group.label, hl.group["label-overlapped"]}
      else
        local _0 = _266_
        return {nil, nil}
      end
    end
  end
  local _let_265_ = _268_()
  local label_hl = _let_265_[1]
  local overlapped_label_hl = _let_265_[2]
  local _269_
  if not label then
    if overlapped_3f0 then
      _269_ = {inc(col), {ch20, unlabeled_hl}}
    else
      _269_ = {col, {ch10, unlabeled_hl}, {ch20, unlabeled_hl}}
    end
  elseif (label_state == "inactive") then
    _269_ = nil
  elseif overlapped_3f0 then
    _269_ = {inc(col), {label, overlapped_label_hl}}
  elseif repeat_3f then
    _269_ = {inc(col), {label, label_hl}}
  else
    _269_ = {col, {ch20, hl.group["masked-ch"]}, {label, label_hl}}
  end
  target["beacon"] = _269_
  return nil
end
local function set_beacons(target_list, _272_)
  local _arg_273_ = _272_
  local repeat_3f = _arg_273_["repeat?"]
  for _, target in ipairs(target_list) do
    set_beacon(target, repeat_3f)
  end
  return nil
end
local function light_up_beacons(target_list)
  for _, _274_ in ipairs(target_list) do
    local _each_275_ = _274_
    local beacon = _each_275_["beacon"]
    local _each_276_ = _each_275_["pos"]
    local line = _each_276_[1]
    local _0 = _each_276_[2]
    local _277_ = beacon
    if ((type(_277_) == "table") and (nil ~= (_277_)[1]) and (nil ~= (_277_)[2]) and true) then
      local startcol = (_277_)[1]
      local chunk1 = (_277_)[2]
      local _3fchunk2 = (_277_)[3]
      hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _279_ in ipairs(target_list) do
    local _each_280_ = _279_
    local target = _each_280_
    local label = _each_280_["label"]
    local label_state = _each_280_["label-state"]
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
  local _let_284_ = get_cycle_keys()
  local cycle_fwd_key = _let_284_[1]
  local cycle_bwd_key = _let_284_[2]
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
      local _285_
      local function _286_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _285_ = (get_input_and_clean_up() or _286_())
      if (nil ~= _285_) then
        local in0 = _285_
        do
          local _288_ = in0
          if (_288_ == "\13") then
            enter_repeat_3f = true
          elseif (_288_ == x_mode_prefix_key) then
            x_mode_3f = true
          end
        end
        local res = in0
        if (x_mode_3f and not invoked_in_x_mode_3f) then
          local _290_
          local function _291_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _290_ = (get_input_and_clean_up() or _291_())
          if (_290_ == "\13") then
            enter_repeat_3f = true
          elseif (nil ~= _290_) then
            local in0_2a = _290_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or enter_repeat_3f)
        if enter_repeat_3f then
          local function _295_()
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
          return (self.state.cold.in1 or _295_())
        else
          return res
        end
      end
    end
  end
  local function save_state_for_repeat_2a(in1)
    local function _302_(_300_)
      local _arg_301_ = _300_
      local cold = _arg_301_["cold"]
      local dot = _arg_301_["dot"]
      if new_search_3f then
        if cold then
          local _303_ = cold
          _303_["in1"] = in1
          _303_["x-mode?"] = x_mode_3f
          _303_["reverse?"] = reverse_3f
          self.state.cold = _303_
        end
        if (dot_repeatable_op_3f and dot) then
          do
            local _305_ = dot
            _305_["in1"] = in1
            _305_["x-mode?"] = x_mode_3f
            self.state.dot = _305_
          end
          return nil
        end
      end
    end
    return _302_
  end
  local jump_wrapped_21
  do
    local first_jump_3f = true
    local function _308_(target)
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
          local _312_ = string.sub(vim.fn.mode("t"), -1)
          if (_312_ == "v") then
            push_cursor_21("bwd")
          elseif (_312_ == "o") then
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
    jump_wrapped_21 = _308_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_318_, ch2)
    local _arg_319_ = _318_
    local target_line = _arg_319_[1]
    local target_col = _arg_319_[2]
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
      local function _322_()
        if reverse_3f then
          return to_pos
        else
          return from_pos
        end
      end
      local _let_321_ = _322_()
      local startline = _let_321_[1]
      local startcol = _let_321_[2]
      local start = _let_321_
      local function _324_()
        if reverse_3f then
          return from_pos
        else
          return to_pos
        end
      end
      local _let_323_ = _324_()
      local _ = _let_323_[1]
      local endcol = _let_323_[2]
      local _end = _let_323_
      local _3fhighlight_cursor_at
      if op_mode_3f then
        local function _325_()
          if (forced_motion == ctrl_v) then
            return {startline, min(startcol, endcol)}
          elseif not reverse_3f then
            return from_pos
          end
        end
        _3fhighlight_cursor_at = map(inc, _325_())
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
    local _let_331_ = sublist
    local _let_332_ = _let_331_[1]
    local first = _let_332_
    local _let_333_ = _let_332_["pos"]
    local line = _let_333_[1]
    local col = _let_333_[2]
    local rest = {(table.unpack or unpack)(_let_331_, 2)}
    local cursor_right_before_first_target_3f
    do
      local _let_334_ = vim.fn.searchpos("\\_.", "nWb")
      local line_2a = _let_334_[1]
      local col_2a = _let_334_[2]
      do local _ = (line == line_2a) end
      cursor_right_before_first_target_3f = (col == dec(col_2a))
    end
    local skip_one_target_3f = (cold_repeat_3f and x_mode_3f and reverse_3f and cursor_right_before_first_target_3f)
    if skip_one_target_3f then
      local _let_335_ = rest
      local first_rest = _let_335_[1]
      local rest_rest = {(table.unpack or unpack)(_let_335_, 2)}
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
          for _, _338_ in ipairs(target_list) do
            local _each_339_ = _338_
            local _each_340_ = _each_339_["pos"]
            local line = _each_340_[1]
            local col = _each_340_[2]
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
      local _343_ = get_input_and_clean_up()
      if (nil ~= _343_) then
        local input = _343_
        if ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          local _7cgroups_7c = floor((#target_list / #labels))
          local group_offset_2a
          local _345_
          do
            local _344_ = input
            if (_344_ == cycle_fwd_key) then
              _345_ = inc
            else
              local _ = _344_
              _345_ = dec
            end
          end
          group_offset_2a = clamp(_345_(group_offset), 0, _7cgroups_7c)
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
  local _354_ = get_first_input()
  if (nil ~= _354_) then
    local in1 = _354_
    local save_state_for_repeat = save_state_for_repeat_2a(in1)
    local prev_in2
    if (cold_repeat_3f or enter_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
    prev_in2 = nil
    end
    local _356_
    local function _357_()
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
    _356_ = (get_targets(in1, reverse_3f) or _357_())
    if ((type(_356_) == "table") and ((type((_356_)[1]) == "table") and (nil ~= ((_356_)[1]).pos) and ((type(((_356_)[1]).pair) == "table") and true and (nil ~= (((_356_)[1]).pair)[2]))) and ((_356_)[2] == nil)) then
      local pos = ((_356_)[1]).pos
      local _ = (((_356_)[1]).pair)[1]
      local ch2 = (((_356_)[1]).pair)[2]
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
    elseif (nil ~= _356_) then
      local targets = _356_
      do
        local _361_ = targets
        populate_sublists(_361_)
        set_labels(_361_, jump_to_first_3f)
        set_label_states(_361_, jump_to_first_3f)
      end
      if new_search_3f then
        do
          local _362_ = targets
          set_shortcuts_and_populate_shortcuts_map(_362_)
          set_beacons(_362_, {["repeat?"] = false})
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
      local _365_
      local function _366_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _365_ = (prev_in2 or get_input_and_clean_up() or _366_())
      if (nil ~= _365_) then
        local in2 = _365_
        local _368_
        if new_search_3f then
          _368_ = targets.shortcuts[in2]
        else
        _368_ = nil
        end
        if ((type(_368_) == "table") and (nil ~= (_368_).pos) and ((type((_368_).pair) == "table") and true and (nil ~= ((_368_).pair)[2]))) then
          local pos = (_368_).pos
          local _ = ((_368_).pair)[1]
          local ch2 = ((_368_).pair)[2]
          do
            save_state_for_repeat({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_wrapped_21(pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _368_
          save_state_for_repeat({cold = {in2 = in2}, dot = {in2 = in2, in3 = labels[1]}})
          local _370_
          local function _371_()
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
          _370_ = (targets.sublists[in2] or _371_())
          if (nil ~= _370_) then
            local sublist = _370_
            local _let_373_ = handle_cold_repeating_X(sublist)
            local first = _let_373_[1]
            local rest = _let_373_[2]
            local sublist0 = _let_373_[3]
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
              local _376_
              local function _377_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
              _376_ = ((dot_repeat_3f and self.state.dot.in3 and {self.state.dot.in3}) or select_match_group(target_list) or _377_())
              if ((type(_376_) == "table") and (nil ~= (_376_)[1]) and true) then
                local in3 = (_376_)[1]
                local _3fgroup_offset = (_376_)[2]
                if (not dot_repeat_3f and dot_repeatable_op_3f) then
                  if (_3fgroup_offset > 0) then
                    self.state.dot.in3 = nil
                  else
                    self.state.dot.in3 = in3
                  end
                end
                local _381_ = get_target_with_active_primary_label(target_list, in3)
                if ((type(_381_) == "table") and (nil ~= (_381_).pos)) then
                  local pos = (_381_).pos
                  do
                    jump_wrapped_21(pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _0 = _381_
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
    local _let_392_ = vim.split(opt, ".", true)
    local _0 = _let_392_[1]
    local scope = _let_392_[2]
    local name = _let_392_[3]
    local _393_
    if (opt == "vim.wo.scrolloff") then
      _393_ = api.nvim_eval("&l:scrolloff")
    else
      _393_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _393_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_395_ = vim.split(opt, ".", true)
    local _ = _let_395_[1]
    local scope = _let_395_[2]
    local name = _let_395_[3]
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
  for _, _396_ in ipairs(plug_keys) do
    local _each_397_ = _396_
    local lhs = _each_397_[1]
    local rhs_call = _each_397_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _398_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_399_ = _398_
    local lhs = _each_399_[1]
    local rhs_call = _each_399_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _400_ in ipairs(default_keymaps) do
    local _each_401_ = _400_
    local mode = _each_401_[1]
    local lhs = _each_401_[2]
    local rhs = _each_401_[3]
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
