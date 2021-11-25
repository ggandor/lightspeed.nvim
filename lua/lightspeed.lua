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
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _141_
  local getchar_timeout
  local function _142_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    end
  end
  getchar_timeout = _142_
  local ok_3f, ch = nil, nil
  local function _144_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_144_())
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
  local _151_
  do
    local _150_ = repeat_invoc
    if (_150_ == "dot") then
      _151_ = "dotrepeat_"
    else
      local _ = _150_
      _151_ = ""
    end
  end
  local _156_
  do
    local _155_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_155_) == "table") and ((_155_)[1] == "ft") and ((_155_)[2] == false) and ((_155_)[3] == false)) then
      _156_ = "f"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "ft") and ((_155_)[2] == true) and ((_155_)[3] == false)) then
      _156_ = "F"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "ft") and ((_155_)[2] == false) and ((_155_)[3] == true)) then
      _156_ = "t"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "ft") and ((_155_)[2] == true) and ((_155_)[3] == true)) then
      _156_ = "T"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "sx") and ((_155_)[2] == false) and ((_155_)[3] == false)) then
      _156_ = "s"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "sx") and ((_155_)[2] == true) and ((_155_)[3] == false)) then
      _156_ = "S"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "sx") and ((_155_)[2] == false) and ((_155_)[3] == true)) then
      _156_ = "x"
    elseif ((type(_155_) == "table") and ((_155_)[1] == "sx") and ((_155_)[2] == true) and ((_155_)[3] == true)) then
      _156_ = "X"
    else
    _156_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _151_ .. _156_)
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
  local _let_168_ = map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_168_[1]
  local revert_key = _let_168_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("ft", reverse_3f, t_mode_3f, "dot"))
  local reset_instant_state
  local function _169_()
    self.state.instant = {["in"] = nil, stack = {}}
    return nil
  end
  reset_instant_state = _169_
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _172_
  if instant_repeat_3f then
    _172_ = self.state.instant["in"]
  elseif dot_repeat_3f then
    _172_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _172_ = self.state.cold["in"]
  else
    local _173_
    local function _174_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _175_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _173_ = (_174_() or _175_())
    if (_173_ == "\13") then
      local function _177_()
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
      _172_ = (self.state.cold["in"] or _177_())
    elseif (nil ~= _173_) then
      local _in = _173_
      _172_ = _in
    else
    _172_ = nil
    end
  end
  if (nil ~= _172_) then
    local in1 = _172_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f, ["t-mode?"] = t_mode_3f}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _182_()
        if reverse_3f then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _182_())
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
      for _185_ in onscreen_match_positions(pattern, reverse_3f, {["ft-search?"] = true, limit = limit}) do
        local _each_186_ = _185_
        local line = _each_186_[1]
        local col = _each_186_[2]
        local pos = _each_186_
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
          local function _192_()
            if reverse_3f then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_192_())
        end
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f and true) then
            local _194_ = string.sub(vim.fn.mode("t"), -1)
            if (_194_ == "v") then
              push_cursor_21("bwd")
            elseif (_194_ == "o") then
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
        local _201_
        local function _202_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _203_()
          do
            reset_instant_state()
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _201_ = (_202_() or _203_())
        if (nil ~= _201_) then
          local in2 = _201_
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
              local _206_ = table.remove(self.state.instant.stack)
              if (nil ~= _206_) then
                local old_pos = _206_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(self.state.instant.stack, get_cursor_pos())
            end
            local function _209_()
              if revert_3f then
                return "reverted-instant"
              else
                return "instant"
              end
            end
            return ft:go(reverse_3f, t_mode_3f, _209_())
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
  local function _215_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _215_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_217_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_217_[1]
  local right_bound = _let_217_[2]
  local _let_218_ = get_cursor_pos()
  local curline = _let_218_[1]
  local curcol = _let_218_[2]
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
        local _222_
        do
          local _221_ = unique_chars[ch]
          if (nil ~= _221_) then
            local pos_already_there = _221_
            _222_ = false
          else
            local _ = _221_
            _222_ = {lnum, col}
          end
        end
        unique_chars[ch] = _222_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _227_ = pos
    if ((type(_227_) == "table") and (nil ~= (_227_)[1]) and (nil ~= (_227_)[2])) then
      local lnum = (_227_)[1]
      local col = (_227_)[2]
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
  for _229_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_230_ = _229_
    local line = _each_230_[1]
    local col = _each_230_[2]
    local pos = _each_230_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local before_eol_3f = (ch2 == "\13")
    local overlaps_prev_match_3f
    local _231_
    if reverse_3f then
      _231_ = dec
    else
      _231_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _231_(prev_match.col)))
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
        local _233_ = prev_target
        if ((type(_233_) == "table") and ((type((_233_).pos) == "table") and (nil ~= ((_233_).pos)[1]) and (nil ~= ((_233_).pos)[2]))) then
          local prev_line = ((_233_).pos)[1]
          local prev_col = ((_233_).pos)[2]
          local function _235_()
            local col_delta
            if reverse_3f then
              col_delta = (prev_col - col)
            else
              col_delta = (col - prev_col)
            end
            return (col_delta <= match_width)
          end
          touches_prev_target_3f = ((line == prev_line) and _235_())
        else
        touches_prev_target_3f = nil
        end
      end
      if before_eol_3f then
        target["squeezed?"] = true
      end
      if touches_prev_target_3f then
        local _238_
        if reverse_3f then
          _238_ = target
        else
          _238_ = prev_target
        end
        _238_["squeezed?"] = true
      end
      if overlaps_prev_target_3f then
        local _241_
        if reverse_3f then
          _241_ = prev_target
        else
          _241_ = target
        end
        _241_["overlapped?"] = true
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
  for _, _246_ in ipairs(targets) do
    local _each_247_ = _246_
    local target = _each_247_
    local _each_248_ = _each_247_["pair"]
    local _0 = _each_248_[1]
    local ch2 = _each_248_[2]
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
    local _252_ = sublist["autojump?"]
    if (_252_ == true) then
      return opts.safe_labels
    elseif (_252_ == false) then
      return opts.labels
    elseif (_252_ == nil) then
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
        local _255_
        if not (sublist["autojump?"] and (i == 1)) then
          local _256_
          local _258_
          if sublist["autojump?"] then
            _258_ = dec(i)
          else
            _258_ = i
          end
          _256_ = (_258_ % #labels)
          if (_256_ == 0) then
            _255_ = last(labels)
          elseif (nil ~= _256_) then
            local n = _256_
            _255_ = labels[n]
          else
          _255_ = nil
          end
        else
        _255_ = nil
        end
        target["label"] = _255_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _265_)
  local _arg_266_ = _265_
  local group_offset = _arg_266_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _267_
  if sublist["autojump?"] then
    _267_ = 2
  else
    _267_ = 1
  end
  primary_start = (offset + _267_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _269_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _269_ = "inactive"
      elseif (i <= primary_end) then
        _269_ = "active-primary"
      else
        _269_ = "active-secondary"
      end
    else
    _269_ = nil
    end
    target["label-state"] = _269_
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
      local _272_, _273_ = ch2, true
      if ((nil ~= _272_) and (nil ~= _273_)) then
        local k_10_auto = _272_
        local v_11_auto = _273_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _275_ in ipairs(targets) do
    local _each_276_ = _275_
    local target = _each_276_
    local label = _each_276_["label"]
    local label_state = _each_276_["label-state"]
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
local function set_beacon(_279_, repeat_3f)
  local _arg_280_ = _279_
  local target = _arg_280_
  local label = _arg_280_["label"]
  local label_state = _arg_280_["label-state"]
  local overlapped_3f = _arg_280_["overlapped?"]
  local _arg_281_ = _arg_280_["pair"]
  local ch1 = _arg_281_[1]
  local ch2 = _arg_281_[2]
  local _arg_282_ = _arg_280_["pos"]
  local _ = _arg_282_[1]
  local col = _arg_282_[2]
  local shortcut_3f = _arg_280_["shortcut?"]
  local squeezed_3f = _arg_280_["squeezed?"]
  local function _284_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_283_ = map(_284_, {ch1, ch2})
  local ch10 = _let_283_[1]
  local ch20 = _let_283_[2]
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _285_ = label_state
    if (_285_ == nil) then
      if overlapped_3f then
        target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
      else
        target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
      end
    elseif (_285_ == "active-primary") then
      if repeat_3f then
        local _287_
        if squeezed_3f then
          _287_ = 1
        else
          _287_ = 2
        end
        target.beacon = {_287_, {label_24}}
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
    elseif (_285_ == "active-secondary") then
      if repeat_3f then
        local _292_
        if squeezed_3f then
          _292_ = 1
        else
          _292_ = 2
        end
        target.beacon = {_292_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_285_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _296_)
  local _arg_297_ = _296_
  local repeat_3f = _arg_297_["repeat?"]
  for _, target in ipairs(target_list) do
    set_beacon(target, repeat_3f)
  end
  return nil
end
local function light_up_beacons(target_list)
  for _, _298_ in ipairs(target_list) do
    local _each_299_ = _298_
    local beacon = _each_299_["beacon"]
    local _each_300_ = _each_299_["pos"]
    local line = _each_300_[1]
    local col = _each_300_[2]
    local _301_ = beacon
    if ((type(_301_) == "table") and (nil ~= (_301_)[1]) and (nil ~= (_301_)[2])) then
      local offset = (_301_)[1]
      local chunks = (_301_)[2]
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _303_ in ipairs(target_list) do
    local _each_304_ = _303_
    local target = _each_304_
    local label = _each_304_["label"]
    local label_state = _each_304_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _306_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _306_) then
    local input = _306_
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
      local _309_
      local function _310_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _311_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _309_ = (_310_() or _311_())
      if (nil ~= _309_) then
        local in0 = _309_
        local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
        do
          local _313_ = in0
          if (_313_ == "\13") then
            enter_repeat_3f = true
          elseif (_313_ == x_mode_prefix_key) then
            x_mode_3f = true
          end
        end
        local res = in0
        if (x_mode_3f and not invoked_in_x_mode_3f) then
          local _315_
          local function _316_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _315_ = (get_input() or _316_())
          if (_315_ == "\13") then
            enter_repeat_3f = true
          elseif (nil ~= _315_) then
            local in0_2a = _315_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or enter_repeat_3f)
        if enter_repeat_3f then
          local function _320_()
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
          return (self.state.cold.in1 or _320_())
        else
          return res
        end
      end
    end
  end
  local function update_state_2a(in1)
    local function _327_(_325_)
      local _arg_326_ = _325_
      local cold = _arg_326_["cold"]
      local dot = _arg_326_["dot"]
      if new_search_3f then
        if cold then
          local _328_ = cold
          _328_["in1"] = in1
          _328_["x-mode?"] = x_mode_3f
          _328_["reverse?"] = reverse_3f
          self.state.cold = _328_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _330_ = dot
              _330_["in1"] = in1
              _330_["x-mode?"] = x_mode_3f
              self.state.dot = _330_
            end
            return nil
          end
        end
      end
    end
    return _327_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _334_(target)
      local adjusted_pos
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
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f and (x_mode_3f and not reverse_3f)) then
            local _338_ = string.sub(vim.fn.mode("t"), -1)
            if (_338_ == "v") then
              push_cursor_21("bwd")
            elseif (_338_ == "o") then
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
    jump_to_21 = _334_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local forced_motion = string.sub(vim.fn.mode("t"), -1)
    local blockwise_3f = (forced_motion == replace_keycodes("<c-v>"))
    local function _344_()
      if reverse_3f then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_343_ = _344_()
    local startline = _let_343_[1]
    local startcol = _let_343_[2]
    local start = _let_343_
    local function _346_()
      if reverse_3f then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_345_ = _346_()
    local _ = _let_345_[1]
    local endcol = _let_345_[2]
    local _end = _let_345_
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
      highlight_range(hl.group["pending-op-area"], map(dec, start), map(dec, _end), {["forced-motion"] = forced_motion, ["inclusive-motion?"] = (x_mode_3f and not reverse_3f)})
    end
    return vim.cmd("redraw")
  end
  local function get_sublist(targets, ch)
    local _351_ = targets.sublists[ch]
    if (nil ~= _351_) then
      local sublist = _351_
      local _let_352_ = sublist
      local _let_353_ = _let_352_[1]
      local _let_354_ = _let_353_["pos"]
      local line = _let_354_[1]
      local col = _let_354_[2]
      local rest = {(table.unpack or unpack)(_let_352_, 2)}
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
          for _, _359_ in ipairs(target_list) do
            local _each_360_ = _359_
            local _each_361_ = _each_360_["pos"]
            local line = _each_361_[1]
            local col = _each_361_[2]
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), inc(col))
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local function _362_()
        local res_2_auto
        do
          res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
        end
        hl:cleanup()
        return res_2_auto
      end
      return vim.fn.feedkeys((_362_() or ""), "i")
    end
  end
  local function get_last_input(sublist)
    local _local_364_ = map(replace_keycodes, {opts.cycle_group_fwd_key, opts.cycle_group_bwd_key})
    local cycle_fwd_key = _local_364_[1]
    local cycle_bwd_key = _local_364_[2]
    local function recur(group_offset, initial_invoc_3f)
      set_beacons(sublist, {["repeat?"] = enter_repeat_3f})
      do
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f)
        end
        do
          light_up_beacons(sublist)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _366_
      do
        local res_2_auto
        do
          local function _367_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_367_())
        end
        hl:cleanup()
        _366_ = res_2_auto
      end
      if (nil ~= _366_) then
        local input = _366_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _369_
          do
            local _368_ = input
            if (_368_ == cycle_fwd_key) then
              _369_ = inc
            else
              local _ = _368_
              _369_ = dec
            end
          end
          group_offset_2a = clamp(_369_(group_offset), 0, max_offset)
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
  local _378_ = get_first_input()
  if (nil ~= _378_) then
    local in1 = _378_
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
    local _380_
    local function _381_()
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
    _380_ = (get_targets(in1, reverse_3f) or _381_())
    if ((type(_380_) == "table") and ((type((_380_)[1]) == "table") and ((type(((_380_)[1]).pair) == "table") and true and (nil ~= (((_380_)[1]).pair)[2]))) and ((_380_)[2] == nil)) then
      local _ = (((_380_)[1]).pair)[1]
      local ch2 = (((_380_)[1]).pair)[2]
      local only = (_380_)[1]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f, x_mode_3f, "dot")))
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
    elseif (nil ~= _380_) then
      local targets = _380_
      do
        local _387_ = targets
        populate_sublists(_387_)
        set_labels(_387_)
        set_label_states(_387_)
      end
      if new_search_3f then
        do
          local _388_ = targets
          set_shortcuts_and_populate_shortcuts_map(_388_)
          set_beacons(_388_, {["repeat?"] = false})
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
      local _391_
      local function _392_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _393_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _391_ = (prev_in2 or _392_() or _393_())
      if (nil ~= _391_) then
        local in2 = _391_
        local _395_
        do
          local t_396_ = targets.shortcuts
          if (nil ~= t_396_) then
            t_396_ = (t_396_)[in2]
          end
          _395_ = t_396_
        end
        if ((type(_395_) == "table") and ((type((_395_).pair) == "table") and true and (nil ~= ((_395_).pair)[2]))) then
          local _ = ((_395_).pair)[1]
          local ch2 = ((_395_).pair)[2]
          local shortcut = _395_
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f, x_mode_3f, "dot")))
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut.pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _395_
          update_state({cold = {in2 = in2}})
          local _399_
          local function _400_()
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
          _399_ = (get_sublist(targets, in2) or _400_())
          if ((type(_399_) == "table") and (nil ~= (_399_)[1]) and ((_399_)[2] == nil)) then
            local only = (_399_)[1]
            do
              if dot_repeatable_op_3f then
                set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f, x_mode_3f, "dot")))
              end
              update_state({dot = {in2 = in2, in3 = opts.labels[1]}})
              jump_to_21(only.pos)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif (nil ~= _399_) then
            local sublist = _399_
            local _let_403_ = sublist
            local first = _let_403_[1]
            local rest = {(table.unpack or unpack)(_let_403_, 2)}
            local autojump_3f = sublist["autojump?"]
            if (autojump_3f or cold_repeat_3f) then
              jump_to_21(first.pos)
            end
            if cold_repeat_3f then
              do
                if dot_repeatable_op_3f then
                  set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f, x_mode_3f, "dot")))
                end
                after_cold_repeat(rest)
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            else
              local _406_
              local function _407_()
                if (dot_repeat_3f and self.state.dot.in3) then
                  return {self.state.dot.in3, 0}
                end
              end
              local function _408_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
              _406_ = (_407_() or get_last_input(sublist) or _408_())
              if ((type(_406_) == "table") and (nil ~= (_406_)[1]) and (nil ~= (_406_)[2])) then
                local in3 = (_406_)[1]
                local group_offset = (_406_)[2]
                local _410_
                local function _413_()
                  if autojump_3f then
                    do
                      if dot_repeatable_op_3f then
                        set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f, x_mode_3f, "dot")))
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
                _410_ = (get_target_with_active_primary_label(sublist, in3) or _413_())
                if (nil ~= _410_) then
                  local target = _410_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f, x_mode_3f, "dot")))
                    end
                    local _415_
                    if (group_offset > 0) then
                      _415_ = nil
                    else
                      _415_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _415_}})
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
    local _let_425_ = vim.split(opt, ".", true)
    local _0 = _let_425_[1]
    local scope = _let_425_[2]
    local name = _let_425_[3]
    local _426_
    if (opt == "vim.wo.scrolloff") then
      _426_ = api.nvim_eval("&l:scrolloff")
    else
      _426_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _426_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_428_ = vim.split(opt, ".", true)
    local _ = _let_428_[1]
    local scope = _let_428_[2]
    local name = _let_428_[3]
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
  for _, _429_ in ipairs(plug_keys) do
    local _each_430_ = _429_
    local lhs = _each_430_[1]
    local rhs_call = _each_430_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _431_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_432_ = _431_
    local lhs = _each_432_[1]
    local rhs_call = _each_432_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _433_ in ipairs(default_keymaps) do
    local _each_434_ = _433_
    local mode = _each_434_[1]
    local lhs = _each_434_[2]
    local rhs = _each_434_[3]
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
