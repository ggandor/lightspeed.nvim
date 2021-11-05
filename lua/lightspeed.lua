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
local opts = {cycle_group_bwd_key = nil, cycle_group_fwd_key = nil, exit_after_idle_msecs = {labeled = 1500, unlabeled = 1000}, grey_out_search_area = true, highlight_unique_chars = true, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, jump_to_first_match = true, labels = nil, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
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
  local ok_3f, ch = nil, nil
  if _3ftimeout then
    local function _141_()
      return (vim.fn.getchar(1) ~= 0)
    end
    if vim.fn.wait(_3ftimeout, _141_, 100) then
      ok_3f, ch = true, vim.fn.getchar(0)
    else
    ok_3f, ch = nil
    end
  else
    ok_3f, ch = pcall(vim.fn.getchar)
  end
  if (ok_3f and (ch ~= esc_keycode)) then
    if (type(ch) == "number") then
      return vim.fn.nr2char(ch)
    else
      return ch
    end
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
  local _let_167_ = map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_167_[1]
  local revert_key = _let_167_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("ft", reverse_3f, t_mode_3f, "dot"))
  local reset_instant_state
  local function _168_()
    self.state.instant = {["in"] = nil, stack = {}}
    return nil
  end
  reset_instant_state = _168_
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _171_
  if instant_repeat_3f then
    _171_ = self.state.instant["in"]
  elseif dot_repeat_3f then
    _171_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _171_ = self.state.cold["in"]
  else
    local _172_
    local function _173_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _174_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _172_ = (_173_() or _174_())
    if (_172_ == "\13") then
      local function _176_()
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
      _171_ = (self.state.cold["in"] or _176_())
    elseif (nil ~= _172_) then
      local _in = _172_
      _171_ = _in
    else
    _171_ = nil
    end
  end
  if (nil ~= _171_) then
    local in1 = _171_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f, ["t-mode?"] = t_mode_3f}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _181_()
        if reverse_3f then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _181_())
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
      for _184_ in onscreen_match_positions(pattern, reverse_3f, {["ft-search?"] = true, limit = limit}) do
        local _each_185_ = _184_
        local line = _each_185_[1]
        local col = _each_185_[2]
        local pos = _each_185_
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
          local function _191_()
            if reverse_3f then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_191_())
        end
        if (op_mode_3f_4_auto and not reverse_3f and true) then
          local _193_ = string.sub(vim.fn.mode("t"), -1)
          if (_193_ == "v") then
            push_cursor_21("bwd")
          elseif (_193_ == "o") then
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
        local _200_
        local function _201_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _202_()
          do
            reset_instant_state()
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _200_ = (_201_() or _202_())
        if (nil ~= _200_) then
          local in2 = _200_
          local mode
          if (vim.fn.mode() == "n") then
            mode = "n"
          else
            mode = "x"
          end
          local repeat_3f = ((vim.fn.maparg(in2, mode) == get_plug_key("ft", false, t_mode_3f)) or (in2 == repeat_key))
          local revert_3f = ((vim.fn.maparg(in2, mode) == get_plug_key("ft", true, t_mode_3f)) or (in2 == revert_key))
          local do_instant_repeat_3f = (repeat_3f or revert_3f)
          if do_instant_repeat_3f then
            if not instant_repeat_3f then
              self.state.instant["in"] = in1
            end
            if revert_3f then
              local _205_ = table.remove(self.state.instant.stack)
              if (nil ~= _205_) then
                local old_pos = _205_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(self.state.instant.stack, get_cursor_pos())
            end
            local function _208_()
              if revert_3f then
                return "reverted-instant"
              else
                return "instant"
              end
            end
            return ft:go(reverse_3f, t_mode_3f, _208_())
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
  local function _214_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _214_})
end
local function get_labels()
  local function _216_()
    if opts.jump_to_first_match then
      return {"s", "f", "n", "u", "t", "/", "q", "F", "S", "G", "H", "L", "M", "N", "U", "R", "T", "Z", "?", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "a", ";", "z", "."}
    end
  end
  return (opts.labels or _216_())
end
local function get_cycle_keys()
  local function _217_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _218_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return map(replace_keycodes, {(opts.cycle_group_fwd_key or _217_()), (opts.cycle_group_bwd_key or _218_())})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_219_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_219_[1]
  local right_bound = _let_219_[2]
  local _let_220_ = get_cursor_pos()
  local curline = _let_220_[1]
  local curcol = _let_220_[2]
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
        local _224_
        do
          local _223_ = unique_chars[ch]
          if (nil ~= _223_) then
            local pos_already_there = _223_
            _224_ = false
          else
            local _ = _223_
            _224_ = {lnum, col}
          end
        end
        unique_chars[ch] = _224_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _229_ = pos
    if ((type(_229_) == "table") and (nil ~= (_229_)[1]) and (nil ~= (_229_)[2])) then
      local lnum = (_229_)[1]
      local col = (_229_)[2]
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
  for _231_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_232_ = _231_
    local line = _each_232_[1]
    local col = _each_232_[2]
    local pos = _each_232_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local overlaps_prev_match_3f
    local _233_
    if reverse_3f then
      _233_ = dec
    else
      _233_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _233_(prev_match.col)))
    local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
    local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
    prev_match = {ch2 = ch2, col = col, line = line}
    if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
      added_prev_match_3f = false
    else
      local target = {pair = {ch1, ch2}, pos = pos}
      if overlaps_prev_target_3f then
        local _235_
        if reverse_3f then
          _235_ = last(targets)
        else
          _235_ = target
        end
        _235_["overlapped?"] = true
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
  for _, _240_ in ipairs(targets) do
    local _each_241_ = _240_
    local target = _each_241_
    local _each_242_ = _each_241_["pair"]
    local _0 = _each_242_[1]
    local ch2 = _each_242_[2]
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
        local _244_
        if not (autojump_to_first_3f and (i == 1)) then
          local _245_
          local _247_
          if autojump_to_first_3f then
            _247_ = dec(i)
          else
            _247_ = i
          end
          _245_ = (_247_ % #labels)
          if (_245_ == 0) then
            _244_ = last(labels)
          elseif (nil ~= _245_) then
            local n = _245_
            _244_ = labels[n]
          else
          _244_ = nil
          end
        else
        _244_ = nil
        end
        target["label"] = _244_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(target_list, _254_)
  local _arg_255_ = _254_
  local autojump_to_first_3f = _arg_255_["autojump-to-first?"]
  local group_offset = _arg_255_["group-offset"]
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
    local _257_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _257_ = "inactive"
      elseif (i <= primary_end) then
        _257_ = "active-primary"
      else
        _257_ = "active-secondary"
      end
    else
    _257_ = nil
    end
    target["label-state"] = _257_
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
      local _260_, _261_ = ch2, true
      if ((nil ~= _260_) and (nil ~= _261_)) then
        local k_10_auto = _260_
        local v_11_auto = _261_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _263_ in ipairs(targets) do
    local _each_264_ = _263_
    local target = _each_264_
    local label = _each_264_["label"]
    local label_state = _each_264_["label-state"]
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
local function set_beacon(_267_, repeat_3f)
  local _arg_268_ = _267_
  local target = _arg_268_
  local label = _arg_268_["label"]
  local label_state = _arg_268_["label-state"]
  local overlapped_3f = _arg_268_["overlapped?"]
  local _arg_269_ = _arg_268_["pair"]
  local ch1 = _arg_269_[1]
  local ch2 = _arg_269_[2]
  local _arg_270_ = _arg_268_["pos"]
  local _ = _arg_270_[1]
  local col = _arg_270_[2]
  local shortcut_3f = _arg_268_["shortcut?"]
  local function _272_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_271_ = map(_272_, {ch1, ch2})
  local ch10 = _let_271_[1]
  local ch20 = _let_271_[2]
  local function _274_(_241)
    return (not repeat_3f and _241)
  end
  local _let_273_ = map(_274_, {overlapped_3f, shortcut_3f})
  local overlapped_3f0 = _let_273_[1]
  local shortcut_3f0 = _let_273_[2]
  local unlabeled_hl = hl.group["unlabeled-match"]
  local function _278_()
    if shortcut_3f0 then
      return {hl.group.shortcut, hl.group["shortcut-overlapped"]}
    else
      local _276_ = label_state
      if (_276_ == "active-secondary") then
        return {hl.group["label-distant"], hl.group["label-distant-overlapped"]}
      elseif (_276_ == "active-primary") then
        return {hl.group.label, hl.group["label-overlapped"]}
      else
        local _0 = _276_
        return {nil, nil}
      end
    end
  end
  local _let_275_ = _278_()
  local label_hl = _let_275_[1]
  local overlapped_label_hl = _let_275_[2]
  local _279_
  if not label then
    if overlapped_3f0 then
      _279_ = {inc(col), {ch20, unlabeled_hl}}
    else
      _279_ = {col, {ch10, unlabeled_hl}, {ch20, unlabeled_hl}}
    end
  elseif (label_state == "inactive") then
    _279_ = nil
  elseif overlapped_3f0 then
    _279_ = {inc(col), {label, overlapped_label_hl}}
  elseif repeat_3f then
    _279_ = {inc(col), {label, label_hl}}
  else
    _279_ = {col, {ch20, hl.group["masked-ch"]}, {label, label_hl}}
  end
  target["beacon"] = _279_
  return nil
end
local function set_beacons(target_list, _282_)
  local _arg_283_ = _282_
  local repeat_3f = _arg_283_["repeat?"]
  for _, target in ipairs(target_list) do
    set_beacon(target, repeat_3f)
  end
  return nil
end
local function light_up_beacons(target_list)
  for _, _284_ in ipairs(target_list) do
    local _each_285_ = _284_
    local beacon = _each_285_["beacon"]
    local _each_286_ = _each_285_["pos"]
    local line = _each_286_[1]
    local _0 = _each_286_[2]
    local _287_ = beacon
    if ((type(_287_) == "table") and (nil ~= (_287_)[1]) and (nil ~= (_287_)[2]) and true) then
      local startcol = (_287_)[1]
      local chunk1 = (_287_)[2]
      local _3fchunk2 = (_287_)[3]
      hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _289_ in ipairs(target_list) do
    local _each_290_ = _289_
    local target = _each_290_
    local label = _each_290_["label"]
    local label_state = _each_290_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_char_until_timeout(char_to_ignore)
  local _292_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _292_) then
    local input = _292_
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
  local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
  local _let_295_ = get_cycle_keys()
  local cycle_fwd_key = _let_295_[1]
  local cycle_bwd_key = _let_295_[2]
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
      local _296_
      local function _297_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _298_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _296_ = (_297_() or _298_())
      if (nil ~= _296_) then
        local in0 = _296_
        do
          local _300_ = in0
          if (_300_ == "\13") then
            enter_repeat_3f = true
          elseif (_300_ == x_mode_prefix_key) then
            x_mode_3f = true
          end
        end
        local res = in0
        if (x_mode_3f and not invoked_in_x_mode_3f) then
          local _302_
          local function _303_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _302_ = (get_input() or _303_())
          if (_302_ == "\13") then
            enter_repeat_3f = true
          elseif (nil ~= _302_) then
            local in0_2a = _302_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or enter_repeat_3f)
        if enter_repeat_3f then
          local function _307_()
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
          return (self.state.cold.in1 or _307_())
        else
          return res
        end
      end
    end
  end
  local function update_state_2a(in1)
    local function _314_(_312_)
      local _arg_313_ = _312_
      local cold = _arg_313_["cold"]
      local dot = _arg_313_["dot"]
      if new_search_3f then
        if cold then
          local _315_ = cold
          _315_["in1"] = in1
          _315_["x-mode?"] = x_mode_3f
          _315_["reverse?"] = reverse_3f
          self.state.cold = _315_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _317_ = dot
              _317_["in1"] = in1
              _317_["x-mode?"] = x_mode_3f
              self.state.dot = _317_
            end
            return nil
          end
        end
      end
    end
    return _314_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _321_(target)
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
          local _325_ = string.sub(vim.fn.mode("t"), -1)
          if (_325_ == "v") then
            push_cursor_21("bwd")
          elseif (_325_ == "o") then
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
    jump_to_21 = _321_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_331_, ch2)
    local _arg_332_ = _331_
    local target_line = _arg_332_[1]
    local target_col = _arg_332_[2]
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
      local function _335_()
        if reverse_3f then
          return to_pos
        else
          return from_pos
        end
      end
      local _let_334_ = _335_()
      local startline = _let_334_[1]
      local startcol = _let_334_[2]
      local start = _let_334_
      local function _337_()
        if reverse_3f then
          return from_pos
        else
          return to_pos
        end
      end
      local _let_336_ = _337_()
      local _ = _let_336_[1]
      local endcol = _let_336_[2]
      local _end = _let_336_
      local _3fhighlight_cursor_at
      if op_mode_3f then
        local _338_
        if (forced_motion == ctrl_v) then
          _338_ = {startline, min(startcol, endcol)}
        elseif not reverse_3f then
          _338_ = from_pos
        else
        _338_ = nil
        end
        if _338_ then
          _3fhighlight_cursor_at = map(inc, _338_)
        else
          _3fhighlight_cursor_at = _338_
        end
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
    local _346_ = targets.sublists[ch]
    if (nil ~= _346_) then
      local sublist = _346_
      local _let_347_ = sublist
      local _let_348_ = _let_347_[1]
      local _let_349_ = _let_348_["pos"]
      local line = _let_349_[1]
      local col = _let_349_[2]
      local rest = {(table.unpack or unpack)(_let_347_, 2)}
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
          for _, _354_ in ipairs(target_list) do
            local _each_355_ = _354_
            local _each_356_ = _each_355_["pos"]
            local line = _each_356_[1]
            local col = _each_356_[2]
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), inc(col))
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local function _357_()
        local res_2_auto
        do
          res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
        end
        hl:cleanup()
        return res_2_auto
      end
      return vim.fn.feedkeys((_357_() or ""), "i")
    end
  end
  local function select_match_group(target_list)
    local num_of_groups = ceil((#target_list / #labels))
    local max_offset = dec(num_of_groups)
    local function recur(group_offset, initial_invoc_3f)
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
      local _360_
      do
        local res_2_auto
        do
          local function _361_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_361_())
        end
        hl:cleanup()
        _360_ = res_2_auto
      end
      if (nil ~= _360_) then
        local input = _360_
        if ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          local group_offset_2a
          local _363_
          do
            local _362_ = input
            if (_362_ == cycle_fwd_key) then
              _363_ = inc
            else
              local _ = _362_
              _363_ = dec
            end
          end
          group_offset_2a = clamp(_363_(group_offset), 0, max_offset)
          set_label_states_for_sublist(target_list, {["autojump-to-first?"] = false, ["group-offset"] = group_offset_2a})
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
  local _372_ = get_first_input()
  if (nil ~= _372_) then
    local in1 = _372_
    local update_state = update_state_2a(in1)
    local prev_in2
    if (cold_repeat_3f or enter_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
    prev_in2 = nil
    end
    local _374_
    local function _375_()
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
    _374_ = (get_targets(in1, reverse_3f) or _375_())
    if ((type(_374_) == "table") and ((type((_374_)[1]) == "table") and ((type(((_374_)[1]).pair) == "table") and true and (nil ~= (((_374_)[1]).pair)[2])) and (nil ~= ((_374_)[1]).pos)) and ((_374_)[2] == nil)) then
      local _ = (((_374_)[1]).pair)[1]
      local ch2 = (((_374_)[1]).pair)[2]
      local pos = ((_374_)[1]).pos
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
    elseif (nil ~= _374_) then
      local targets = _374_
      do
        local _379_ = targets
        populate_sublists(_379_)
        set_labels(_379_, autojump_to_first_3f)
        set_label_states(_379_, autojump_to_first_3f)
      end
      if new_search_3f then
        do
          local _380_ = targets
          set_shortcuts_and_populate_shortcuts_map(_380_)
          set_beacons(_380_, {["repeat?"] = false})
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
      local _383_
      local function _384_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
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
      _383_ = (prev_in2 or _384_() or _385_())
      if (nil ~= _383_) then
        local in2 = _383_
        local _387_
        if new_search_3f then
          _387_ = targets.shortcuts[in2]
        else
        _387_ = nil
        end
        if ((type(_387_) == "table") and ((type((_387_).pair) == "table") and true and (nil ~= ((_387_).pair)[2])) and (nil ~= (_387_).pos)) then
          local _ = ((_387_).pair)[1]
          local ch2 = ((_387_).pair)[2]
          local pos = (_387_).pos
          do
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _387_
          update_state({cold = {in2 = in2}})
          local _389_
          local function _390_()
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
          _389_ = (get_sublist(targets, in2) or _390_())
          if ((type(_389_) == "table") and (nil ~= (_389_)[1]) and ((_389_)[2] == nil)) then
            local only = (_389_)[1]
            do
              update_state({dot = {in2 = in2, in3 = labels[1]}})
              jump_to_21(only.pos)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif (nil ~= _389_) then
            local sublist = _389_
            local _let_392_ = sublist
            local first = _let_392_[1]
            local rest = {(table.unpack or unpack)(_let_392_, 2)}
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
              local _395_
              local function _396_()
                if (dot_repeat_3f and self.state.dot.in3) then
                  return {self.state.dot.in3, 0}
                end
              end
              local function _397_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
              _395_ = (_396_() or select_match_group(labeled_targets) or _397_())
              if ((type(_395_) == "table") and (nil ~= (_395_)[1]) and (nil ~= (_395_)[2])) then
                local in3 = (_395_)[1]
                local group_offset = (_395_)[2]
                local _399_
                local function _401_()
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
                _399_ = (get_target_with_active_primary_label(labeled_targets, in3) or _401_())
                if (nil ~= _399_) then
                  local target = _399_
                  do
                    local _402_
                    if (group_offset > 0) then
                      _402_ = nil
                    else
                      _402_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _402_}})
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
    local _let_412_ = vim.split(opt, ".", true)
    local _0 = _let_412_[1]
    local scope = _let_412_[2]
    local name = _let_412_[3]
    local _413_
    if (opt == "vim.wo.scrolloff") then
      _413_ = api.nvim_eval("&l:scrolloff")
    else
      _413_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _413_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_415_ = vim.split(opt, ".", true)
    local _ = _let_415_[1]
    local scope = _let_415_[2]
    local name = _let_415_[3]
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
  for _, _416_ in ipairs(plug_keys) do
    local _each_417_ = _416_
    local lhs = _each_417_[1]
    local rhs_call = _each_417_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _418_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_419_ = _418_
    local lhs = _each_419_[1]
    local rhs_call = _each_419_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _420_ in ipairs(default_keymaps) do
    local _each_421_ = _420_
    local mode = _each_421_[1]
    local lhs = _each_421_[2]
    local rhs = _each_421_[3]
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
