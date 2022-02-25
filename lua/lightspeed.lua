local api = vim.api
local contains_3f = vim.tbl_contains
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local abs = math.abs
local ceil = math.ceil
local max = math.max
local min = math.min
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
  else
    return nil
  end
end
local function last(tbl)
  return tbl[#tbl]
end
local function echo(msg)
  vim.cmd("redraw")
  return api.nvim_echo({{msg}}, false, {})
end
local function replace_keycodes(s)
  return api.nvim_replace_termcodes(s, true, false, true)
end
local _3cbackspace_3e = replace_keycodes("<bs>")
local _3cctrl_v_3e = replace_keycodes("<c-v>")
local function get_motion_force(mode)
  local _2_
  if mode:match("o") then
    _2_ = mode:sub(-1)
  else
    _2_ = nil
  end
  if (nil ~= _2_) then
    local last_ch = _2_
    if ((last_ch == _3cctrl_v_3e) or (last_ch == "V") or (last_ch == "v")) then
      return last_ch
    else
      return nil
    end
  else
    return nil
  end
end
local function operator_pending_mode_3f()
  return string.match(api.nvim_get_mode().mode, "o")
end
local function change_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "c"))
end
local function get_cursor_pos()
  return {vim.fn.line("."), vim.fn.col(".")}
end
local function same_pos_3f(_6_, _8_)
  local _arg_7_ = _6_
  local l1 = _arg_7_[1]
  local c1 = _arg_7_[2]
  local _arg_9_ = _8_
  local l2 = _arg_9_[1]
  local c2 = _arg_9_[2]
  return ((l1 == l2) and (c1 == c2))
end
local function char_at_pos(_10_, _12_)
  local _arg_11_ = _10_
  local line = _arg_11_[1]
  local byte_col = _arg_11_[2]
  local _arg_13_ = _12_
  local char_offset = _arg_13_["char-offset"]
  local line_str = vim.fn.getline(line)
  local char_idx = vim.fn.charidx(line_str, dec(byte_col))
  local char_nr = vim.fn.strgetchar(line_str, (char_idx + (char_offset or 0)))
  if (char_nr ~= -1) then
    return vim.fn.nr2char(char_nr)
  else
    return nil
  end
end
local function leftmost_editable_wincol()
  local view = vim.fn.winsaveview()
  vim.cmd("norm! 0")
  local wincol = vim.fn.wincol()
  vim.fn.winrestview(view)
  if ("\9" == string.sub(vim.fn.getline("."), 1, 1)) then
    return (wincol - dec(vim.o.tabstop))
  else
    return wincol
  end
end
local function get_fold_edge(lnum, reverse_3f)
  local _16_
  local _17_
  if reverse_3f then
    _17_ = vim.fn.foldclosed
  else
    _17_ = vim.fn.foldclosedend
  end
  _16_ = _17_(lnum)
  if (_16_ == -1) then
    return nil
  elseif (nil ~= _16_) then
    local fold_edge = _16_
    return fold_edge
  else
    return nil
  end
end
local function maparg_expr(name, mode)
  local rhs = vim.fn.maparg(name, mode)
  local ok_3f, eval_rhs = pcall(vim.fn.eval, rhs)
  if (ok_3f and (type(eval_rhs) == "string")) then
    return eval_rhs
  else
    return rhs
  end
end
local function highlight_range_compat(bufnr, ns, higroup, start, finish, opts)
  if (1 == vim.fn.has("nvim-0.7")) then
    return vim.highlight.range(bufnr, ns, higroup, start, finish, opts)
  else
    return vim.highlight.range(bufnr, ns, higroup, start, finish, opts.regtype, opts.inclusive, opts.priority)
  end
end
local opts
do
  local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  local labels = {"s", "f", "n", "j", "k", "l", "o", "d", "w", "e", "h", "m", "v", "g", "u", "t", "c", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  opts = {ignore_case = false, exit_after_idle_msecs = {labeled = nil, unlabeled = 1000}, jump_to_unique_chars = {safety_timeout = 400}, match_only_the_start_of_same_char_seqs = true, substitute_chars = {["\13"] = "\194\172"}, force_beacons_into_match_width = false, safe_labels = safe_labels, labels = labels, special_keys = {next_match_group = "<space>", prev_match_group = "<tab>"}, limit_ft_matches = 4, repeat_ft_with_target_char = false}
end
local removed_opts = {"jump_to_first_match", "instant_repeat_fwd_key", "instant_repeat_bwd_key", "x_mode_prefix_key", "full_inclusive_prefix_key", "grey_out_search_area", "highlight_unique_chars", "jump_on_partial_input_safety_timeout", "cycle_group_fwd_key", "cycle_group_bwd_key"}
local function get_warning_msg(arg_fields)
  local msg = {{"ligthspeed.nvim\n", "Question"}, {"The following fields in the "}, {"opts", "Visual"}, {" table has been renamed or removed:\n\n"}}
  local field_names
  do
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for _, field in ipairs(arg_fields) do
      local val_17_auto = {("\9" .. field .. "\n")}
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    field_names = tbl_15_auto
  end
  local msg_for_jump_to_first_match = {{"The plugin implements \"smart\" auto-jump now, that you can fine-tune via "}, {"opts.labels", "Visual"}, {" and "}, {"opts.safe_labels", "Visual"}, {". See "}, {":h lightspeed-config", "Visual"}, {" for details."}}
  local msg_for_instant_repeat_keys = {{"There are dedicated "}, {"<Plug>", "Visual"}, {" keys available for native-like "}, {";", "Visual"}, {" and "}, {",", "Visual"}, {" functionality now, "}, {"that can also be used for instant repeat only, if you prefer. See "}, {":h lightspeed-custom-mappings", "Visual"}, {"."}}
  local msg_for_x_prefix = {{"Use "}, {"<Plug>Lightspeed_x", "Visual"}, {" and "}, {"<Plug>Lightspeed_X", "Visual"}, {" instead."}}
  local msg_for_grey_out = {{"This flag has been removed. To turn the 'greywash' feature off, "}, {"just set all attributes of the corresponding highlight group to 'none': "}, {":hi LightspeedGreywash guifg=none guibg=none ...", "Visual"}}
  local msg_for_hl_unique_chars = {{"Use "}, {"jump_to_unique_chars", "Visual"}, {" instead. See "}, {":h lightspeed-config", "Visual"}, {" for details."}}
  local msg_for_cycle_keys = {{"Use the "}, {"opts.special_keys", "Visual"}, {" table instead. See "}, {":h lightspeed-config", "Visual"}, {" for details."}}
  local spec_messages = {jump_to_first_match = msg_for_jump_to_first_match, instant_repeat_fwd_key = msg_for_instant_repeat_keys, instant_repeat_bwd_key = msg_for_instant_repeat_keys, x_mode_prefix_key = msg_for_x_prefix, full_inclusive_prefix_key = msg_for_x_prefix, grey_out_search_area = msg_for_grey_out, highlight_unique_chars = msg_for_hl_unique_chars, jump_on_partial_input_safety_timeout = msg_for_hl_unique_chars, cycle_group_fwd_key = msg_for_cycle_keys, cycle_group_bwd_key = msg_for_cycle_keys}
  for _, field_name_chunk in ipairs(field_names) do
    table.insert(msg, field_name_chunk)
  end
  table.insert(msg, {"\n"})
  for field, spec_msg in pairs(spec_messages) do
    if contains_3f(arg_fields, field) then
      table.insert(msg, {(field .. "\n"), "IncSearch"})
      for _, chunk in ipairs(spec_msg) do
        table.insert(msg, chunk)
      end
      table.insert(msg, {"\n\n"})
    else
    end
  end
  return msg
end
do
  local guard
  local function _24_(t, k)
    if contains_3f(removed_opts, k) then
      return api.nvim_echo(get_warning_msg({k}), true, {})
    else
      return nil
    end
  end
  guard = _24_
  setmetatable(opts, {__index = guard, __newindex = guard})
end
local function normalize_opts(opts0)
  local removed_arg_opts = {}
  for k, v in pairs(opts0) do
    if contains_3f(removed_opts, k) then
      table.insert(removed_arg_opts, k)
      do end (opts0)[k] = nil
    else
    end
  end
  if not empty_3f(removed_arg_opts) then
    api.nvim_echo(get_warning_msg(removed_arg_opts), true, {})
  else
  end
  return opts0
end
local function setup(user_opts)
  opts = setmetatable(normalize_opts(user_opts), {__index = opts})
  return nil
end
local hl
local function _28_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  else
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {group = {label = "LightspeedLabel", ["label-distant"] = "LightspeedLabelDistant", ["label-overlapped"] = "LightspeedLabelOverlapped", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", shortcut = "LightspeedShortcut", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", ["one-char-match"] = "LightspeedOneCharMatch", ["unique-ch"] = "LightspeedUniqueChar", ["pending-op-area"] = "LightspeedPendingOpArea", greywash = "LightspeedGreyWash", cursor = "LightspeedCursor"}, priority = {cursor = 65535, label = 65534, greywash = 65533}, ns = api.nvim_create_namespace(""), cleanup = _28_}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _31_
  do
    local _30_ = bg
    if (_30_ == "light") then
      _31_ = "#f02077"
    elseif true then
      local _ = _30_
      _31_ = "#ff2f87"
    else
      _31_ = nil
    end
  end
  local _36_
  do
    local _35_ = bg
    if (_35_ == "light") then
      _36_ = "#ff4090"
    elseif true then
      local _ = _35_
      _36_ = "#e01067"
    else
      _36_ = nil
    end
  end
  local _41_
  do
    local _40_ = bg
    if (_40_ == "light") then
      _41_ = "#399d9f"
    elseif true then
      local _ = _40_
      _41_ = "#99ddff"
    else
      _41_ = nil
    end
  end
  local _46_
  do
    local _45_ = bg
    if (_45_ == "light") then
      _46_ = "Blue"
    elseif true then
      local _ = _45_
      _46_ = "Cyan"
    else
      _46_ = nil
    end
  end
  local _51_
  do
    local _50_ = bg
    if (_50_ == "light") then
      _51_ = "#59bdbf"
    elseif true then
      local _ = _50_
      _51_ = "#79bddf"
    else
      _51_ = nil
    end
  end
  local _56_
  do
    local _55_ = bg
    if (_55_ == "light") then
      _56_ = "Cyan"
    elseif true then
      local _ = _55_
      _56_ = "Blue"
    else
      _56_ = nil
    end
  end
  local _61_
  do
    local _60_ = bg
    if (_60_ == "light") then
      _61_ = "#cc9999"
    elseif true then
      local _ = _60_
      _61_ = "#b38080"
    else
      _61_ = nil
    end
  end
  local _66_
  do
    local _65_ = bg
    if (_65_ == "light") then
      _66_ = "#272020"
    elseif true then
      local _ = _65_
      _66_ = "#f3ecec"
    else
      _66_ = nil
    end
  end
  local _71_
  do
    local _70_ = bg
    if (_70_ == "light") then
      _71_ = "Black"
    elseif true then
      local _ = _70_
      _71_ = "White"
    else
      _71_ = nil
    end
  end
  groupdefs = {{hl.group.label, {guifg = _31_, ctermfg = "Red", guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["label-overlapped"], {guifg = _36_, ctermfg = "Magenta", guibg = "NONE", ctermbg = "NONE", gui = "underline", cterm = "underline"}}, {hl.group["label-distant"], {guifg = _41_, ctermfg = _46_, guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["label-distant-overlapped"], {guifg = _51_, ctermfg = _56_, gui = "underline", cterm = "underline"}}, {hl.group.shortcut, {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["one-char-match"], {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold", cterm = "bold"}}, {hl.group["masked-ch"], {guifg = _61_, ctermfg = "DarkGrey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}}, {hl.group["unlabeled-match"], {guifg = _66_, ctermfg = _71_, guibg = "NONE", ctermbg = "NONE", gui = "bold", cterm = "bold"}}, {hl.group["pending-op-area"], {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White"}}, {hl.group.greywash, {guifg = "#777777", ctermfg = "Grey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}}}
  for _, _75_ in ipairs(groupdefs) do
    local _each_76_ = _75_
    local group = _each_76_[1]
    local attrs = _each_76_[2]
    local attrs_str
    local _77_
    do
      local tbl_15_auto = {}
      local i_16_auto = #tbl_15_auto
      for k, v in pairs(attrs) do
        local val_17_auto = (k .. "=" .. v)
        if (nil ~= val_17_auto) then
          i_16_auto = (i_16_auto + 1)
          do end (tbl_15_auto)[i_16_auto] = val_17_auto
        else
        end
      end
      _77_ = tbl_15_auto
    end
    attrs_str = table.concat(_77_, " ")
    local function _79_()
      if force_3f then
        return ""
      else
        return "default "
      end
    end
    vim.cmd(("highlight " .. _79_() .. group .. " " .. attrs_str))
  end
  for _, _80_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_81_ = _80_
    local from_group = _each_81_[1]
    local to_group = _each_81_[2]
    local function _82_()
      if force_3f then
        return ""
      else
        return "default "
      end
    end
    vim.cmd(("highlight " .. _82_() .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f, _3ftarget_windows, omni_3f)
  if (_3ftarget_windows or omni_3f) then
    for _, win in ipairs((_3ftarget_windows or {vim.fn.getwininfo(vim.fn.win_getid())[1]})) do
      highlight_range_compat(win.bufnr, hl.ns, hl.group.greywash, {dec(win.topline), 0}, {dec(win.botline), -1}, {regtype = "v", inclusive = false, priority = hl.priority.greywash})
    end
    return nil
  else
    local _let_83_ = map(dec, get_cursor_pos())
    local curline = _let_83_[1]
    local curcol = _let_83_[2]
    local _let_84_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
    local win_top = _let_84_[1]
    local win_bot = _let_84_[2]
    local function _86_()
      if reverse_3f then
        return {{win_top, 0}, {curline, curcol}}
      else
        return {{curline, inc(curcol)}, {win_bot, -1}}
      end
    end
    local _let_85_ = _86_()
    local start = _let_85_[1]
    local finish = _let_85_[2]
    return highlight_range_compat(0, hl.ns, hl.group.greywash, start, finish, {regtype = "v"}, {inclusive = false}, {priority = hl.priority.greywash})
  end
end
local function highlight_range(hl_group, _88_, _90_, _92_)
  local _arg_89_ = _88_
  local startline = _arg_89_[1]
  local startcol = _arg_89_[2]
  local start = _arg_89_
  local _arg_91_ = _90_
  local endline = _arg_91_[1]
  local endcol = _arg_91_[2]
  local _end = _arg_91_
  local _arg_93_ = _92_
  local motion_force = _arg_93_["motion-force"]
  local inclusive_motion_3f = _arg_93_["inclusive-motion?"]
  local hl_range
  local function _94_(start0, _end0, end_inclusive_3f)
    return highlight_range_compat(0, hl.ns, hl_group, start0, _end0, {regtype = "v", inclusive = end_inclusive_3f, priority = hl.priority.label})
  end
  hl_range = _94_
  local _95_ = motion_force
  if (_95_ == _3cctrl_v_3e) then
    local _let_96_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_96_[1]
    local endcol0 = _let_96_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_95_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_95_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  elseif (_95_ == nil) then
    return hl_range(start, _end, inclusive_motion_3f)
  else
    return nil
  end
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local function _99_()
    local _98_ = direction
    if (_98_ == "fwd") then
      return "W"
    elseif (_98_ == "bwd") then
      return "bW"
    else
      return nil
    end
  end
  return vim.fn.search("\\_.", _99_())
end
local function get_restore_virtualedit_autocmd()
  return ("autocmd " .. "CursorMoved,WinLeave,BufLeave,InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function jump_to_21_2a(target, _101_)
  local _arg_102_ = _101_
  local mode = _arg_102_["mode"]
  local reverse_3f = _arg_102_["reverse?"]
  local inclusive_motion_3f = _arg_102_["inclusive-motion?"]
  local add_to_jumplist_3f = _arg_102_["add-to-jumplist?"]
  local adjust = _arg_102_["adjust"]
  local op_mode_3f = string.match(mode, "o")
  local motion_force = get_motion_force(mode)
  local restore_virtualedit_autocmd = get_restore_virtualedit_autocmd()
  if add_to_jumplist_3f then
    vim.cmd("norm! m`")
  else
  end
  vim.fn.cursor(target)
  adjust()
  if not op_mode_3f then
    force_matchparen_refresh()
  else
  end
  local adjusted_pos = get_cursor_pos()
  if (op_mode_3f and not reverse_3f and inclusive_motion_3f) then
    local _105_ = motion_force
    if (_105_ == nil) then
      if not cursor_before_eof_3f() then
        push_cursor_21("fwd")
      else
        vim.cmd("set virtualedit=onemore")
        vim.cmd("norm! l")
        vim.cmd(restore_virtualedit_autocmd)
      end
    elseif (_105_ == "V") then
    elseif (_105_ == _3cctrl_v_3e) then
    elseif (_105_ == "v") then
      push_cursor_21("bwd")
    else
    end
  else
  end
  return adjusted_pos
end
local function get_onscreen_lines(_109_)
  local _arg_110_ = _109_
  local get_full_window_3f = _arg_110_["get-full-window?"]
  local reverse_3f = _arg_110_["reverse?"]
  local skip_folds_3f = _arg_110_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum
  if get_full_window_3f then
    if reverse_3f then
      lnum = winbot
    else
      lnum = wintop
    end
  else
    lnum = vim.fn.line(".")
  end
  while true do
    local _113_
    if reverse_3f then
      _113_ = (lnum >= wintop)
    else
      _113_ = (lnum <= winbot)
    end
    if not _113_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _115_
      if reverse_3f then
        _115_ = dec
      else
        _115_ = inc
      end
      lnum = _115_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _117_
      if reverse_3f then
        _117_ = dec
      else
        _117_ = inc
      end
      lnum = _117_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_120_)
  local _arg_121_ = _120_
  local match_width = _arg_121_["match-width"]
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = dec(vim.fn.wincol())
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - offset_in_editable_win)
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _122_)
  local _arg_123_ = _122_
  local cross_window_3f = _arg_123_["cross-window?"]
  local to_eol_3f = _arg_123_["to-eol?"]
  local ft_search_3f = _arg_123_["ft-search?"]
  local limit = _arg_123_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local stopline
  if reverse_3f then
    stopline = wintop
  else
    stopline = winbot
  end
  local cleanup
  local function _126_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _126_
  local _128_
  if ft_search_3f then
    _128_ = 1
  else
    _128_ = 2
  end
  local _let_127_ = get_horizontal_bounds({["match-width"] = _128_})
  local left_bound = _let_127_[1]
  local right_bound = _let_127_[2]
  local function reach_right_bound()
    while ((vim.fn.virtcol(".") < right_bound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
      vim.cmd("norm! l")
    end
    return nil
  end
  local function skip_to_fold_edge_21()
    local _130_
    local _131_
    if reverse_3f then
      _131_ = vim.fn.foldclosed
    else
      _131_ = vim.fn.foldclosedend
    end
    _130_ = _131_(vim.fn.line("."))
    if (_130_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _130_) then
      local fold_edge = _130_
      vim.fn.cursor(fold_edge, 0)
      local function _133_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _133_())
      return "moved-the-cursor"
    else
      return nil
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_135_ = {vim.fn.line("."), vim.fn.virtcol(".")}
    local line = _local_135_[1]
    local virtcol = _local_135_[2]
    local from_pos = _local_135_
    local _136_
    if (virtcol < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _136_ = {dec(line), right_bound}
        else
          _136_ = nil
        end
      else
        _136_ = {line, left_bound}
      end
    elseif (virtcol > right_bound) then
      if reverse_3f then
        _136_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _136_ = {inc(line), left_bound}
        else
          _136_ = nil
        end
      end
    else
      _136_ = nil
    end
    if (nil ~= _136_) then
      local to_pos = _136_
      if (from_pos ~= to_pos) then
        vim.fn.cursor(to_pos)
        if reverse_3f then
          reach_right_bound()
        else
        end
        return "moved-the-cursor"
      else
        return nil
      end
    else
      return nil
    end
  end
  vim.o.cpo = cpo:gsub("c", "")
  local win_enter_3f = nil
  local match_count = 0
  if cross_window_3f then
    win_enter_3f = true
    local function _145_()
      if reverse_3f then
        return {winbot, right_bound}
      else
        return {wintop, left_bound}
      end
    end
    vim.fn.cursor(_145_())
    if reverse_3f then
      reach_right_bound()
    else
    end
  else
  end
  local function recur(match_at_curpos_3f)
    local match_at_curpos_3f0
    local function _148_()
      if win_enter_3f then
        win_enter_3f = false
        return true
      else
        return nil
      end
    end
    match_at_curpos_3f0 = (match_at_curpos_3f or _148_())
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _149_
      local function _150_()
        if match_at_curpos_3f0 then
          return "c"
        else
          return ""
        end
      end
      _149_ = vim.fn.searchpos(pattern, (opts0 .. _150_()), stopline)
      if ((_G.type(_149_) == "table") and ((_149_)[1] == 0) and true) then
        local _ = (_149_)[2]
        return cleanup()
      elseif ((_G.type(_149_) == "table") and (nil ~= (_149_)[1]) and (nil ~= (_149_)[2])) then
        local line = (_149_)[1]
        local col = (_149_)[2]
        local pos = _149_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _151_ = skip_to_fold_edge_21()
          if (_151_ == "moved-the-cursor") then
            return recur(false)
          elseif (_151_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_152_,_153_,_154_) return (_152_ <= _153_) and (_153_ <= _154_) end)(left_bound,col,right_bound) or to_eol_3f) then
              match_count = (match_count + 1)
              return {line, col, left_bound, right_bound}
            else
              local _155_ = skip_to_next_in_window_pos_21()
              if (_155_ == "moved-the-cursor") then
                return recur(true)
              elseif true then
                local _ = _155_
                return cleanup()
              else
                return nil
              end
            end
          else
            return nil
          end
        end
      else
        return nil
      end
    end
  end
  return recur
end
local function highlight_cursor(_3fpos)
  local _let_162_ = (_3fpos or get_cursor_pos())
  local line = _let_162_[1]
  local col = _let_162_[2]
  local pos = _let_162_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {virt_text = {{ch_at_curpos, hl.group.cursor}}, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.cursor})
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
  else
    return nil
  end
end
local function enter(mode)
  doau_when_exists("LightspeedEnter")
  local _165_ = mode
  if (_165_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_165_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  else
    return nil
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _167_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _167_
  local getchar_timeout
  local function _168_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    else
      return nil
    end
  end
  getchar_timeout = _168_
  local ok_3f, ch = nil, nil
  local function _170_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_170_())
  if (ok_3f and (ch ~= esc_keycode)) then
    if (type(ch) == "number") then
      return vim.fn.nr2char(ch)
    else
      return ch
    end
  else
    return nil
  end
end
local function set_dot_repeat(cmd, _3fcount)
  local op = vim.v.operator
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
local function get_plug_key(search_mode, reverse_3f, x_2ft_3f, repeat_invoc)
  local function _175_()
    local _174_ = repeat_invoc
    if (_174_ == "dot") then
      return "dotrepeat_"
    elseif true then
      local _ = _174_
      return ""
    else
      return nil
    end
  end
  local function _178_()
    local _177_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((_G.type(_177_) == "table") and ((_177_)[1] == "ft") and ((_177_)[2] == false) and ((_177_)[3] == false)) then
      return "f"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "ft") and ((_177_)[2] == true) and ((_177_)[3] == false)) then
      return "F"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "ft") and ((_177_)[2] == false) and ((_177_)[3] == true)) then
      return "t"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "ft") and ((_177_)[2] == true) and ((_177_)[3] == true)) then
      return "T"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "sx") and ((_177_)[2] == false) and ((_177_)[3] == false)) then
      return "s"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "sx") and ((_177_)[2] == true) and ((_177_)[3] == false)) then
      return "S"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "sx") and ((_177_)[2] == false) and ((_177_)[3] == true)) then
      return "x"
    elseif ((_G.type(_177_) == "table") and ((_177_)[1] == "sx") and ((_177_)[2] == true) and ((_177_)[3] == true)) then
      return "X"
    else
      return nil
    end
  end
  return ("<Plug>Lightspeed_" .. _175_() .. _178_())
end
local function get_repeat_action(_in, search_mode, x_2ft_3f, instant_repeat_3f, from_reverse_cold_repeat_3f, _3ftarget_char)
  local mode
  if (vim.fn.mode() == "n") then
    mode = "n"
  else
    mode = "x"
  end
  local in_mapped_to = maparg_expr(_in, mode)
  local repeat_plug_key = ("<Plug>Lightspeed_;_" .. search_mode)
  local revert_plug_key = ("<Plug>Lightspeed_,_" .. search_mode)
  local _181_
  if from_reverse_cold_repeat_3f then
    _181_ = revert_plug_key
  else
    _181_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _181_))) then
    return "repeat"
  else
    local _183_
    if from_reverse_cold_repeat_3f then
      _183_ = repeat_plug_key
    else
      _183_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _183_)))) then
      return "revert"
    else
      return nil
    end
  end
end
local ft = {state = {dot = {["in"] = nil}, cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}}}
ft.go = function(self, reverse_3f, t_mode_3f, repeat_invoc)
  local mode = api.nvim_get_mode().mode
  local op_mode_3f = mode:match("o")
  local dot_repeatable_op_3f = (op_mode_3f and (vim.v.operator ~= "y"))
  local instant_repeat_3f = (type(repeat_invoc) == "table")
  local instant_state
  if instant_repeat_3f then
    instant_state = repeat_invoc
  else
    instant_state = nil
  end
  local reverted_instant_repeat_3f
  do
    local t_187_ = instant_state
    if (nil ~= t_187_) then
      t_187_ = (t_187_)["reverted?"]
    else
    end
    reverted_instant_repeat_3f = t_187_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _189_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _189_(self.state.cold["reverse?"])
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
  local function get_num_of_matches_to_be_highlighted()
    local _195_ = opts.limit_ft_matches
    local function _196_()
      local group_limit = _195_
      return (group_limit > 0)
    end
    if ((nil ~= _195_) and _196_()) then
      local group_limit = _195_
      local matches_left_behind
      local function _198_()
        local _197_ = instant_state
        if (nil ~= _197_) then
          local _199_ = (_197_).stack
          if (nil ~= _199_) then
            return #_199_
          else
            return _199_
          end
        else
          return _197_
        end
      end
      matches_left_behind = (_198_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    elseif true then
      local _ = _195_
      return 0
    else
      return nil
    end
  end
  if not instant_repeat_3f then
    enter("ft")
  else
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  else
  end
  local _206_
  if instant_repeat_3f then
    _206_ = instant_state["in"]
  elseif dot_repeat_3f then
    _206_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _206_ = self.state.cold["in"]
  else
    local _207_
    local function _208_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _209_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _207_ = (_208_() or _209_())
    if (_207_ == _3cbackspace_3e) then
      local function _211_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_no_prev_search()
        end
        doau_when_exists("LightspeedFtLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _206_ = (self.state.cold["in"] or _211_())
    elseif (nil ~= _207_) then
      local _in = _207_
      _206_ = _in
    else
      _206_ = nil
    end
  end
  if (nil ~= _206_) then
    local in1 = _206_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    else
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _216_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _216_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local function _217_()
          if opts.ignore_case then
            return "\\c"
          else
            return "\\C"
          end
        end
        pattern = ("\\V" .. _217_() .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _219_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_220_ = _219_
        local line = _each_220_[1]
        local col = _each_220_[2]
        local pos = _each_220_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              local ch = (char_at_pos(pos, {}) or "\13")
              local ch0
              local function _222_()
                local t_221_ = opts.substitute_chars
                if (nil ~= t_221_) then
                  t_221_ = (t_221_)[ch]
                else
                end
                return t_221_
              end
              ch0 = (_222_() or ch)
              api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {virt_text = {{ch0, hl.group["one-char-match"]}}, virt_text_pos = "overlay", priority = hl.priority.label})
            else
            end
          end
          match_count = (match_count + 1)
        else
        end
      end
    end
    if (not reverted_instant_repeat_3f and ((match_count == 0) or ((match_count == 1) and instant_repeat_3f and t_mode_3f0))) then
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      else
      end
      do
        echo_not_found(in1)
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    else
      if not reverted_instant_repeat_3f then
        local function _228_()
          if t_mode_3f0 then
            local function _229_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_229_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            else
              return nil
            end
          else
            return nil
          end
        end
        jump_to_21_2a(jump_pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = true, ["add-to-jumplist?"] = not instant_repeat_3f, adjust = _228_})
      else
      end
      if op_mode_3f then
        do
          if dot_repeatable_op_3f then
            self.state.dot = {["in"] = in1}
            set_dot_repeat(replace_keycodes(get_plug_key("ft", reverse_3f0, t_mode_3f0, "dot")), count0)
          else
          end
        end
        doau_when_exists("LightspeedFtLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      else
        highlight_cursor()
        vim.cmd("redraw")
        local _234_
        local function _235_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _236_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _234_ = (_235_() or _236_())
        if (nil ~= _234_) then
          local in2 = _234_
          local stack
          local function _238_()
            local t_237_ = instant_state
            if (nil ~= t_237_) then
              t_237_ = (t_237_).stack
            else
            end
            return t_237_
          end
          stack = (_238_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _241_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_241_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, stack = stack, ["reverted?"] = false, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
          elseif (_241_ == "revert") then
            do
              local _242_ = table.remove(stack)
              if (nil ~= _242_) then
                vim.fn.cursor(_242_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, stack = stack, ["reverted?"] = true, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
          elseif true then
            local _ = _241_
            do
              vim.fn.feedkeys(in2, "i")
            end
            doau_when_exists("LightspeedFtLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          else
            return nil
          end
        else
          return nil
        end
      end
    end
  else
    return nil
  end
end
local function get_targetable_windows(reverse_3f)
  local curr_win_id = vim.fn.win_getid()
  local _let_249_ = vim.split(vim.fn.string(vim.fn.winlayout()), tostring(curr_win_id))
  local left = _let_249_[1]
  local right = _let_249_[2]
  local ids
  local _250_
  if reverse_3f then
    _250_ = left
  else
    _250_ = right
  end
  ids = string.gmatch(_250_, "%d+")
  local visual_or_OP_mode_3f = (vim.fn.mode() ~= "n")
  local buf = api.nvim_win_get_buf
  local ids0
  do
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for id in ids do
      local val_17_auto
      if not (visual_or_OP_mode_3f and (buf(id) ~= buf(curr_win_id))) then
        val_17_auto = id
      else
        val_17_auto = nil
      end
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    ids0 = tbl_15_auto
  end
  local ids1
  if reverse_3f then
    ids1 = vim.fn.reverse(ids0)
  else
    ids1 = ids0
  end
  local function _255_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  return map(_255_, ids1)
end
local function highlight_unique_chars(reverse_3f, _3ftarget_windows, omni_3f)
  local unique_chars = {}
  local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local _let_256_ = get_cursor_pos()
  local curline = _let_256_[1]
  local curcol = _let_256_[2]
  for _, w in ipairs((_3ftarget_windows or {curr_w})) do
    if _3ftarget_windows then
      api.nvim_set_current_win(w.winid)
    else
    end
    local _let_258_ = get_horizontal_bounds({["match-width"] = 2})
    local left_bound = _let_258_[1]
    local right_bound = _let_258_[2]
    local lines = get_onscreen_lines({["get-full-window?"] = (_3ftarget_windows or omni_3f), ["reverse?"] = reverse_3f, ["skip-folds?"] = true})
    for lnum, line in pairs(lines) do
      local startcol
      if ((lnum == curline) and not reverse_3f and not _3ftarget_windows) then
        startcol = inc(curcol)
      else
        startcol = 1
      end
      local endcol
      if ((lnum == curline) and reverse_3f and not _3ftarget_windows) then
        endcol = dec(curcol)
      else
        endcol = #line
      end
      for col = startcol, endcol do
        if (vim.wo.wrap or ((col >= left_bound) and (col <= right_bound))) then
          local ch = line:sub(col, col)
          local ch0
          if opts.ignore_case then
            ch0 = ch:lower()
          else
            ch0 = ch
          end
          local _263_
          do
            local _262_ = unique_chars[ch0]
            if (nil ~= _262_) then
              local pos_already_there = _262_
              _263_ = false
            elseif true then
              local _0 = _262_
              _263_ = {lnum, col, w}
            else
              _263_ = nil
            end
          end
          unique_chars[ch0] = _263_
        else
        end
      end
    end
  end
  if _3ftarget_windows then
    api.nvim_set_current_win(curr_w.winid)
  else
  end
  for ch, pos in pairs(unique_chars) do
    local _269_ = pos
    if ((_G.type(_269_) == "table") and (nil ~= (_269_)[1]) and (nil ~= (_269_)[2]) and (nil ~= (_269_)[3])) then
      local lnum = (_269_)[1]
      local col = (_269_)[2]
      local w = (_269_)[3]
      api.nvim_buf_add_highlight(w.bufnr, hl.ns, hl.group["unique-ch"], dec(lnum), dec(col), col)
    else
    end
  end
  return nil
end
local function get_targets_2a(input, reverse_3f, _3fwininfo, _3ftargets)
  local targets = (_3ftargets or {})
  local to_eol_3f = (input == "\13")
  local winid = vim.fn.win_getid()
  local prev_match = {}
  local added_prev_match_3f = nil
  local pattern
  if to_eol_3f then
    pattern = "\\n"
  else
    local function _271_()
      if opts.ignore_case then
        return "\\c"
      else
        return "\\C"
      end
    end
    pattern = ("\\V" .. _271_() .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _273_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f, ["cross-window?"] = _3fwininfo}) do
    local _each_274_ = _273_
    local line = _each_274_[1]
    local col = _each_274_[2]
    local pos = _each_274_
    local target = {pos = pos, wininfo = _3fwininfo}
    if to_eol_3f then
      target["pair"] = {"\n", ""}
      table.insert(targets, target)
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _275_
      if reverse_3f then
        _275_ = dec
      else
        _275_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _275_(prev_match.col)))
      local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
      local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
      prev_match = {line = line, col = col, ch2 = ch2}
      if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
        added_prev_match_3f = false
      else
        local _
        target["pair"] = {ch1, ch2}
        _ = nil
        local prev_target = last(targets)
        local min_delta_to_prevent_squeezing = 4
        local close_to_prev_target_3f
        do
          local _277_ = prev_target
          if ((_G.type(_277_) == "table") and ((_G.type((_277_).pos) == "table") and (nil ~= ((_277_).pos)[1]) and (nil ~= ((_277_).pos)[2]))) then
            local prev_line = ((_277_).pos)[1]
            local prev_col = ((_277_).pos)[2]
            local function _279_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta < min_delta_to_prevent_squeezing)
            end
            close_to_prev_target_3f = ((line == prev_line) and _279_())
          else
            close_to_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        else
        end
        if close_to_prev_target_3f then
          local _282_
          if reverse_3f then
            _282_ = target
          else
            _282_ = prev_target
          end
          _282_["squeezed?"] = true
        else
        end
        if overlaps_prev_target_3f then
          local _285_
          if reverse_3f then
            _285_ = prev_target
          else
            _285_ = target
          end
          _285_["overlapped?"] = true
        else
        end
        table.insert(targets, target)
        added_prev_match_3f = true
      end
    end
  end
  if next(targets) then
    return targets
  else
    return nil
  end
end
local function get_targets(input, reverse_3f, _3ftarget_windows, omni_3f)
  if omni_3f then
    local _291_ = get_targets_2a(input, true, nil, get_targets_2a(input, false, nil))
    if (nil ~= _291_) then
      local targets = _291_
      local calculate_screen_positions_3f = (vim.wo.wrap and (#targets < 200))
      local winid = vim.fn.win_getid()
      local _let_292_ = get_cursor_pos()
      local curline = _let_292_[1]
      local curcol = _let_292_[2]
      local curscreenpos = vim.fn.screenpos(winid, curline, curcol)
      local editor_grid_aspect_ratio = 0.3
      local to_eol_3f = (input == "\13")
      local function dist_from_cursor(target)
        local function _294_()
          if calculate_screen_positions_3f then
            return {abs((target.screenpos.col - curscreenpos.col)), abs((target.screenpos.row - curscreenpos.row))}
          else
            return {abs((target.pos[2] - curcol)), abs((target.pos[1] - curline))}
          end
        end
        local _let_293_ = _294_()
        local dx = _let_293_[1]
        local dy = _let_293_[2]
        local dx0
        local function _295_()
          if to_eol_3f then
            return 0
          else
            return 1
          end
        end
        dx0 = (dx * editor_grid_aspect_ratio * _295_())
        return math.pow((math.pow(dx0, 2) + math.pow(dy, 2)), 0.5)
      end
      local function by_dist_from_cursor(t1, t2)
        return (dist_from_cursor(t1) < dist_from_cursor(t2))
      end
      if calculate_screen_positions_3f then
        for _, _296_ in ipairs(targets) do
          local _each_297_ = _296_
          local _each_298_ = _each_297_["pos"]
          local line = _each_298_[1]
          local col = _each_298_[2]
          local t = _each_297_
          t["screenpos"] = vim.fn.screenpos(winid, line, col)
        end
      else
      end
      table.sort(targets, by_dist_from_cursor)
      return targets
    else
      return nil
    end
  elseif _3ftarget_windows then
    local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
    local targets = {}
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_set_current_win(w.winid)
      get_targets_2a(input, reverse_3f, w, targets)
    end
    api.nvim_set_current_win(curr_w.winid)
    if next(targets) then
      return targets
    else
      return nil
    end
  else
    return get_targets_2a(input, reverse_3f)
  end
end
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.ignore_case then
    local function _303_(self, k)
      return rawget(self, k:lower())
    end
    local function _304_(self, k, v)
      return rawset(self, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _303_, __newindex = _304_})
  else
  end
  for _, _306_ in ipairs(targets) do
    local _each_307_ = _306_
    local _each_308_ = _each_307_["pair"]
    local _0 = _each_308_[1]
    local ch2 = _each_308_[2]
    local target = _each_307_
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    else
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function get_labels(sublist, to_eol_3f)
  if to_eol_3f then
    sublist["autojump?"] = false
  else
  end
  if (not opts.safe_labels or empty_3f(opts.safe_labels)) then
    if (sublist["autojump?"] == nil) then
      sublist["autojump?"] = false
    else
    end
    return opts.labels
  elseif (not opts.labels or empty_3f(opts.labels)) then
    if (sublist["autojump?"] == nil) then
      sublist["autojump?"] = true
    else
    end
    return opts.safe_labels
  else
    local _313_ = sublist["autojump?"]
    if (_313_ == true) then
      return opts.safe_labels
    elseif (_313_ == false) then
      return opts.labels
    elseif (_313_ == nil) then
      sublist["autojump?"] = (not operator_pending_mode_3f() and (dec(#sublist) <= #opts.safe_labels))
      return get_labels(sublist)
    else
      return nil
    end
  end
end
local function set_labels(targets, to_eol_3f)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      local labels = get_labels(sublist, to_eol_3f)
      for i, target in ipairs(sublist) do
        local _316_
        if not (sublist["autojump?"] and (i == 1)) then
          local _317_
          local function _319_()
            if sublist["autojump?"] then
              return dec(i)
            else
              return i
            end
          end
          _317_ = (_319_() % #labels)
          if (_317_ == 0) then
            _316_ = last(labels)
          elseif (nil ~= _317_) then
            local n = _317_
            _316_ = labels[n]
          else
            _316_ = nil
          end
        else
          _316_ = nil
        end
        target["label"] = _316_
      end
    else
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _325_)
  local _arg_326_ = _325_
  local group_offset = _arg_326_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local function _327_()
    if sublist["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _327_())
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _328_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _328_ = "inactive"
      elseif (i <= primary_end) then
        _328_ = "active-primary"
      else
        _328_ = "active-secondary"
      end
    else
      _328_ = nil
    end
    target["label-state"] = _328_
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
    local tbl_12_auto = {}
    for ch2, _ in pairs(targets.sublists) do
      local _331_, _332_ = ch2, true
      if ((nil ~= _331_) and (nil ~= _332_)) then
        local k_13_auto = _331_
        local v_14_auto = _332_
        tbl_12_auto[k_13_auto] = v_14_auto
      else
      end
    end
    potential_2nd_inputs = tbl_12_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _334_ in ipairs(targets) do
    local _each_335_ = _334_
    local label = _each_335_["label"]
    local label_state = _each_335_["label-state"]
    local target = _each_335_
    if (label_state == "active-primary") then
      if not ((potential_2nd_inputs)[label] or labels_used_up_as_shortcut[label]) then
        target["shortcut?"] = true
        targets.shortcuts[label] = target
        labels_used_up_as_shortcut[label] = true
      else
      end
    else
    end
  end
  return nil
end
local function set_beacon(_338_, _repeat)
  local _arg_339_ = _338_
  local _arg_340_ = _arg_339_["pos"]
  local _ = _arg_340_[1]
  local col = _arg_340_[2]
  local left_bound = _arg_340_[3]
  local right_bound = _arg_340_[4]
  local _arg_341_ = _arg_339_["pair"]
  local ch1 = _arg_341_[1]
  local ch2 = _arg_341_[2]
  local label = _arg_339_["label"]
  local label_state = _arg_339_["label-state"]
  local squeezed_3f = _arg_339_["squeezed?"]
  local overlapped_3f = _arg_339_["overlapped?"]
  local shortcut_3f = _arg_339_["shortcut?"]
  local target = _arg_339_
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local ch10
  if to_eol_3f then
    ch10 = "\13"
  else
    ch10 = ch1
  end
  local function _344_(_241)
    local function _346_()
      local t_345_ = opts.substitute_chars
      if (nil ~= t_345_) then
        t_345_ = (t_345_)[_241]
      else
      end
      return t_345_
    end
    return (_346_() or _241)
  end
  local _let_343_ = map(_344_, {ch10, ch2})
  local ch11 = _let_343_[1]
  local ch20 = _let_343_[2]
  local squeezed_3f0 = (opts.force_beacons_into_match_width or squeezed_3f)
  local onscreen_3f = (vim.wo.wrap or ((col <= right_bound) and (col >= left_bound)))
  local left_off_3f = (col < left_bound)
  local right_off_3f = (col > right_bound)
  local hg = hl.group
  local masked_char_24 = {ch20, hg["masked-ch"]}
  local label_24 = {label, hg.label}
  local shortcut_24 = {label, hg.shortcut}
  local distant_label_24 = {label, hg["label-distant"]}
  local overlapped_label_24 = {label, hg["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hg["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hg["label-distant-overlapped"]}
  if (_repeat == "instant-unsafe") then
    target.beacon = {0, {{(ch11 .. ch20), hg["one-char-match"]}}}
  else
    local _348_ = label_state
    if (_348_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hg["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch11 .. ch20), hg["unlabeled-match"]}}}
        end
      else
        target.beacon = nil
      end
    elseif (_348_ == "active-primary") then
      if to_eol_3f then
        if onscreen_3f then
          target.beacon = {0, {shortcut_24}}
        elseif left_off_3f then
          target.beacon = {0, {{"<", hg["one-char-match"]}, shortcut_24}, "left-off"}
        elseif right_off_3f then
          target.beacon = {dec((right_bound - col)), {shortcut_24, {">", hg["one-char-match"]}}}
        else
          target.beacon = nil
        end
      elseif _repeat then
        local _352_
        if squeezed_3f0 then
          _352_ = 1
        else
          _352_ = 2
        end
        target.beacon = {_352_, {shortcut_24}}
      elseif shortcut_3f then
        if overlapped_3f then
          target.beacon = {1, {overlapped_shortcut_24}}
        else
          if squeezed_3f0 then
            target.beacon = {0, {masked_char_24, shortcut_24}}
          else
            target.beacon = {2, {shortcut_24}}
          end
        end
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, label_24}}
      else
        target.beacon = {2, {label_24}}
      end
    elseif (_348_ == "active-secondary") then
      if to_eol_3f then
        if onscreen_3f then
          target.beacon = {0, {distant_label_24}}
        elseif left_off_3f then
          target.beacon = {0, {{"<", hg["unlabeled-match"]}, distant_label_24}, "left-off"}
        elseif right_off_3f then
          target.beacon = {dec((right_bound - col)), {distant_label_24, {">", hg["unlabeled-match"]}}}
        else
          target.beacon = nil
        end
      elseif _repeat then
        local _358_
        if squeezed_3f0 then
          _358_ = 1
        else
          _358_ = 2
        end
        target.beacon = {_358_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_348_ == "inactive") then
      target.beacon = nil
    else
      target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _363_)
  local _arg_364_ = _363_
  local _repeat = _arg_364_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, ghost_beacons_3f, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_365_ = target_list[i]
    local _let_366_ = _let_365_["pos"]
    local line = _let_366_[1]
    local col = _let_366_[2]
    local target = _let_365_
    local _367_ = target.beacon
    if ((_G.type(_367_) == "table") and (nil ~= (_367_)[1]) and (nil ~= (_367_)[2]) and true) then
      local offset = (_367_)[1]
      local chunks = (_367_)[2]
      local _3fleft_off_3f = (_367_)[3]
      local function _369_()
        local t_368_ = target.wininfo
        if (nil ~= t_368_) then
          t_368_ = (t_368_).bufnr
        else
        end
        return t_368_
      end
      local _371_
      if _3fleft_off_3f then
        _371_ = 0
      else
        _371_ = nil
      end
      api.nvim_buf_set_extmark((_369_() or 0), hl.ns, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _371_, priority = hl.priority.label})
      if ghost_beacons_3f then
        local curcol = vim.fn.col(".")
        local col_delta = abs((curcol - col))
        local min_col_delta = 5
        if (col_delta > min_col_delta) then
          local chunks0
          do
            local _373_ = target["label-state"]
            if (_373_ == "active-primary") then
              chunks0 = {{target.label, hl.group["label-overlapped"]}}
            elseif (_373_ == "active-secondary") then
              chunks0 = {{target.label, hl.group["label-distant-overlapped"]}}
            else
              chunks0 = nil
            end
          end
          api.nvim_buf_set_extmark(0, hl.ns, dec(line), 0, {virt_text = chunks0, virt_text_pos = "overlay", virt_text_win_col = dec(vim.fn.virtcol(".")), priority = hl.priority.label})
        else
        end
      else
      end
    else
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _378_ in ipairs(target_list) do
    local _each_379_ = _378_
    local label = _each_379_["label"]
    local label_state = _each_379_["label-state"]
    local target = _each_379_
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    else
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _381_ = opts.jump_to_unique_chars
  if ((_G.type(_381_) == "table") and (nil ~= (_381_).safety_timeout)) then
    local timeout = (_381_).safety_timeout
    local _382_ = get_input(timeout)
    if (nil ~= _382_) then
      local input = _382_
      if (input ~= char_to_ignore) then
        return vim.fn.feedkeys(input, "i")
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
local sx = {state = {dot = {in1 = nil, in2 = nil, in3 = nil}, cold = {in1 = nil, in2 = nil, ["reverse?"] = nil, ["x-mode?"] = nil}}}
sx.go = function(self, reverse_3f, x_mode_3f, repeat_invoc, cross_window_3f, omni_3f)
  local mode = api.nvim_get_mode().mode
  local linewise_3f = (mode:sub(-1) == "V")
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local delete_op_3f = (op_mode_3f and (vim.v.operator == "d"))
  local dot_repeatable_op_3f = (op_mode_3f and not omni_3f and (vim.v.operator ~= "y"))
  local instant_repeat_3f = (type(repeat_invoc) == "table")
  local instant_state
  if instant_repeat_3f then
    instant_state = repeat_invoc
  else
    instant_state = nil
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _387_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _387_(self.state.cold["reverse?"])
  else
    reverse_3f0 = reverse_3f
  end
  local x_mode_3f0
  if cold_repeat_3f then
    x_mode_3f0 = self.state.cold["x-mode?"]
  else
    x_mode_3f0 = x_mode_3f
  end
  local _3ftarget_windows
  local function _391_()
    if cross_window_3f then
      return get_targetable_windows(reverse_3f0)
    else
      return nil
    end
  end
  local function _392_()
    if instant_repeat_3f then
      return instant_state["target-windows"]
    else
      return nil
    end
  end
  _3ftarget_windows = (_391_() or _392_())
  local new_search_3f = not repeat_invoc
  local backspace_repeat_3f = nil
  local to_eol_3f = nil
  local to_pre_eol_3f = nil
  local function get_first_input()
    if instant_repeat_3f then
      return instant_state.in1
    elseif dot_repeat_3f then
      return self.state.dot.in1
    elseif cold_repeat_3f then
      return self.state.cold.in1
    else
      local _393_
      local function _394_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _395_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _393_ = (_394_() or _395_())
      local function _397_()
        return not omni_3f
      end
      if ((_393_ == "\9") and _397_()) then
        sx:go(not reverse_3f0, x_mode_3f0, false, cross_window_3f)
        return nil
      elseif (_393_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _398_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          else
          end
          do
            echo_no_prev_search()
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        return (self.state.cold.in1 or _398_())
      elseif (nil ~= _393_) then
        local _in = _393_
        return _in
      else
        return nil
      end
    end
  end
  local function update_state_2a(in1)
    local function _404_(_402_)
      local _arg_403_ = _402_
      local cold = _arg_403_["cold"]
      local dot = _arg_403_["dot"]
      if new_search_3f then
        if cold then
          local _405_ = cold
          _405_["in1"] = in1
          _405_["x-mode?"] = x_mode_3f0
          _405_["reverse?"] = reverse_3f0
          self.state.cold = _405_
        else
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _407_ = dot
              _407_["in1"] = in1
              _407_["x-mode?"] = x_mode_3f0
              self.state.dot = _407_
            end
            return nil
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    end
    return _404_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _411_(target, _3fto_pre_eol_3f, _3fsave_winview_3f)
      if target.wininfo then
        api.nvim_set_current_win(target.wininfo.winid)
        if _3fsave_winview_3f then
          target["winview"] = vim.fn.winsaveview()
        else
        end
      else
      end
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      local function _414_()
        if to_eol_3f then
          if op_mode_3f then
            return push_cursor_21("fwd")
          else
            return nil
          end
        elseif to_pre_eol_3f0 then
          if (op_mode_3f and x_mode_3f0) then
            return push_cursor_21("fwd")
          else
            return nil
          end
        elseif x_mode_3f0 then
          push_cursor_21("fwd")
          if reverse_3f0 then
            return push_cursor_21("fwd")
          else
            return nil
          end
        else
          return nil
        end
      end
      adjusted_pos = jump_to_21_2a(target.pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), adjust = _414_})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _411_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _420_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_419_ = _420_()
    local startline = _let_419_[1]
    local startcol = _let_419_[2]
    local start = _let_419_
    local function _422_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_421_ = _422_()
    local _ = _let_421_[1]
    local endcol = _let_421_[2]
    local _end = _let_421_
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
    else
    end
    if op_mode_3f then
      highlight_range(hl.group["pending-op-area"], map(dec, start), map(dec, _end), {["motion-force"] = motion_force, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0)})
    else
    end
    return vim.cmd("redraw")
  end
  local function get_sublist(targets, ch)
    local _427_ = targets.sublists[ch]
    if (nil ~= _427_) then
      local sublist = _427_
      local _let_428_ = sublist
      local _let_429_ = _let_428_[1]
      local _let_430_ = _let_429_["pos"]
      local line = _let_430_[1]
      local col = _let_430_[2]
      local rest = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_428_, 2)
      local target_tail = {line, inc(col)}
      local prev_pos = vim.fn.searchpos("\\_.", "nWb")
      local cursor_touches_first_target_3f = same_pos_3f(target_tail, prev_pos)
      if (cold_repeat_3f and x_mode_3f0 and reverse_3f0 and cursor_touches_first_target_3f) then
        if not empty_3f(rest) then
          return rest
        else
          return nil
        end
      else
        return sublist
      end
    else
      return nil
    end
  end
  local function get_last_input(sublist, start_idx)
    local next_group_key = replace_keycodes(opts.special_keys.next_match_group)
    local prev_group_key = replace_keycodes(opts.special_keys.prev_match_group)
    local function recur(group_offset, initial_invoc_3f)
      local _434_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _434_ = "cold"
      elseif instant_repeat_3f then
        if sublist["autojump?"] then
          _434_ = "instant"
        else
          _434_ = "instant-unsafe"
        end
      else
        _434_ = nil
      end
      set_beacons(sublist, {["repeat"] = _434_})
      do
        if not (cold_repeat_3f or instant_repeat_3f) then
          grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
        else
        end
        do
          light_up_beacons(sublist, (linewise_3f and to_eol_3f and not instant_repeat_3f), start_idx)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _438_
      do
        local res_2_auto
        do
          local function _439_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            else
              return nil
            end
          end
          res_2_auto = get_input(_439_())
        end
        hl:cleanup(_3ftarget_windows)
        _438_ = res_2_auto
      end
      if (nil ~= _438_) then
        local input = _438_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _441_
          do
            local _440_ = input
            if (_440_ == next_group_key) then
              _441_ = inc
            elseif true then
              local _ = _440_
              _441_ = dec
            else
              _441_ = nil
            end
          end
          group_offset_2a = clamp(_441_(group_offset), 0, max_offset)
          set_label_states_for_sublist(sublist, {["group-offset"] = group_offset_2a})
          return recur(group_offset_2a)
        else
          return {input, group_offset}
        end
      else
        return nil
      end
    end
    return recur(0, true)
  end
  local function restore_view_on_winleave(curr_target, next_target)
    local _448_
    do
      local t_447_ = curr_target
      if (nil ~= t_447_) then
        t_447_ = (t_447_).wininfo
      else
      end
      if (nil ~= t_447_) then
        t_447_ = (t_447_).winid
      else
      end
      _448_ = t_447_
    end
    local _452_
    do
      local t_451_ = next_target
      if (nil ~= t_451_) then
        t_451_ = (t_451_).wininfo
      else
      end
      if (nil ~= t_451_) then
        t_451_ = (t_451_).winid
      else
      end
      _452_ = t_451_
    end
    if (not instant_repeat_3f and (_448_ ~= _452_)) then
      if curr_target.winview then
        return vim.fn.winrestview(curr_target.winview)
      else
        return nil
      end
    else
      return nil
    end
  end
  enter("sx")
  if not repeat_invoc then
    echo("")
    if not (cold_repeat_3f or instant_repeat_3f) then
      grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
    else
    end
    do
      if opts.jump_to_unique_chars then
        highlight_unique_chars(reverse_3f0, _3ftarget_windows, omni_3f)
      else
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  else
  end
  local _460_ = get_first_input()
  if (nil ~= _460_) then
    local in1 = _460_
    local _
    to_eol_3f = (in1 == "\13")
    _ = nil
    local from_pos = get_cursor_pos()
    local update_state = update_state_2a(in1)
    local prev_in2
    if instant_repeat_3f then
      prev_in2 = instant_state.in2
    elseif (cold_repeat_3f or backspace_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
      prev_in2 = nil
    end
    local _462_
    local function _464_()
      local t_463_ = instant_state
      if (nil ~= t_463_) then
        t_463_ = (t_463_).sublist
      else
      end
      return t_463_
    end
    local function _466_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      else
      end
      do
        echo_not_found((in1 .. (prev_in2 or "")))
      end
      doau_when_exists("LightspeedSxLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _462_ = (_464_() or get_targets(in1, reverse_3f0, _3ftarget_windows, omni_3f) or _466_())
    local function _468_()
      local only = (_462_)[1]
      local _0 = (((_462_)[1]).pair)[1]
      local ch2 = (((_462_)[1]).pair)[2]
      return opts.jump_to_unique_chars
    end
    if (((_G.type(_462_) == "table") and ((_G.type((_462_)[1]) == "table") and ((_G.type(((_462_)[1]).pair) == "table") and true and (nil ~= (((_462_)[1]).pair)[2]))) and ((_462_)[2] == nil)) and _468_()) then
      local only = (_462_)[1]
      local _0 = (((_462_)[1]).pair)[1]
      local ch2 = (((_462_)[1]).pair)[2]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
          else
          end
          update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = opts.labels[1]}})
          local to_pos = jump_to_21(only, (ch2 == "\13"))
          if new_search_3f then
            local res_2_auto
            do
              highlight_new_curpos_and_op_area(from_pos, to_pos)
              res_2_auto = ignore_input_until_timeout(ch2)
            end
            hl:cleanup(_3ftarget_windows)
          else
          end
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      else
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_not_found((in1 .. prev_in2))
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
    elseif (nil ~= _462_) then
      local targets = _462_
      if not instant_repeat_3f then
        local _473_ = targets
        populate_sublists(_473_)
        set_labels(_473_, to_eol_3f)
        set_label_states(_473_)
      else
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _475_ = targets
          set_shortcuts_and_populate_shortcuts_map(_475_)
          set_beacons(_475_, {["repeat"] = nil})
        end
        if not (cold_repeat_3f or instant_repeat_3f) then
          grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
        else
        end
        do
          light_up_beacons(targets, (linewise_3f and to_eol_3f and not instant_repeat_3f))
        end
        highlight_cursor()
        vim.cmd("redraw")
      else
      end
      local _478_
      local function _479_()
        if to_eol_3f then
          return ""
        else
          return nil
        end
      end
      local function _480_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _481_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _478_ = (prev_in2 or _479_() or _480_() or _481_())
      if (nil ~= _478_) then
        local in2 = _478_
        local _483_
        do
          local t_484_ = targets.shortcuts
          if (nil ~= t_484_) then
            t_484_ = (t_484_)[in2]
          else
          end
          _483_ = t_484_
        end
        if ((_G.type(_483_) == "table") and ((_G.type((_483_).pair) == "table") and true and (nil ~= ((_483_).pair)[2]))) then
          local shortcut = _483_
          local _0 = ((_483_).pair)[1]
          local ch2 = ((_483_).pair)[2]
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            else
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut, (ch2 == "\13"))
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        elseif true then
          local _0 = _483_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _487_
          local function _489_()
            local t_488_ = instant_state
            if (nil ~= t_488_) then
              t_488_ = (t_488_).sublist
            else
            end
            return t_488_
          end
          local function _491_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            else
            end
            do
              echo_not_found((in1 .. in2))
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _487_ = (_489_() or get_sublist(targets, in2) or _491_())
          if ((_G.type(_487_) == "table") and (nil ~= (_487_)[1]) and ((_487_)[2] == nil)) then
            local only = (_487_)[1]
            do
              if dot_repeatable_op_3f then
                set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
              else
              end
              update_state({dot = {in2 = in2, in3 = (opts.labels or opts.safe_labels)[1]}})
              jump_to_21(only)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif ((_G.type(_487_) == "table") and (nil ~= (_487_)[1])) then
            local first = (_487_)[1]
            local sublist = _487_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _495_()
              local t_494_ = instant_state
              if (nil ~= t_494_) then
                t_494_ = (t_494_).idx
              else
              end
              return t_494_
            end
            local function _497_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_495_() or _497_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first, nil, true)
            else
            end
            local _500_
            local function _501_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              else
                return nil
              end
            end
            local function _502_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              else
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _500_ = (_501_() or get_last_input(sublist, inc(curr_idx)) or _502_())
            if ((_G.type(_500_) == "table") and (nil ~= (_500_)[1]) and (nil ~= (_500_)[2])) then
              local in3 = (_500_)[1]
              local group_offset = (_500_)[2]
              local _504_
              if not (op_mode_3f or (group_offset > 0)) then
                _504_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
                _504_ = nil
              end
              if (nil ~= _504_) then
                local action = _504_
                local idx
                do
                  local _506_ = action
                  if (_506_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_506_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                    idx = nil
                  end
                end
                local neighbor = sublist[idx]
                restore_view_on_winleave(first, neighbor)
                jump_to_21(neighbor)
                return sx:go(reverse_3f0, x_mode_3f0, {in1 = in1, in2 = in2, sublist = sublist, idx = idx, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["target-windows"] = _3ftarget_windows})
              elseif true then
                local _1 = _504_
                local _508_
                if not (instant_repeat_3f and not autojump_3f) then
                  _508_ = get_target_with_active_primary_label(sublist, in3)
                else
                  _508_ = nil
                end
                if (nil ~= _508_) then
                  local target = _508_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    else
                    end
                    local _511_
                    if (group_offset > 0) then
                      _511_ = nil
                    else
                      _511_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _511_}})
                    restore_view_on_winleave(first, target)
                    jump_to_21(target)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                elseif true then
                  local _2 = _508_
                  if (autojump_3f or instant_repeat_3f) then
                    do
                      if dot_repeatable_op_3f then
                        set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                      else
                      end
                      vim.fn.feedkeys(in3, "i")
                    end
                    doau_when_exists("LightspeedSxLeave")
                    doau_when_exists("LightspeedLeave")
                    return nil
                  else
                    if change_operation_3f() then
                      handle_interrupted_change_op_21()
                    else
                    end
                    do
                    end
                    doau_when_exists("LightspeedSxLeave")
                    doau_when_exists("LightspeedLeave")
                    return nil
                  end
                else
                  return nil
                end
              else
                return nil
              end
            else
              return nil
            end
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
local temporary_editor_opts = {["vim.wo.conceallevel"] = 0, ["vim.wo.scrolloff"] = 0, ["vim.bo.modeline"] = false}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_524_ = vim.split(opt, ".", true)
    local _0 = _let_524_[1]
    local scope = _let_524_[2]
    local name = _let_524_[3]
    local _525_
    if (opt == "vim.wo.scrolloff") then
      _525_ = api.nvim_eval("&l:scrolloff")
    else
      _525_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _525_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_527_ = vim.split(opt, ".", true)
    local _ = _let_527_[1]
    local scope = _let_527_[2]
    local name = _let_527_[3]
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
  local plug_keys = {{"<Plug>Lightspeed_s", "sx:go(false)"}, {"<Plug>Lightspeed_S", "sx:go(true)"}, {"<Plug>Lightspeed_x", "sx:go(false, true)"}, {"<Plug>Lightspeed_X", "sx:go(true, true)"}, {"<Plug>Lightspeed_gs", "sx:go(false, nil, nil, true)"}, {"<Plug>Lightspeed_gS", "sx:go(true, nil, nil, true)"}, {"<Plug>Lightspeed_omni_s", "sx:go(nil, false, nil, nil, true)"}, {"<Plug>Lightspeed_f", "ft:go(false)"}, {"<Plug>Lightspeed_F", "ft:go(true)"}, {"<Plug>Lightspeed_t", "ft:go(false, true)"}, {"<Plug>Lightspeed_T", "ft:go(true, true)"}, {"<Plug>Lightspeed_;_sx", "sx:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_sx", "sx:go(true, nil, 'cold')"}, {"<Plug>Lightspeed_;_ft", "ft:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_ft", "ft:go(true, nil, 'cold')"}}
  for _, _528_ in ipairs(plug_keys) do
    local _each_529_ = _528_
    local lhs = _each_529_[1]
    local rhs_call = _each_529_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _530_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_531_ = _530_
    local lhs = _each_531_[1]
    local rhs_call = _each_531_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"n", "gs", "<Plug>Lightspeed_gs"}, {"n", "gS", "<Plug>Lightspeed_gS"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _532_ in ipairs(default_keymaps) do
    local _each_533_ = _532_
    local mode = _each_533_[1]
    local lhs = _each_533_[2]
    local rhs = _each_533_[3]
    if ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0)) then
      api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
    else
    end
  end
  return nil
end
init_highlight()
set_plug_keys()
if not vim.g.lightspeed_no_default_keymaps then
  set_default_keymaps()
else
end
vim.cmd("augroup lightspeed_reinit_highlight\n   autocmd!\n   autocmd ColorScheme * lua require'lightspeed'.init_highlight()\n   augroup end")
vim.cmd("augroup lightspeed_editor_opts\n   autocmd!\n   autocmd User LightspeedEnter lua require'lightspeed'.save_editor_opts(); require'lightspeed'.set_temporary_editor_opts()\n   autocmd User LightspeedLeave lua require'lightspeed'.restore_editor_opts()\n   augroup end")
return {opts = opts, setup = setup, ft = ft, sx = sx, save_editor_opts = save_editor_opts, set_temporary_editor_opts = set_temporary_editor_opts, restore_editor_opts = restore_editor_opts, init_highlight = init_highlight, set_default_keymaps = set_default_keymaps}
