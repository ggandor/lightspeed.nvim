local api = vim.api
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local min = math.min
local max = math.max
local ceil = math.ceil
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
local function same_pos_3f(_2_, _4_)
  local _arg_3_ = _2_
  local l1 = _arg_3_[1]
  local c1 = _arg_3_[2]
  local _arg_5_ = _4_
  local l2 = _arg_5_[1]
  local c2 = _arg_5_[2]
  return ((l1 == l2) and (c1 == c2))
end
local function getchar_as_str()
  local ok_3f, ch = pcall(vim.fn.getchar)
  local function _6_()
    if (type(ch) == "number") then
      return vim.fn.nr2char(ch)
    else
      return ch
    end
  end
  return ok_3f, _6_()
end
local function char_at_pos(_7_, _9_)
  local _arg_8_ = _7_
  local line = _arg_8_[1]
  local byte_col = _arg_8_[2]
  local _arg_10_ = _9_
  local char_offset = _arg_10_["char-offset"]
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
  local _12_
  local _13_
  if reverse_3f then
    _13_ = vim.fn.foldclosed
  else
    _13_ = vim.fn.foldclosedend
  end
  _12_ = _13_(lnum)
  if (_12_ == -1) then
    return nil
  elseif (nil ~= _12_) then
    local fold_edge = _12_
    return fold_edge
  end
end
local opts = {cycle_group_bwd_key = nil, cycle_group_fwd_key = nil, grey_out_search_area = true, highlight_unique_chars = true, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, jump_to_first_match = true, labels = nil, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local hl
local function _16_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _17_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _18_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _16_, ["set-extmark"] = _17_, cleanup = _18_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _20_
  do
    local _19_ = bg
    if (_19_ == "light") then
      _20_ = "#f02077"
    else
      local _ = _19_
      _20_ = "#ff2f87"
    end
  end
  local _25_
  do
    local _24_ = bg
    if (_24_ == "light") then
      _25_ = "#ff4090"
    else
      local _ = _24_
      _25_ = "#e01067"
    end
  end
  local _30_
  do
    local _29_ = bg
    if (_29_ == "light") then
      _30_ = "Blue"
    else
      local _ = _29_
      _30_ = "Cyan"
    end
  end
  local _35_
  do
    local _34_ = bg
    if (_34_ == "light") then
      _35_ = "#399d9f"
    else
      local _ = _34_
      _35_ = "#99ddff"
    end
  end
  local _40_
  do
    local _39_ = bg
    if (_39_ == "light") then
      _40_ = "Cyan"
    else
      local _ = _39_
      _40_ = "Blue"
    end
  end
  local _45_
  do
    local _44_ = bg
    if (_44_ == "light") then
      _45_ = "#59bdbf"
    else
      local _ = _44_
      _45_ = "#79bddf"
    end
  end
  local _50_
  do
    local _49_ = bg
    if (_49_ == "light") then
      _50_ = "#cc9999"
    else
      local _ = _49_
      _50_ = "#b38080"
    end
  end
  local _55_
  do
    local _54_ = bg
    if (_54_ == "light") then
      _55_ = "Black"
    else
      local _ = _54_
      _55_ = "White"
    end
  end
  local _60_
  do
    local _59_ = bg
    if (_59_ == "light") then
      _60_ = "#272020"
    else
      local _ = _59_
      _60_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _20_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _25_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _30_, gui = "bold,underline", guibg = "NONE", guifg = _35_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _40_, gui = "underline", guifg = _45_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _50_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _55_, gui = "bold", guibg = "NONE", guifg = _60_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _64_ in ipairs(groupdefs) do
    local _each_65_ = _64_
    local group = _each_65_[1]
    local attrs = _each_65_[2]
    local attrs_str
    local _66_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _66_ = tbl_12_auto
    end
    attrs_str = table.concat(_66_, " ")
    local _67_
    if force_3f then
      _67_ = ""
    else
      _67_ = "default "
    end
    vim.cmd(("highlight " .. _67_ .. group .. " " .. attrs_str))
  end
  for _, _69_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_70_ = _69_
    local from_group = _each_70_[1]
    local to_group = _each_70_[2]
    local _71_
    if force_3f then
      _71_ = ""
    else
      _71_ = "default "
    end
    vim.cmd(("highlight " .. _71_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_73_ = map(dec, get_cursor_pos())
  local curline = _let_73_[1]
  local curcol = _let_73_[2]
  local _let_74_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_74_[1]
  local win_bot = _let_74_[2]
  local function _76_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_75_ = _76_()
  local start = _let_75_[1]
  local finish = _let_75_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _77_, _79_, _81_)
  local _arg_78_ = _77_
  local startline = _arg_78_[1]
  local startcol = _arg_78_[2]
  local start = _arg_78_
  local _arg_80_ = _79_
  local endline = _arg_80_[1]
  local endcol = _arg_80_[2]
  local _end = _arg_80_
  local _arg_82_ = _81_
  local forced_motion = _arg_82_["forced-motion"]
  local inclusive_motion_3f = _arg_82_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _83_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _83_
  local _84_ = forced_motion
  if (_84_ == ctrl_v) then
    local _let_85_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_85_[1]
    local endcol0 = _let_85_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_84_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_84_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _84_
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
  local function _88_()
    local _87_ = direction
    if (_87_ == "fwd") then
      return "W"
    elseif (_87_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _88_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_onscreen_lines(_90_)
  local _arg_91_ = _90_
  local reverse_3f = _arg_91_["reverse?"]
  local skip_folds_3f = _arg_91_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _92_
    if reverse_3f then
      _92_ = (lnum >= wintop)
    else
      _92_ = (lnum <= winbot)
    end
    if not _92_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _94_
      if reverse_3f then
        _94_ = dec
      else
        _94_ = inc
      end
      lnum = _94_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _96_
      if reverse_3f then
        _96_ = dec
      else
        _96_ = inc
      end
      lnum = _96_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_99_)
  local _arg_100_ = _99_
  local match_width = _arg_100_["match-width"]
  local gutter_width = dec(leftmost_editable_wincol())
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - gutter_width)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - gutter_width)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _101_)
  local _arg_102_ = _101_
  local ft_search_3f = _arg_102_["ft-search?"]
  local limit = _arg_102_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _104_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_104_())
  local cleanup
  local function _105_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _105_
  local _107_
  if ft_search_3f then
    _107_ = 1
  else
    _107_ = 2
  end
  local _let_106_ = get_horizontal_bounds({["match-width"] = _107_})
  local left_bound = _let_106_[1]
  local right_bound = _let_106_[2]
  local function skip_to_fold_edge_21()
    local _109_
    local _110_
    if reverse_3f then
      _110_ = vim.fn.foldclosed
    else
      _110_ = vim.fn.foldclosedend
    end
    _109_ = _110_(vim.fn.line("."))
    if (_109_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _109_) then
      local fold_edge = _109_
      vim.fn.cursor(fold_edge, 0)
      local function _112_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _112_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_114_ = get_cursor_pos()
    local line = _local_114_[1]
    local col = _local_114_[2]
    local from_pos = _local_114_
    local _115_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _115_ = {dec(line), right_bound}
        else
        _115_ = nil
        end
      else
        _115_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _115_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _115_ = {inc(line), left_bound}
        else
        _115_ = nil
        end
      end
    else
    _115_ = nil
    end
    if (nil ~= _115_) then
      local to_pos = _115_
      if (from_pos ~= to_pos) then
        vim.fn.cursor(to_pos)
        return "moved-the-cursor"
      end
    end
  end
  vim.o.cpo = cpo:gsub("c", "")
  local match_count = 0
  local function recur(match_at_curpos_3f)
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _123_
      local _124_
      if match_at_curpos_3f then
        _124_ = "c"
      else
        _124_ = ""
      end
      _123_ = vim.fn.searchpos(pattern, (opts0 .. _124_), stopline)
      if ((type(_123_) == "table") and ((_123_)[1] == 0) and true) then
        local _ = (_123_)[2]
        return cleanup()
      elseif ((type(_123_) == "table") and (nil ~= (_123_)[1]) and (nil ~= (_123_)[2])) then
        local line = (_123_)[1]
        local col = (_123_)[2]
        local pos = _123_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _126_ = skip_to_fold_edge_21()
          if (_126_ == "moved-the-cursor") then
            return recur(false)
          elseif (_126_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_127_,_128_,_129_) return (_127_ <= _128_) and (_128_ <= _129_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _130_ = skip_to_next_in_window_pos_21()
              if (_130_ == "moved-the-cursor") then
                return recur(true)
              else
                local _ = _130_
                return cleanup()
              end
            end
          end
        end
      end
    end
  end
  return recur
end
local function highlight_cursor(_3fpos)
  local _let_137_ = (_3fpos or get_cursor_pos())
  local line = _let_137_[1]
  local col = _let_137_[2]
  local pos = _let_137_
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
  local _140_ = mode
  if (_140_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  elseif (_140_ == "ft") then
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
  local _147_
  do
    local _146_ = repeat_invoc
    if (_146_ == "dot") then
      _147_ = "dotrepeat_"
    else
      local _ = _146_
      _147_ = ""
    end
  end
  local _152_
  do
    local _151_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_151_) == "table") and ((_151_)[1] == "ft") and ((_151_)[2] == false) and ((_151_)[3] == false)) then
      _152_ = "f"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "ft") and ((_151_)[2] == true) and ((_151_)[3] == false)) then
      _152_ = "F"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "ft") and ((_151_)[2] == false) and ((_151_)[3] == true)) then
      _152_ = "t"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "ft") and ((_151_)[2] == true) and ((_151_)[3] == true)) then
      _152_ = "T"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "sx") and ((_151_)[2] == false) and ((_151_)[3] == false)) then
      _152_ = "s"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "sx") and ((_151_)[2] == true) and ((_151_)[3] == false)) then
      _152_ = "S"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "sx") and ((_151_)[2] == false) and ((_151_)[3] == true)) then
      _152_ = "x"
    elseif ((type(_151_) == "table") and ((_151_)[1] == "sx") and ((_151_)[2] == true) and ((_151_)[3] == true)) then
      _152_ = "X"
    else
    _152_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _147_ .. _152_)
end
local ft = {state = {cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}, dot = {["in"] = nil}, instant = {["in"] = nil, stack = {}}}}
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
  local count0
  if (instant_repeat_3f and t_mode_3f) then
    count0 = inc(count)
  else
    count0 = count
  end
  local _let_164_ = map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_164_[1]
  local revert_key = _let_164_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("ft", reverse_3f, t_mode_3f, "dot"))
  local reset_instant_state
  local function _165_()
    self.state.instant = {["in"] = nil, stack = {}}
    return nil
  end
  reset_instant_state = _165_
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _168_
  if instant_repeat_3f then
    _168_ = self.state.instant["in"]
  elseif dot_repeat_3f then
    _168_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _168_ = self.state.cold["in"]
  else
    local _169_
    local function _170_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _169_ = (get_input_and_clean_up() or _170_())
    if (_169_ == "\13") then
      local function _172_()
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
      _168_ = (self.state.cold["in"] or _172_())
    elseif (nil ~= _169_) then
      local _in = _169_
      _168_ = _in
    else
    _168_ = nil
    end
  end
  if (nil ~= _168_) then
    local in1 = _168_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f, ["t-mode?"] = t_mode_3f}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _177_()
        if reverse_3f then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _177_())
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local stack_size = #self.state.instant.stack
      local group_limit = (opts.limit_ft_matches or 0)
      local eaten_up
      if (group_limit == 0) then
        eaten_up = 0
      else
        eaten_up = (stack_size % group_limit)
      end
      local remaining = (group_limit - eaten_up)
      local to_be_highlighted
      if (remaining == 0) then
        to_be_highlighted = group_limit
      else
        to_be_highlighted = remaining
      end
      local limit = (count0 + to_be_highlighted)
      for _180_ in onscreen_match_positions(pattern, reverse_3f, {["ft-search?"] = true, limit = limit}) do
        local _each_181_ = _180_
        local line = _each_181_[1]
        local col = _each_181_[2]
        local pos = _each_181_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
            end
          end
          match_count = (match_count + 1)
        end
      end
    end
    if (not reverted_instant_repeat_3f and ((match_count == 0) or ((match_count == 1) and instant_repeat_3f and t_mode_3f))) then
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        reset_instant_state()
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
        vim.fn.cursor(jump_pos)
        if t_mode_3f then
          local function _187_()
            if reverse_3f then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_187_())
        end
        if (op_mode_3f_4_auto and not reverse_3f and true) then
          local _189_ = string.sub(vim.fn.mode("t"), -1)
          if (_189_ == "v") then
            push_cursor_21("bwd")
          elseif (_189_ == "o") then
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
            set_dot_repeat(cmd_for_dot_repeat, count0)
          end
        end
        doau_when_exists("LightspeedFtLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      else
        highlight_cursor()
        vim.cmd("redraw")
        local _196_
        local function _197_()
          do
            reset_instant_state()
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _196_ = (get_input_and_clean_up() or _197_())
        if (nil ~= _196_) then
          local in2 = _196_
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
              self.state.instant["in"] = in1
            end
            if revert_3f then
              local _200_ = table.remove(self.state.instant.stack)
              if (nil ~= _200_) then
                local old_pos = _200_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(self.state.instant.stack, get_cursor_pos())
            end
            local function _203_()
              if revert_3f then
                return "reverted-instant"
              else
                return "instant"
              end
            end
            return ft:go(reverse_3f, t_mode_3f, _203_())
          else
            do
              reset_instant_state()
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
  local function _209_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _209_})
end
local function get_labels()
  local function _211_()
    if opts.jump_to_first_match then
      return {"s", "f", "n", "u", "t", "/", "q", "F", "S", "G", "H", "L", "M", "N", "U", "R", "T", "Z", "?", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "a", ";", "z", "."}
    end
  end
  return (opts.labels or _211_())
end
local function get_cycle_keys()
  local function _212_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _213_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return map(replace_keycodes, {(opts.cycle_group_fwd_key or _212_()), (opts.cycle_group_bwd_key or _213_())})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_214_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_214_[1]
  local right_bound = _let_214_[2]
  local _let_215_ = get_cursor_pos()
  local curline = _let_215_[1]
  local curcol = _let_215_[2]
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
        local _219_
        do
          local _218_ = unique_chars[ch]
          if (nil ~= _218_) then
            local pos_already_there = _218_
            _219_ = false
          else
            local _ = _218_
            _219_ = {lnum, col}
          end
        end
        unique_chars[ch] = _219_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _224_ = pos
    if ((type(_224_) == "table") and (nil ~= (_224_)[1]) and (nil ~= (_224_)[2])) then
      local lnum = (_224_)[1]
      local col = (_224_)[2]
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
  for _226_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_227_ = _226_
    local line = _each_227_[1]
    local col = _each_227_[2]
    local pos = _each_227_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local overlaps_prev_match_3f
    local _228_
    if reverse_3f then
      _228_ = dec
    else
      _228_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _228_(prev_match.col)))
    local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
    local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
    prev_match = {ch2 = ch2, col = col, line = line}
    if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
      added_prev_match_3f = false
    else
      local target = {pair = {ch1, ch2}, pos = pos}
      if overlaps_prev_target_3f then
        local _230_
        if reverse_3f then
          _230_ = last(targets)
        else
          _230_ = target
        end
        _230_["overlapped?"] = true
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
  for _, _235_ in ipairs(targets) do
    local _each_236_ = _235_
    local target = _each_236_
    local _each_237_ = _each_236_["pair"]
    local _0 = _each_237_[1]
    local ch2 = _each_237_[2]
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function set_labels(targets, autojump_to_first_3f)
  local labels = get_labels()
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      for i, target in ipairs(sublist) do
        local _239_
        if not (autojump_to_first_3f and (i == 1)) then
          local _240_
          local _242_
          if autojump_to_first_3f then
            _242_ = dec(i)
          else
            _242_ = i
          end
          _240_ = (_242_ % #labels)
          if (_240_ == 0) then
            _239_ = last(labels)
          elseif (nil ~= _240_) then
            local n = _240_
            _239_ = labels[n]
          else
          _239_ = nil
          end
        else
        _239_ = nil
        end
        target["label"] = _239_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(target_list, _249_)
  local _arg_250_ = _249_
  local autojump_to_first_3f = _arg_250_["autojump-to-first?"]
  local group_offset = _arg_250_["group-offset"]
  local labels = get_labels()
  local _7clabels_7c = #labels
  local base
  if autojump_to_first_3f then
    base = 2
  else
    base = 1
  end
  local offset = (group_offset * _7clabels_7c)
  local primary_start = (base + offset)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(target_list) do
    local _252_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _252_ = "inactive"
      elseif (i <= primary_end) then
        _252_ = "active-primary"
      else
        _252_ = "active-secondary"
      end
    else
    _252_ = nil
    end
    target["label-state"] = _252_
  end
  return nil
end
local function set_label_states(targets, autojump_to_first_3f)
  for _, sublist in pairs(targets.sublists) do
    set_label_states_for_sublist(sublist, {["autojump-to-first?"] = autojump_to_first_3f, ["group-offset"] = 0})
  end
  return nil
end
local function set_shortcuts_and_populate_shortcuts_map(targets)
  targets["shortcuts"] = {}
  local potential_2nd_inputs
  do
    local tbl_9_auto = {}
    for ch2, _ in pairs(targets.sublists) do
      local _255_, _256_ = ch2, true
      if ((nil ~= _255_) and (nil ~= _256_)) then
        local k_10_auto = _255_
        local v_11_auto = _256_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _258_ in ipairs(targets) do
    local _each_259_ = _258_
    local target = _each_259_
    local label = _each_259_["label"]
    local label_state = _each_259_["label-state"]
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
local function set_beacon(_262_, repeat_3f)
  local _arg_263_ = _262_
  local target = _arg_263_
  local label = _arg_263_["label"]
  local label_state = _arg_263_["label-state"]
  local overlapped_3f = _arg_263_["overlapped?"]
  local _arg_264_ = _arg_263_["pair"]
  local ch1 = _arg_264_[1]
  local ch2 = _arg_264_[2]
  local _arg_265_ = _arg_263_["pos"]
  local _ = _arg_265_[1]
  local col = _arg_265_[2]
  local shortcut_3f = _arg_263_["shortcut?"]
  local function _267_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_266_ = map(_267_, {ch1, ch2})
  local ch10 = _let_266_[1]
  local ch20 = _let_266_[2]
  local function _269_(_241)
    return (not repeat_3f and _241)
  end
  local _let_268_ = map(_269_, {overlapped_3f, shortcut_3f})
  local overlapped_3f0 = _let_268_[1]
  local shortcut_3f0 = _let_268_[2]
  local unlabeled_hl = hl.group["unlabeled-match"]
  local function _273_()
    if shortcut_3f0 then
      return {hl.group.shortcut, hl.group["shortcut-overlapped"]}
    else
      local _271_ = label_state
      if (_271_ == "active-secondary") then
        return {hl.group["label-distant"], hl.group["label-distant-overlapped"]}
      elseif (_271_ == "active-primary") then
        return {hl.group.label, hl.group["label-overlapped"]}
      else
        local _0 = _271_
        return {nil, nil}
      end
    end
  end
  local _let_270_ = _273_()
  local label_hl = _let_270_[1]
  local overlapped_label_hl = _let_270_[2]
  local _274_
  if not label then
    if overlapped_3f0 then
      _274_ = {inc(col), {ch20, unlabeled_hl}}
    else
      _274_ = {col, {ch10, unlabeled_hl}, {ch20, unlabeled_hl}}
    end
  elseif (label_state == "inactive") then
    _274_ = nil
  elseif overlapped_3f0 then
    _274_ = {inc(col), {label, overlapped_label_hl}}
  elseif repeat_3f then
    _274_ = {inc(col), {label, label_hl}}
  else
    _274_ = {col, {ch20, hl.group["masked-ch"]}, {label, label_hl}}
  end
  target["beacon"] = _274_
  return nil
end
local function set_beacons(target_list, _277_)
  local _arg_278_ = _277_
  local repeat_3f = _arg_278_["repeat?"]
  for _, target in ipairs(target_list) do
    set_beacon(target, repeat_3f)
  end
  return nil
end
local function light_up_beacons(target_list)
  for _, _279_ in ipairs(target_list) do
    local _each_280_ = _279_
    local beacon = _each_280_["beacon"]
    local _each_281_ = _each_280_["pos"]
    local line = _each_281_[1]
    local _0 = _each_281_[2]
    local _282_ = beacon
    if ((type(_282_) == "table") and (nil ~= (_282_)[1]) and (nil ~= (_282_)[2]) and true) then
      local startcol = (_282_)[1]
      local chunk1 = (_282_)[2]
      local _3fchunk2 = (_282_)[3]
      hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _284_ in ipairs(target_list) do
    local _each_285_ = _284_
    local target = _each_285_
    local label = _each_285_["label"]
    local label_state = _each_285_["label-state"]
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
  local _let_289_ = get_cycle_keys()
  local cycle_fwd_key = _let_289_[1]
  local cycle_bwd_key = _let_289_[2]
  local labels = get_labels()
  local autojump_to_first_3f = (opts.jump_to_first_match and not op_mode_3f)
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
      if (nil ~= _290_) then
        local in0 = _290_
        do
          local _293_ = in0
          if (_293_ == "\13") then
            enter_repeat_3f = true
          elseif (_293_ == x_mode_prefix_key) then
            x_mode_3f = true
          end
        end
        local res = in0
        if (x_mode_3f and not invoked_in_x_mode_3f) then
          local _295_
          local function _296_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _295_ = (get_input_and_clean_up() or _296_())
          if (_295_ == "\13") then
            enter_repeat_3f = true
          elseif (nil ~= _295_) then
            local in0_2a = _295_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or enter_repeat_3f)
        if enter_repeat_3f then
          local function _300_()
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
          return (self.state.cold.in1 or _300_())
        else
          return res
        end
      end
    end
  end
  local function update_state_2a(in1)
    local function _307_(_305_)
      local _arg_306_ = _305_
      local cold = _arg_306_["cold"]
      local dot = _arg_306_["dot"]
      if new_search_3f then
        if cold then
          local _308_ = cold
          _308_["in1"] = in1
          _308_["x-mode?"] = x_mode_3f
          _308_["reverse?"] = reverse_3f
          self.state.cold = _308_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _310_ = dot
              _310_["in1"] = in1
              _310_["x-mode?"] = x_mode_3f
              self.state.dot = _310_
            end
            return nil
          end
        end
      end
    end
    return _307_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _314_(target)
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
          local _318_ = string.sub(vim.fn.mode("t"), -1)
          if (_318_ == "v") then
            push_cursor_21("bwd")
          elseif (_318_ == "o") then
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
    jump_to_21 = _314_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_324_, ch2)
    local _arg_325_ = _324_
    local target_line = _arg_325_[1]
    local target_col = _arg_325_[2]
    local from_pos = map(dec, get_cursor_pos())
    jump_to_21({target_line, target_col})
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
      local function _328_()
        if reverse_3f then
          return to_pos
        else
          return from_pos
        end
      end
      local _let_327_ = _328_()
      local startline = _let_327_[1]
      local startcol = _let_327_[2]
      local start = _let_327_
      local function _330_()
        if reverse_3f then
          return from_pos
        else
          return to_pos
        end
      end
      local _let_329_ = _330_()
      local _ = _let_329_[1]
      local endcol = _let_329_[2]
      local _end = _let_329_
      local _3fhighlight_cursor_at
      if op_mode_3f then
        local function _331_()
          if (forced_motion == ctrl_v) then
            return {startline, min(startcol, endcol)}
          elseif not reverse_3f then
            return from_pos
          end
        end
        _3fhighlight_cursor_at = map(inc, _331_())
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
  local function get_sublist(targets, ch)
    local _337_ = targets.sublists[ch]
    if (nil ~= _337_) then
      local sublist = _337_
      local _let_338_ = sublist
      local _let_339_ = _let_338_[1]
      local _let_340_ = _let_339_["pos"]
      local line = _let_340_[1]
      local col = _let_340_[2]
      local rest = {(table.unpack or unpack)(_let_338_, 2)}
      local target_tail = {line, inc(col)}
      local prev_pos = vim.fn.searchpos("\\_.", "nWb")
      local cursor_touches_first_target_3f = same_pos_3f(target_tail, prev_pos)
      if (cold_repeat_3f and x_mode_3f and reverse_3f and cursor_touches_first_target_3f) then
        if not empty_3f(rest) then
          return rest
        end
      else
        return sublist
      end
    end
  end
  local function after_cold_repeat(target_list)
    if not op_mode_3f then
      do
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f)
        end
        do
          for _, _345_ in ipairs(target_list) do
            local _each_346_ = _345_
            local _each_347_ = _each_346_["pos"]
            local line = _each_347_[1]
            local col = _each_347_[2]
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), inc(col))
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      return vim.fn.feedkeys((get_input_and_clean_up() or ""), "i")
    end
  end
  local function select_match_group(target_list)
    local num_of_groups = ceil((#target_list / #labels))
    local max_offset = dec(num_of_groups)
    local function recur(group_offset)
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
      local _350_ = get_input_and_clean_up()
      if (nil ~= _350_) then
        local input = _350_
        if ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          local group_offset_2a
          local _352_
          do
            local _351_ = input
            if (_351_ == cycle_fwd_key) then
              _352_ = inc
            else
              local _ = _351_
              _352_ = dec
            end
          end
          group_offset_2a = clamp(_352_(group_offset), 0, max_offset)
          set_label_states_for_sublist(target_list, {["autojump-to-first?"] = false, ["group-offset"] = group_offset_2a})
          return recur(group_offset_2a)
        else
          return {input, group_offset}
        end
      end
    end
    return recur(0)
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
  local _361_ = get_first_input()
  if (nil ~= _361_) then
    local in1 = _361_
    local update_state = update_state_2a(in1)
    local prev_in2
    if (cold_repeat_3f or enter_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
    prev_in2 = nil
    end
    local _363_
    local function _364_()
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
    _363_ = (get_targets(in1, reverse_3f) or _364_())
    if ((type(_363_) == "table") and ((type((_363_)[1]) == "table") and (nil ~= ((_363_)[1]).pos) and ((type(((_363_)[1]).pair) == "table") and true and (nil ~= (((_363_)[1]).pair)[2]))) and ((_363_)[2] == nil)) then
      local pos = ((_363_)[1]).pos
      local _ = (((_363_)[1]).pair)[1]
      local ch2 = (((_363_)[1]).pair)[2]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = labels[1]}})
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
    elseif (nil ~= _363_) then
      local targets = _363_
      do
        local _368_ = targets
        populate_sublists(_368_)
        set_labels(_368_, autojump_to_first_3f)
        set_label_states(_368_, autojump_to_first_3f)
      end
      if new_search_3f then
        do
          local _369_ = targets
          set_shortcuts_and_populate_shortcuts_map(_369_)
          set_beacons(_369_, {["repeat?"] = false})
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
      local _372_
      local function _373_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _372_ = (prev_in2 or get_input_and_clean_up() or _373_())
      if (nil ~= _372_) then
        local in2 = _372_
        local _375_
        if new_search_3f then
          _375_ = targets.shortcuts[in2]
        else
        _375_ = nil
        end
        if ((type(_375_) == "table") and (nil ~= (_375_).pos) and ((type((_375_).pair) == "table") and true and (nil ~= ((_375_).pair)[2]))) then
          local pos = (_375_).pos
          local _ = ((_375_).pair)[1]
          local ch2 = ((_375_).pair)[2]
          do
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _375_
          update_state({cold = {in2 = in2}})
          local _377_
          local function _378_()
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
          _377_ = (get_sublist(targets, in2) or _378_())
          if ((type(_377_) == "table") and (nil ~= (_377_)[1]) and ((_377_)[2] == nil)) then
            local only = (_377_)[1]
            do
              update_state({dot = {in2 = in2, in3 = labels[1]}})
              jump_to_21(only.pos)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif (nil ~= _377_) then
            local sublist = _377_
            local _let_380_ = sublist
            local first = _let_380_[1]
            local rest = {(table.unpack or unpack)(_let_380_, 2)}
            if (autojump_to_first_3f or cold_repeat_3f) then
              jump_to_21(first.pos)
            end
            if cold_repeat_3f then
              do
                after_cold_repeat(rest)
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            else
              local labeled_targets
              if autojump_to_first_3f then
                labeled_targets = rest
              else
                labeled_targets = sublist
              end
              local _383_
              local function _384_()
                if (dot_repeat_3f and self.state.dot.in3) then
                  return {self.state.dot.in3, 0}
                end
              end
              local function _385_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
              _383_ = (_384_() or select_match_group(labeled_targets) or _385_())
              if ((type(_383_) == "table") and (nil ~= (_383_)[1]) and (nil ~= (_383_)[2])) then
                local in3 = (_383_)[1]
                local group_offset = (_383_)[2]
                local _387_
                local function _389_()
                  if autojump_to_first_3f then
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
                _387_ = (get_target_with_active_primary_label(labeled_targets, in3) or _389_())
                if (nil ~= _387_) then
                  local target = _387_
                  do
                    local _390_
                    if (group_offset > 0) then
                      _390_ = nil
                    else
                      _390_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _390_}})
                    jump_to_21(target.pos)
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
local temporary_editor_opts = {["vim.wo.conceallevel"] = 0, ["vim.wo.scrolloff"] = 0}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_400_ = vim.split(opt, ".", true)
    local _0 = _let_400_[1]
    local scope = _let_400_[2]
    local name = _let_400_[3]
    local _401_
    if (opt == "vim.wo.scrolloff") then
      _401_ = api.nvim_eval("&l:scrolloff")
    else
      _401_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _401_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_403_ = vim.split(opt, ".", true)
    local _ = _let_403_[1]
    local scope = _let_403_[2]
    local name = _let_403_[3]
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
  for _, _404_ in ipairs(plug_keys) do
    local _each_405_ = _404_
    local lhs = _each_405_[1]
    local rhs_call = _each_405_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _406_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_407_ = _406_
    local lhs = _each_407_[1]
    local rhs_call = _each_407_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _408_ in ipairs(default_keymaps) do
    local _each_409_ = _408_
    local mode = _each_409_[1]
    local lhs = _each_409_[2]
    local rhs = _each_409_[3]
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
