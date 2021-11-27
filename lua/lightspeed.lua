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
local function char_at_pos(_6_, _8_)
  local _arg_7_ = _6_
  local line = _arg_7_[1]
  local byte_col = _arg_7_[2]
  local _arg_9_ = _8_
  local char_offset = _arg_9_["char-offset"]
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
  local _11_
  local _12_
  if reverse_3f then
    _12_ = vim.fn.foldclosed
  else
    _12_ = vim.fn.foldclosedend
  end
  _11_ = _12_(lnum)
  if (_11_ == -1) then
    return nil
  elseif (nil ~= _11_) then
    local fold_edge = _11_
    return fold_edge
  end
end
local opts
do
  local safe_labels = {"s", "f", "n", "u", "t", "/", "S", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  local labels = {"s", "f", "n", "j", "k", "l", "o", "i", "w", "e", "h", "g", "u", "t", "m", "v", "c", ";", "a", ".", "z", "/", "S", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  opts = {cycle_group_bwd_key = "<tab>", cycle_group_fwd_key = "<space>", exit_after_idle_msecs = {labeled = 1500, unlabeled = 1000}, grey_out_search_area = true, highlight_unique_chars = true, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, labels = labels, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, safe_labels = safe_labels, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
end
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local hl
local function _15_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _16_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _17_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _15_, ["set-extmark"] = _16_, cleanup = _17_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _19_
  do
    local _18_ = bg
    if (_18_ == "light") then
      _19_ = "#f02077"
    else
      local _ = _18_
      _19_ = "#ff2f87"
    end
  end
  local _24_
  do
    local _23_ = bg
    if (_23_ == "light") then
      _24_ = "#ff4090"
    else
      local _ = _23_
      _24_ = "#e01067"
    end
  end
  local _29_
  do
    local _28_ = bg
    if (_28_ == "light") then
      _29_ = "Blue"
    else
      local _ = _28_
      _29_ = "Cyan"
    end
  end
  local _34_
  do
    local _33_ = bg
    if (_33_ == "light") then
      _34_ = "#399d9f"
    else
      local _ = _33_
      _34_ = "#99ddff"
    end
  end
  local _39_
  do
    local _38_ = bg
    if (_38_ == "light") then
      _39_ = "Cyan"
    else
      local _ = _38_
      _39_ = "Blue"
    end
  end
  local _44_
  do
    local _43_ = bg
    if (_43_ == "light") then
      _44_ = "#59bdbf"
    else
      local _ = _43_
      _44_ = "#79bddf"
    end
  end
  local _49_
  do
    local _48_ = bg
    if (_48_ == "light") then
      _49_ = "#cc9999"
    else
      local _ = _48_
      _49_ = "#b38080"
    end
  end
  local _54_
  do
    local _53_ = bg
    if (_53_ == "light") then
      _54_ = "Black"
    else
      local _ = _53_
      _54_ = "White"
    end
  end
  local _59_
  do
    local _58_ = bg
    if (_58_ == "light") then
      _59_ = "#272020"
    else
      local _ = _58_
      _59_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _19_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _24_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _29_, gui = "bold,underline", guibg = "NONE", guifg = _34_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _39_, gui = "underline", guifg = _44_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _49_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _54_, gui = "bold", guibg = "NONE", guifg = _59_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _63_ in ipairs(groupdefs) do
    local _each_64_ = _63_
    local group = _each_64_[1]
    local attrs = _each_64_[2]
    local attrs_str
    local _65_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _65_ = tbl_12_auto
    end
    attrs_str = table.concat(_65_, " ")
    local _66_
    if force_3f then
      _66_ = ""
    else
      _66_ = "default "
    end
    vim.cmd(("highlight " .. _66_ .. group .. " " .. attrs_str))
  end
  for _, _68_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_69_ = _68_
    local from_group = _each_69_[1]
    local to_group = _each_69_[2]
    local _70_
    if force_3f then
      _70_ = ""
    else
      _70_ = "default "
    end
    vim.cmd(("highlight " .. _70_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_72_ = map(dec, get_cursor_pos())
  local curline = _let_72_[1]
  local curcol = _let_72_[2]
  local _let_73_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_73_[1]
  local win_bot = _let_73_[2]
  local function _75_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_74_ = _75_()
  local start = _let_74_[1]
  local finish = _let_74_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _76_, _78_, _80_)
  local _arg_77_ = _76_
  local startline = _arg_77_[1]
  local startcol = _arg_77_[2]
  local start = _arg_77_
  local _arg_79_ = _78_
  local endline = _arg_79_[1]
  local endcol = _arg_79_[2]
  local _end = _arg_79_
  local _arg_81_ = _80_
  local forced_motion = _arg_81_["forced-motion"]
  local inclusive_motion_3f = _arg_81_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _82_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _82_
  local _83_ = forced_motion
  if (_83_ == ctrl_v) then
    local _let_84_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_84_[1]
    local endcol0 = _let_84_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_83_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_83_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _83_
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
  local function _87_()
    local _86_ = direction
    if (_86_ == "fwd") then
      return "W"
    elseif (_86_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _87_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_onscreen_lines(_89_)
  local _arg_90_ = _89_
  local reverse_3f = _arg_90_["reverse?"]
  local skip_folds_3f = _arg_90_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _91_
    if reverse_3f then
      _91_ = (lnum >= wintop)
    else
      _91_ = (lnum <= winbot)
    end
    if not _91_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _93_
      if reverse_3f then
        _93_ = dec
      else
        _93_ = inc
      end
      lnum = _93_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _95_
      if reverse_3f then
        _95_ = dec
      else
        _95_ = inc
      end
      lnum = _95_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_98_)
  local _arg_99_ = _98_
  local match_width = _arg_99_["match-width"]
  local gutter_width = dec(leftmost_editable_wincol())
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - gutter_width)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - gutter_width)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _100_)
  local _arg_101_ = _100_
  local ft_search_3f = _arg_101_["ft-search?"]
  local limit = _arg_101_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _103_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_103_())
  local cleanup
  local function _104_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _104_
  local _106_
  if ft_search_3f then
    _106_ = 1
  else
    _106_ = 2
  end
  local _let_105_ = get_horizontal_bounds({["match-width"] = _106_})
  local left_bound = _let_105_[1]
  local right_bound = _let_105_[2]
  local function skip_to_fold_edge_21()
    local _108_
    local _109_
    if reverse_3f then
      _109_ = vim.fn.foldclosed
    else
      _109_ = vim.fn.foldclosedend
    end
    _108_ = _109_(vim.fn.line("."))
    if (_108_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _108_) then
      local fold_edge = _108_
      vim.fn.cursor(fold_edge, 0)
      local function _111_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _111_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_113_ = get_cursor_pos()
    local line = _local_113_[1]
    local col = _local_113_[2]
    local from_pos = _local_113_
    local _114_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _114_ = {dec(line), right_bound}
        else
        _114_ = nil
        end
      else
        _114_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _114_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _114_ = {inc(line), left_bound}
        else
        _114_ = nil
        end
      end
    else
    _114_ = nil
    end
    if (nil ~= _114_) then
      local to_pos = _114_
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
      local _122_
      local _123_
      if match_at_curpos_3f then
        _123_ = "c"
      else
        _123_ = ""
      end
      _122_ = vim.fn.searchpos(pattern, (opts0 .. _123_), stopline)
      if ((type(_122_) == "table") and ((_122_)[1] == 0) and true) then
        local _ = (_122_)[2]
        return cleanup()
      elseif ((type(_122_) == "table") and (nil ~= (_122_)[1]) and (nil ~= (_122_)[2])) then
        local line = (_122_)[1]
        local col = (_122_)[2]
        local pos = _122_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _125_ = skip_to_fold_edge_21()
          if (_125_ == "moved-the-cursor") then
            return recur(false)
          elseif (_125_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_126_,_127_,_128_) return (_126_ <= _127_) and (_127_ <= _128_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _129_ = skip_to_next_in_window_pos_21()
              if (_129_ == "moved-the-cursor") then
                return recur(true)
              else
                local _ = _129_
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
  local _let_136_ = (_3fpos or get_cursor_pos())
  local line = _let_136_[1]
  local col = _let_136_[2]
  local pos = _let_136_
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
  local _139_ = mode
  if (_139_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  elseif (_139_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _141_()
    return ("" ~= vim.fn.getcharstr(true))
  end
  char_available_3f = _141_
  local getchar_timeout
  local function _142_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getcharstr(false)
    end
  end
  getchar_timeout = _142_
  local ok_3f, ch = nil, nil
  local function _144_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getcharstr
    end
  end
  ok_3f, ch = pcall(_144_())
  if (ok_3f and (ch ~= esc_keycode)) then
    return ch
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
  local _150_
  do
    local _149_ = repeat_invoc
    if (_149_ == "dot") then
      _150_ = "dotrepeat_"
    else
      local _ = _149_
      _150_ = ""
    end
  end
  local _155_
  do
    local _154_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_154_) == "table") and ((_154_)[1] == "ft") and ((_154_)[2] == false) and ((_154_)[3] == false)) then
      _155_ = "f"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "ft") and ((_154_)[2] == true) and ((_154_)[3] == false)) then
      _155_ = "F"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "ft") and ((_154_)[2] == false) and ((_154_)[3] == true)) then
      _155_ = "t"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "ft") and ((_154_)[2] == true) and ((_154_)[3] == true)) then
      _155_ = "T"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "sx") and ((_154_)[2] == false) and ((_154_)[3] == false)) then
      _155_ = "s"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "sx") and ((_154_)[2] == true) and ((_154_)[3] == false)) then
      _155_ = "S"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "sx") and ((_154_)[2] == false) and ((_154_)[3] == true)) then
      _155_ = "x"
    elseif ((type(_154_) == "table") and ((_154_)[1] == "sx") and ((_154_)[2] == true) and ((_154_)[3] == true)) then
      _155_ = "X"
    else
    _155_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _150_ .. _155_)
end
local ft = {state = {cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}, dot = {["in"] = nil}}}
ft.go = function(self, reverse_3f, t_mode_3f, repeat_invoc)
  local instant_repeat_3f = (type(repeat_invoc) == "table")
  local instant
  if instant_repeat_3f then
    instant = repeat_invoc
  else
  instant = nil
  end
  local reverted_instant_repeat_3f
  if instant_repeat_3f then
    reverted_instant_repeat_3f = instant["reverted?"]
  else
  reverted_instant_repeat_3f = nil
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local reverse_3f0
  if cold_repeat_3f then
    local function _167_(_241)
      if reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _167_(self.state.cold["reverse?"])
  else
    reverse_3f0 = reverse_3f
  end
  local t_mode_3f0
  if cold_repeat_3f then
    t_mode_3f0 = self.state.cold["t-mode?"]
  else
    t_mode_3f0 = t_mode_3f
  end
  local count
  if reverted_instant_repeat_3f then
    count = 0
  else
    count = vim.v.count1
  end
  local count0
  if (instant_repeat_3f and t_mode_3f0) then
    count0 = inc(count)
  else
    count0 = count
  end
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("ft", reverse_3f0, t_mode_3f0, "dot"))
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _175_
  if instant_repeat_3f then
    _175_ = instant["in"]
  elseif dot_repeat_3f then
    _175_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _175_ = self.state.cold["in"]
  else
    local _176_
    local function _177_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _178_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _176_ = (_177_() or _178_())
    if (_176_ == "\13") then
      local function _180_()
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
      _175_ = (self.state.cold["in"] or _180_())
    elseif (nil ~= _176_) then
      local _in = _176_
      _175_ = _in
    else
    _175_ = nil
    end
  end
  if (nil ~= _175_) then
    local in1 = _175_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _185_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _185_())
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local stack_size
      if instant_repeat_3f then
        stack_size = #instant.stack
      else
        stack_size = 0
      end
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
      for _189_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_190_ = _189_
        local line = _each_190_[1]
        local col = _each_190_[2]
        local pos = _each_190_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
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
    if (not reverted_instant_repeat_3f and ((match_count == 0) or ((match_count == 1) and instant_repeat_3f and t_mode_3f0))) then
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
        vim.fn.cursor(jump_pos)
        if t_mode_3f0 then
          local function _196_()
            if reverse_3f0 then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_196_())
        end
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and true) then
            local _198_ = string.sub(vim.fn.mode("t"), -1)
            if (_198_ == "v") then
              push_cursor_21("bwd")
            elseif (_198_ == "o") then
              if not cursor_before_eof_3f() then
                push_cursor_21("fwd")
              else
                vim.cmd("set virtualedit=onemore")
                vim.cmd("norm! l")
                vim.cmd(restore_virtualedit_autocmd_5_auto)
              end
            end
          end
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
        local _205_
        local function _206_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _207_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _205_ = (_206_() or _207_())
        if (nil ~= _205_) then
          local in2 = _205_
          local mode
          if (vim.fn.mode() == "n") then
            mode = "n"
          else
            mode = "x"
          end
          local repeat_3f = ((vim.fn.maparg(in2, mode) == get_plug_key("ft", false, t_mode_3f0)) or (in2 == replace_keycodes((opts.instant_repeat_fwd_key or ""))))
          local revert_3f = ((vim.fn.maparg(in2, mode) == get_plug_key("ft", true, t_mode_3f0)) or (in2 == replace_keycodes((opts.instant_repeat_bwd_key or ""))))
          local invoke_instant_repeat_3f = (repeat_3f or revert_3f)
          if invoke_instant_repeat_3f then
            local stack
            if instant_repeat_3f then
              stack = instant.stack
            else
              stack = {}
            end
            if revert_3f then
              local _210_ = table.remove(stack)
              if (nil ~= _210_) then
                local old_pos = _210_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(stack, get_cursor_pos())
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, ["reverted?"] = revert_3f, stack = stack})
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
  local function _218_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _218_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_220_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_220_[1]
  local right_bound = _let_220_[2]
  local _let_221_ = get_cursor_pos()
  local curline = _let_221_[1]
  local curcol = _let_221_[2]
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
        local _225_
        do
          local _224_ = unique_chars[ch]
          if (nil ~= _224_) then
            local pos_already_there = _224_
            _225_ = false
          else
            local _ = _224_
            _225_ = {lnum, col}
          end
        end
        unique_chars[ch] = _225_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _230_ = pos
    if ((type(_230_) == "table") and (nil ~= (_230_)[1]) and (nil ~= (_230_)[2])) then
      local lnum = (_230_)[1]
      local col = (_230_)[2]
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
  for _232_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_233_ = _232_
    local line = _each_233_[1]
    local col = _each_233_[2]
    local pos = _each_233_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local before_eol_3f = (ch2 == "\13")
    local overlaps_prev_match_3f
    local _234_
    if reverse_3f then
      _234_ = dec
    else
      _234_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _234_(prev_match.col)))
    local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
    local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
    prev_match = {ch2 = ch2, col = col, line = line}
    if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
      added_prev_match_3f = false
    else
      local target = {pair = {ch1, ch2}, pos = pos}
      local prev_target = last(targets)
      local match_width = 2
      local touches_prev_target_3f
      do
        local _236_ = prev_target
        if ((type(_236_) == "table") and ((type((_236_).pos) == "table") and (nil ~= ((_236_).pos)[1]) and (nil ~= ((_236_).pos)[2]))) then
          local prev_line = ((_236_).pos)[1]
          local prev_col = ((_236_).pos)[2]
          local function _238_()
            local col_delta
            if reverse_3f then
              col_delta = (prev_col - col)
            else
              col_delta = (col - prev_col)
            end
            return (col_delta <= match_width)
          end
          touches_prev_target_3f = ((line == prev_line) and _238_())
        else
        touches_prev_target_3f = nil
        end
      end
      if before_eol_3f then
        target["squeezed?"] = true
      end
      if touches_prev_target_3f then
        local _241_
        if reverse_3f then
          _241_ = target
        else
          _241_ = prev_target
        end
        _241_["squeezed?"] = true
      end
      if overlaps_prev_target_3f then
        local _244_
        if reverse_3f then
          _244_ = prev_target
        else
          _244_ = target
        end
        _244_["overlapped?"] = true
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
  for _, _249_ in ipairs(targets) do
    local _each_250_ = _249_
    local target = _each_250_
    local _each_251_ = _each_250_["pair"]
    local _0 = _each_251_[1]
    local ch2 = _each_251_[2]
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function get_labels(sublist)
  if (not opts.labels or empty_3f(opts.labels)) then
    if (sublist["autojump?"] == nil) then
      sublist["autojump?"] = true
    end
    return opts.safe_labels
  elseif (not opts.safe_labels or empty_3f(opts.safe_labels)) then
    if (sublist["autojump?"] == nil) then
      sublist["autojump?"] = false
    end
    return opts.labels
  else
    local _255_ = sublist["autojump?"]
    if (_255_ == true) then
      return opts.safe_labels
    elseif (_255_ == false) then
      return opts.labels
    elseif (_255_ == nil) then
      sublist["autojump?"] = (not operator_pending_mode_3f() and (dec(#sublist) <= #opts.safe_labels))
      return get_labels(sublist)
    end
  end
end
local function set_labels(targets)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      local labels = get_labels(sublist)
      for i, target in ipairs(sublist) do
        local _258_
        if not (sublist["autojump?"] and (i == 1)) then
          local _259_
          local _261_
          if sublist["autojump?"] then
            _261_ = dec(i)
          else
            _261_ = i
          end
          _259_ = (_261_ % #labels)
          if (_259_ == 0) then
            _258_ = last(labels)
          elseif (nil ~= _259_) then
            local n = _259_
            _258_ = labels[n]
          else
          _258_ = nil
          end
        else
        _258_ = nil
        end
        target["label"] = _258_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _268_)
  local _arg_269_ = _268_
  local group_offset = _arg_269_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _270_
  if sublist["autojump?"] then
    _270_ = 2
  else
    _270_ = 1
  end
  primary_start = (offset + _270_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _272_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _272_ = "inactive"
      elseif (i <= primary_end) then
        _272_ = "active-primary"
      else
        _272_ = "active-secondary"
      end
    else
    _272_ = nil
    end
    target["label-state"] = _272_
  end
  return nil
end
local function set_label_states(targets)
  for _, sublist in pairs(targets.sublists) do
    set_label_states_for_sublist(sublist, {["group-offset"] = 0})
  end
  return nil
end
local function set_shortcuts_and_populate_shortcuts_map(targets)
  targets["shortcuts"] = {}
  local potential_2nd_inputs
  do
    local tbl_9_auto = {}
    for ch2, _ in pairs(targets.sublists) do
      local _275_, _276_ = ch2, true
      if ((nil ~= _275_) and (nil ~= _276_)) then
        local k_10_auto = _275_
        local v_11_auto = _276_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _278_ in ipairs(targets) do
    local _each_279_ = _278_
    local target = _each_279_
    local label = _each_279_["label"]
    local label_state = _each_279_["label-state"]
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
local function set_beacon(_282_, repeat_3f)
  local _arg_283_ = _282_
  local target = _arg_283_
  local label = _arg_283_["label"]
  local label_state = _arg_283_["label-state"]
  local overlapped_3f = _arg_283_["overlapped?"]
  local _arg_284_ = _arg_283_["pair"]
  local ch1 = _arg_284_[1]
  local ch2 = _arg_284_[2]
  local _arg_285_ = _arg_283_["pos"]
  local _ = _arg_285_[1]
  local col = _arg_285_[2]
  local shortcut_3f = _arg_283_["shortcut?"]
  local squeezed_3f = _arg_283_["squeezed?"]
  local function _287_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_286_ = map(_287_, {ch1, ch2})
  local ch10 = _let_286_[1]
  local ch20 = _let_286_[2]
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _288_ = label_state
    if (_288_ == nil) then
      if overlapped_3f then
        target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
      else
        target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
      end
    elseif (_288_ == "active-primary") then
      if repeat_3f then
        local _290_
        if squeezed_3f then
          _290_ = 1
        else
          _290_ = 2
        end
        target.beacon = {_290_, {label_24}}
      elseif shortcut_3f then
        if overlapped_3f then
          target.beacon = {1, {overlapped_shortcut_24}}
        else
          if squeezed_3f then
            target.beacon = {0, {masked_char_24, shortcut_24}}
          else
            target.beacon = {2, {shortcut_24}}
          end
        end
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, label_24}}
      else
        target.beacon = {2, {label_24}}
      end
    elseif (_288_ == "active-secondary") then
      if repeat_3f then
        local _295_
        if squeezed_3f then
          _295_ = 1
        else
          _295_ = 2
        end
        target.beacon = {_295_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_288_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _299_)
  local _arg_300_ = _299_
  local repeat_3f = _arg_300_["repeat?"]
  for _, target in ipairs(target_list) do
    set_beacon(target, repeat_3f)
  end
  return nil
end
local function light_up_beacons(target_list)
  for _, _301_ in ipairs(target_list) do
    local _each_302_ = _301_
    local beacon = _each_302_["beacon"]
    local _each_303_ = _each_302_["pos"]
    local line = _each_303_[1]
    local col = _each_303_[2]
    local _304_ = beacon
    if ((type(_304_) == "table") and (nil ~= (_304_)[1]) and (nil ~= (_304_)[2])) then
      local offset = (_304_)[1]
      local chunks = (_304_)[2]
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _306_ in ipairs(target_list) do
    local _each_307_ = _306_
    local target = _each_307_
    local label = _each_307_["label"]
    local label_state = _each_307_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _309_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _309_) then
    local input = _309_
    if (input ~= char_to_ignore) then
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
  local reverse_3f0
  if cold_repeat_3f then
    local function _312_(_241)
      if reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _312_(self.state.cold["reverse?"])
  else
    reverse_3f0 = reverse_3f
  end
  local x_mode_3f
  if cold_repeat_3f then
    x_mode_3f = self.state.cold["x-mode?"]
  else
    x_mode_3f = invoked_in_x_mode_3f
  end
  local x_mode_3f0 = x_mode_3f
  local enter_repeat_3f = nil
  local new_search_3f = nil
  local function get_first_input()
    if dot_repeat_3f then
      x_mode_3f0 = self.state.dot["x-mode?"]
      return self.state.dot.in1
    elseif cold_repeat_3f then
      return self.state.cold.in1
    else
      local _316_
      local function _317_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _318_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _316_ = (_317_() or _318_())
      if (nil ~= _316_) then
        local in0 = _316_
        local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
        do
          local _320_ = in0
          if (_320_ == "\13") then
            enter_repeat_3f = true
          elseif (_320_ == x_mode_prefix_key) then
            x_mode_3f0 = true
          end
        end
        local res = in0
        if (x_mode_3f0 and not invoked_in_x_mode_3f) then
          local _322_
          local function _323_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _322_ = (get_input() or _323_())
          if (_322_ == "\13") then
            enter_repeat_3f = true
          elseif (nil ~= _322_) then
            local in0_2a = _322_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or enter_repeat_3f)
        if enter_repeat_3f then
          local function _327_()
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
          return (self.state.cold.in1 or _327_())
        else
          return res
        end
      end
    end
  end
  local function update_state_2a(in1)
    local function _334_(_332_)
      local _arg_333_ = _332_
      local cold = _arg_333_["cold"]
      local dot = _arg_333_["dot"]
      if new_search_3f then
        if cold then
          local _335_ = cold
          _335_["in1"] = in1
          _335_["x-mode?"] = x_mode_3f0
          _335_["reverse?"] = reverse_3f0
          self.state.cold = _335_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _337_ = dot
              _337_["in1"] = in1
              _337_["x-mode?"] = x_mode_3f0
              self.state.dot = _337_
            end
            return nil
          end
        end
      end
    end
    return _334_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _341_(target)
      local adjusted_pos
      do
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if first_jump_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target)
        if x_mode_3f0 then
          push_cursor_21("fwd")
          if reverse_3f0 then
            push_cursor_21("fwd")
          end
        end
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and (x_mode_3f0 and not reverse_3f0)) then
            local _345_ = string.sub(vim.fn.mode("t"), -1)
            if (_345_ == "v") then
              push_cursor_21("bwd")
            elseif (_345_ == "o") then
              if not cursor_before_eof_3f() then
                push_cursor_21("fwd")
              else
                vim.cmd("set virtualedit=onemore")
                vim.cmd("norm! l")
                vim.cmd(restore_virtualedit_autocmd_5_auto)
              end
            end
          end
        end
        adjusted_pos = adjusted_pos_6_auto
      end
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _341_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local forced_motion = string.sub(vim.fn.mode("t"), -1)
    local blockwise_3f = (forced_motion == replace_keycodes("<c-v>"))
    local function _351_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_350_ = _351_()
    local startline = _let_350_[1]
    local startcol = _let_350_[2]
    local start = _let_350_
    local function _353_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_352_ = _353_()
    local _ = _let_352_[1]
    local endcol = _let_352_[2]
    local _end = _let_352_
    local top_left = {startline, min(startcol, endcol)}
    local new_curpos
    if op_mode_3f then
      if blockwise_3f then
        new_curpos = top_left
      else
        new_curpos = start
      end
    else
      new_curpos = to_pos
    end
    if not change_op_3f then
      highlight_cursor(new_curpos)
    end
    if op_mode_3f then
      highlight_range(hl.group["pending-op-area"], map(dec, start), map(dec, _end), {["forced-motion"] = forced_motion, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0)})
    end
    return vim.cmd("redraw")
  end
  local function get_sublist(targets, ch)
    local _358_ = targets.sublists[ch]
    if (nil ~= _358_) then
      local sublist = _358_
      local _let_359_ = sublist
      local _let_360_ = _let_359_[1]
      local _let_361_ = _let_360_["pos"]
      local line = _let_361_[1]
      local col = _let_361_[2]
      local rest = {(table.unpack or unpack)(_let_359_, 2)}
      local target_tail = {line, inc(col)}
      local prev_pos = vim.fn.searchpos("\\_.", "nWb")
      local cursor_touches_first_target_3f = same_pos_3f(target_tail, prev_pos)
      if (cold_repeat_3f and x_mode_3f0 and reverse_3f0 and cursor_touches_first_target_3f) then
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
          grey_out_search_area(reverse_3f0)
        end
        do
          for _, _366_ in ipairs(target_list) do
            local _each_367_ = _366_
            local _each_368_ = _each_367_["pos"]
            local line = _each_368_[1]
            local col = _each_368_[2]
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), inc(col))
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local function _369_()
        local res_2_auto
        do
          res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
        end
        hl:cleanup()
        return res_2_auto
      end
      return vim.fn.feedkeys((_369_() or ""), "i")
    end
  end
  local function get_last_input(sublist)
    local _local_371_ = map(replace_keycodes, {opts.cycle_group_fwd_key, opts.cycle_group_bwd_key})
    local cycle_fwd_key = _local_371_[1]
    local cycle_bwd_key = _local_371_[2]
    local function recur(group_offset, initial_invoc_3f)
      set_beacons(sublist, {["repeat?"] = enter_repeat_3f})
      do
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f0)
        end
        do
          light_up_beacons(sublist)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _373_
      do
        local res_2_auto
        do
          local function _374_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_374_())
        end
        hl:cleanup()
        _373_ = res_2_auto
      end
      if (nil ~= _373_) then
        local input = _373_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _376_
          do
            local _375_ = input
            if (_375_ == cycle_fwd_key) then
              _376_ = inc
            else
              local _ = _375_
              _376_ = dec
            end
          end
          group_offset_2a = clamp(_376_(group_offset), 0, max_offset)
          set_label_states_for_sublist(sublist, {["group-offset"] = group_offset_2a})
          return recur(group_offset_2a)
        else
          return {input, group_offset}
        end
      end
    end
    return recur(0, true)
  end
  enter("sx")
  if not repeat_invoc then
    echo("")
    if (opts.grey_out_search_area and not cold_repeat_3f) then
      grey_out_search_area(reverse_3f0)
    end
    do
      if opts.highlight_unique_chars then
        highlight_unique_chars(reverse_3f0)
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _385_ = get_first_input()
  if (nil ~= _385_) then
    local in1 = _385_
    local from_pos = get_cursor_pos()
    local update_state = update_state_2a(in1)
    local prev_in2
    if (cold_repeat_3f or enter_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
    prev_in2 = nil
    end
    local _387_
    local function _388_()
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
    _387_ = (get_targets(in1, reverse_3f0) or _388_())
    if ((type(_387_) == "table") and ((type((_387_)[1]) == "table") and ((type(((_387_)[1]).pair) == "table") and true and (nil ~= (((_387_)[1]).pair)[2]))) and ((_387_)[2] == nil)) then
      local _ = (((_387_)[1]).pair)[1]
      local ch2 = (((_387_)[1]).pair)[2]
      local only = (_387_)[1]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
          end
          update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = opts.labels[1]}})
          local to_pos = jump_to_21(only.pos)
          if new_search_3f then
            local res_2_auto
            do
              highlight_new_curpos_and_op_area(from_pos, to_pos)
              res_2_auto = ignore_input_until_timeout(ch2)
            end
            hl:cleanup()
          end
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
    elseif (nil ~= _387_) then
      local targets = _387_
      do
        local _394_ = targets
        populate_sublists(_394_)
        set_labels(_394_)
        set_label_states(_394_)
      end
      if new_search_3f then
        do
          local _395_ = targets
          set_shortcuts_and_populate_shortcuts_map(_395_)
          set_beacons(_395_, {["repeat?"] = false})
        end
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f0)
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _398_
      local function _399_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _400_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _398_ = (prev_in2 or _399_() or _400_())
      if (nil ~= _398_) then
        local in2 = _398_
        local _402_
        do
          local t_403_ = targets.shortcuts
          if (nil ~= t_403_) then
            t_403_ = (t_403_)[in2]
          end
          _402_ = t_403_
        end
        if ((type(_402_) == "table") and ((type((_402_).pair) == "table") and true and (nil ~= ((_402_).pair)[2]))) then
          local _ = ((_402_).pair)[1]
          local ch2 = ((_402_).pair)[2]
          local shortcut = _402_
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut.pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _402_
          update_state({cold = {in2 = in2}})
          local _406_
          local function _407_()
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
          _406_ = (get_sublist(targets, in2) or _407_())
          if ((type(_406_) == "table") and (nil ~= (_406_)[1]) and ((_406_)[2] == nil)) then
            local only = (_406_)[1]
            do
              if dot_repeatable_op_3f then
                set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
              end
              update_state({dot = {in2 = in2, in3 = opts.labels[1]}})
              jump_to_21(only.pos)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif (nil ~= _406_) then
            local sublist = _406_
            local _let_410_ = sublist
            local first = _let_410_[1]
            local rest = {(table.unpack or unpack)(_let_410_, 2)}
            local autojump_3f = sublist["autojump?"]
            if (autojump_3f or cold_repeat_3f) then
              jump_to_21(first.pos)
            end
            if cold_repeat_3f then
              do
                if dot_repeatable_op_3f then
                  set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                end
                after_cold_repeat(rest)
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            else
              local _413_
              local function _414_()
                if (dot_repeat_3f and self.state.dot.in3) then
                  return {self.state.dot.in3, 0}
                end
              end
              local function _415_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
              _413_ = (_414_() or get_last_input(sublist) or _415_())
              if ((type(_413_) == "table") and (nil ~= (_413_)[1]) and (nil ~= (_413_)[2])) then
                local in3 = (_413_)[1]
                local group_offset = (_413_)[2]
                local _417_
                local function _420_()
                  if autojump_3f then
                    do
                      if dot_repeatable_op_3f then
                        set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                      end
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
                _417_ = (get_target_with_active_primary_label(sublist, in3) or _420_())
                if (nil ~= _417_) then
                  local target = _417_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _422_
                    if (group_offset > 0) then
                      _422_ = nil
                    else
                      _422_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _422_}})
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
local temporary_editor_opts = {["vim.bo.modeline"] = false, ["vim.wo.conceallevel"] = 0, ["vim.wo.scrolloff"] = 0}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_432_ = vim.split(opt, ".", true)
    local _0 = _let_432_[1]
    local scope = _let_432_[2]
    local name = _let_432_[3]
    local _433_
    if (opt == "vim.wo.scrolloff") then
      _433_ = api.nvim_eval("&l:scrolloff")
    else
      _433_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _433_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_435_ = vim.split(opt, ".", true)
    local _ = _let_435_[1]
    local scope = _let_435_[2]
    local name = _let_435_[3]
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
  local plug_keys = {{"<Plug>Lightspeed_s", "sx:go(false)"}, {"<Plug>Lightspeed_S", "sx:go(true)"}, {"<Plug>Lightspeed_x", "sx:go(false, true)"}, {"<Plug>Lightspeed_X", "sx:go(true, true)"}, {"<Plug>Lightspeed_f", "ft:go(false)"}, {"<Plug>Lightspeed_F", "ft:go(true)"}, {"<Plug>Lightspeed_t", "ft:go(false, true)"}, {"<Plug>Lightspeed_T", "ft:go(true, true)"}, {"<Plug>Lightspeed_;_sx", "sx:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_sx", "sx:go(true, nil, 'cold')"}, {"<Plug>Lightspeed_;_ft", "ft:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_ft", "ft:go(true, nil, 'cold')"}, {"<Plug>Lightspeed_;", "sx:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,", "sx:go(true, nil, 'cold')"}}
  for _, _436_ in ipairs(plug_keys) do
    local _each_437_ = _436_
    local lhs = _each_437_[1]
    local rhs_call = _each_437_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _438_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_439_ = _438_
    local lhs = _each_439_[1]
    local rhs_call = _each_439_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _440_ in ipairs(default_keymaps) do
    local _each_441_ = _440_
    local mode = _each_441_[1]
    local lhs = _each_441_[2]
    local rhs = _each_441_[3]
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
