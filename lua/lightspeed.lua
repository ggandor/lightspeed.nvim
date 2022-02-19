local api = vim.api
local contains_3f = vim.tbl_contains
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local _local_1_ = math
local abs = _local_1_["abs"]
local ceil = _local_1_["ceil"]
local max = _local_1_["max"]
local min = _local_1_["min"]
local pow = _local_1_["pow"]
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
  local _3_
  if mode:match("o") then
    _3_ = mode:sub(-1)
  else
  _3_ = nil
  end
  if (nil ~= _3_) then
    local last_ch = _3_
    if ((last_ch == _3cctrl_v_3e) or (last_ch == "V") or (last_ch == "v")) then
      return last_ch
    end
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
local function same_pos_3f(_7_, _9_)
  local _arg_8_ = _7_
  local l1 = _arg_8_[1]
  local c1 = _arg_8_[2]
  local _arg_10_ = _9_
  local l2 = _arg_10_[1]
  local c2 = _arg_10_[2]
  return ((l1 == l2) and (c1 == c2))
end
local function char_at_pos(_11_, _13_)
  local _arg_12_ = _11_
  local line = _arg_12_[1]
  local byte_col = _arg_12_[2]
  local _arg_14_ = _13_
  local char_offset = _arg_14_["char-offset"]
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
  if ("\9" == string.sub(vim.fn.getline("."), 1, 1)) then
    return (wincol - dec(vim.o.tabstop))
  else
    return wincol
  end
end
local function get_fold_edge(lnum, reverse_3f)
  local _17_
  local _18_
  if reverse_3f then
    _18_ = vim.fn.foldclosed
  else
    _18_ = vim.fn.foldclosedend
  end
  _17_ = _18_(lnum)
  if (_17_ == -1) then
    return nil
  elseif (nil ~= _17_) then
    local fold_edge = _17_
    return fold_edge
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
local opts
do
  local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  local labels = {"s", "f", "n", "j", "k", "l", "o", "d", "w", "e", "h", "m", "v", "g", "u", "t", "c", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  opts = {exit_after_idle_msecs = {labeled = nil, unlabeled = 1000}, force_beacons_into_match_width = false, ignore_case = false, jump_to_unique_chars = {safety_timeout = 400}, labels = labels, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, repeat_ft_with_target_char = false, safe_labels = safe_labels, special_keys = {next_match_group = "<space>", prev_match_group = "<tab>"}, substitute_chars = {["\13"] = "\194\172"}}
end
local removed_opts = {"jump_to_first_match", "instant_repeat_fwd_key", "instant_repeat_bwd_key", "x_mode_prefix_key", "full_inclusive_prefix_key", "grey_out_search_area", "highlight_unique_chars", "jump_on_partial_input_safety_timeout", "cycle_group_fwd_key", "cycle_group_bwd_key"}
local function get_warning_msg(arg_fields)
  local msg = {{"ligthspeed.nvim\n", "Question"}, {"The following fields in the "}, {"opts", "Visual"}, {" table has been renamed or removed:\n\n"}}
  local field_names
  do
    local tbl_12_auto = {}
    for _, field in ipairs(arg_fields) do
      tbl_12_auto[(#tbl_12_auto + 1)] = {("\9" .. field .. "\n")}
    end
    field_names = tbl_12_auto
  end
  local msg_for_jump_to_first_match = {{"The plugin implements \"smart\" auto-jump now, that you can fine-tune via "}, {"opts.labels", "Visual"}, {" and "}, {"opts.safe_labels", "Visual"}, {". See "}, {":h lightspeed-config", "Visual"}, {" for details."}}
  local msg_for_instant_repeat_keys = {{"There are dedicated "}, {"<Plug>", "Visual"}, {" keys available for native-like "}, {";", "Visual"}, {" and "}, {",", "Visual"}, {" functionality now, "}, {"that can also be used for instant repeat only, if you prefer. See "}, {":h lightspeed-custom-mappings", "Visual"}, {"."}}
  local msg_for_x_prefix = {{"Use "}, {"<Plug>Lightspeed_x", "Visual"}, {" and "}, {"<Plug>Lightspeed_X", "Visual"}, {" instead."}}
  local msg_for_grey_out = {{"This flag has been removed. To turn the 'greywash' feature off, "}, {"just set all attributes of the corresponding highlight group to 'none': "}, {":hi LightspeedGreywash guifg=none guibg=none ...", "Visual"}}
  local msg_for_hl_unique_chars = {{"Use "}, {"jump_to_unique_chars", "Visual"}, {" instead. See "}, {":h lightspeed-config", "Visual"}, {" for details."}}
  local msg_for_cycle_keys = {{"Use the "}, {"opts.special_keys", "Visual"}, {" table instead. See "}, {":h lightspeed-config", "Visual"}, {" for details."}}
  local spec_messages = {cycle_group_bwd_key = msg_for_cycle_keys, cycle_group_fwd_key = msg_for_cycle_keys, full_inclusive_prefix_key = msg_for_x_prefix, grey_out_search_area = msg_for_grey_out, highlight_unique_chars = msg_for_hl_unique_chars, instant_repeat_bwd_key = msg_for_instant_repeat_keys, instant_repeat_fwd_key = msg_for_instant_repeat_keys, jump_on_partial_input_safety_timeout = msg_for_hl_unique_chars, jump_to_first_match = msg_for_jump_to_first_match, x_mode_prefix_key = msg_for_x_prefix}
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
    end
  end
  return msg
end
do
  local guard
  local function _23_(t, k)
    if contains_3f(removed_opts, k) then
      return api.nvim_echo(get_warning_msg({k}), true, {})
    end
  end
  guard = _23_
  setmetatable(opts, {__index = guard, __newindex = guard})
end
local function normalize_opts(opts0)
  local removed_arg_opts = {}
  for k, v in pairs(opts0) do
    if contains_3f(removed_opts, k) then
      table.insert(removed_arg_opts, k)
      do end (opts0)[k] = nil
    end
  end
  if not empty_3f(removed_arg_opts) then
    api.nvim_echo(get_warning_msg(removed_arg_opts), true, {})
  end
  return opts0
end
local function setup(user_opts)
  opts = setmetatable(normalize_opts(user_opts), {__index = opts})
  return nil
end
local hl
local function _27_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {cleanup = _27_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace(""), priority = {cursor = 65535, greywash = 65533, label = 65534}}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _30_
  do
    local _29_ = bg
    if (_29_ == "light") then
      _30_ = "#f02077"
    else
      local _ = _29_
      _30_ = "#ff2f87"
    end
  end
  local _35_
  do
    local _34_ = bg
    if (_34_ == "light") then
      _35_ = "#ff4090"
    else
      local _ = _34_
      _35_ = "#e01067"
    end
  end
  local _40_
  do
    local _39_ = bg
    if (_39_ == "light") then
      _40_ = "Blue"
    else
      local _ = _39_
      _40_ = "Cyan"
    end
  end
  local _45_
  do
    local _44_ = bg
    if (_44_ == "light") then
      _45_ = "#399d9f"
    else
      local _ = _44_
      _45_ = "#99ddff"
    end
  end
  local _50_
  do
    local _49_ = bg
    if (_49_ == "light") then
      _50_ = "Cyan"
    else
      local _ = _49_
      _50_ = "Blue"
    end
  end
  local _55_
  do
    local _54_ = bg
    if (_54_ == "light") then
      _55_ = "#59bdbf"
    else
      local _ = _54_
      _55_ = "#79bddf"
    end
  end
  local _60_
  do
    local _59_ = bg
    if (_59_ == "light") then
      _60_ = "#cc9999"
    else
      local _ = _59_
      _60_ = "#b38080"
    end
  end
  local _65_
  do
    local _64_ = bg
    if (_64_ == "light") then
      _65_ = "Black"
    else
      local _ = _64_
      _65_ = "White"
    end
  end
  local _70_
  do
    local _69_ = bg
    if (_69_ == "light") then
      _70_ = "#272020"
    else
      local _ = _69_
      _70_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _30_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _35_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _40_, gui = "bold,underline", guibg = "NONE", guifg = _45_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _50_, gui = "underline", guifg = _55_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _60_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _65_, gui = "bold", guibg = "NONE", guifg = _70_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _74_ in ipairs(groupdefs) do
    local _each_75_ = _74_
    local group = _each_75_[1]
    local attrs = _each_75_[2]
    local attrs_str
    local _76_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _76_ = tbl_12_auto
    end
    attrs_str = table.concat(_76_, " ")
    local _77_
    if force_3f then
      _77_ = ""
    else
      _77_ = "default "
    end
    vim.cmd(("highlight " .. _77_ .. group .. " " .. attrs_str))
  end
  for _, _79_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_80_ = _79_
    local from_group = _each_80_[1]
    local to_group = _each_80_[2]
    local _81_
    if force_3f then
      _81_ = ""
    else
      _81_ = "default "
    end
    vim.cmd(("highlight " .. _81_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f, _3ftarget_windows, omni_3f)
  if (_3ftarget_windows or omni_3f) then
    for _, win in ipairs((_3ftarget_windows or {vim.fn.getwininfo(vim.fn.win_getid())[1]})) do
      vim.highlight.range(win.bufnr, hl.ns, hl.group.greywash, {dec(win.topline), 0}, {dec(win.botline), -1}, "v", false, hl.priority.greywash)
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
    return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish, "v", false, hl.priority.greywash)
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
  local inclusive_motion_3f = _arg_93_["inclusive-motion?"]
  local motion_force = _arg_93_["motion-force"]
  local hl_range
  local function _94_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, "v", end_inclusive_3f, hl.priority.label)
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
  local add_to_jumplist_3f = _arg_102_["add-to-jumplist?"]
  local adjust = _arg_102_["adjust"]
  local inclusive_motion_3f = _arg_102_["inclusive-motion?"]
  local mode = _arg_102_["mode"]
  local reverse_3f = _arg_102_["reverse?"]
  local op_mode_3f = string.match(mode, "o")
  local motion_force = get_motion_force(mode)
  local restore_virtualedit_autocmd = get_restore_virtualedit_autocmd()
  if add_to_jumplist_3f then
    vim.cmd("norm! m`")
  end
  vim.fn.cursor(target)
  adjust()
  if not op_mode_3f then
    force_matchparen_refresh()
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
    end
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
  local ft_search_3f = _arg_123_["ft-search?"]
  local limit = _arg_123_["limit"]
  local to_eol_3f = _arg_123_["to-eol?"]
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
        end
        return "moved-the-cursor"
      end
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
    end
  end
  local function recur(match_at_curpos_3f)
    local match_at_curpos_3f0
    local function _148_()
      if win_enter_3f then
        win_enter_3f = false
        return true
      end
    end
    match_at_curpos_3f0 = (match_at_curpos_3f or _148_())
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _149_
      local _150_
      if match_at_curpos_3f0 then
        _150_ = "c"
      else
        _150_ = ""
      end
      _149_ = vim.fn.searchpos(pattern, (opts0 .. _150_), stopline)
      if ((type(_149_) == "table") and ((_149_)[1] == 0) and true) then
        local _ = (_149_)[2]
        return cleanup()
      elseif ((type(_149_) == "table") and (nil ~= (_149_)[1]) and (nil ~= (_149_)[2])) then
        local line = (_149_)[1]
        local col = (_149_)[2]
        local pos = _149_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _152_ = skip_to_fold_edge_21()
          if (_152_ == "moved-the-cursor") then
            return recur(false)
          elseif (_152_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_153_,_154_,_155_) return (_153_ <= _154_) and (_154_ <= _155_) end)(left_bound,col,right_bound) or to_eol_3f) then
              match_count = (match_count + 1)
              return {line, col, left_bound, right_bound}
            else
              local _156_ = skip_to_next_in_window_pos_21()
              if (_156_ == "moved-the-cursor") then
                return recur(true)
              else
                local _ = _156_
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
  local _let_163_ = (_3fpos or get_cursor_pos())
  local line = _let_163_[1]
  local col = _let_163_[2]
  local pos = _let_163_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {hl_mode = "combine", priority = hl.priority.cursor, virt_text = {{ch_at_curpos, hl.group.cursor}}, virt_text_pos = "overlay"})
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
  local _166_ = mode
  if (_166_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_166_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _168_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _168_
  local getchar_timeout
  local function _169_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    end
  end
  getchar_timeout = _169_
  local ok_3f, ch = nil, nil
  local function _171_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_171_())
  if (ok_3f and (ch ~= esc_keycode)) then
    if (type(ch) == "number") then
      return vim.fn.nr2char(ch)
    else
      return ch
    end
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
  local _176_
  do
    local _175_ = repeat_invoc
    if (_175_ == "dot") then
      _176_ = "dotrepeat_"
    else
      local _ = _175_
      _176_ = ""
    end
  end
  local _181_
  do
    local _180_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((type(_180_) == "table") and ((_180_)[1] == "ft") and ((_180_)[2] == false) and ((_180_)[3] == false)) then
      _181_ = "f"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "ft") and ((_180_)[2] == true) and ((_180_)[3] == false)) then
      _181_ = "F"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "ft") and ((_180_)[2] == false) and ((_180_)[3] == true)) then
      _181_ = "t"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "ft") and ((_180_)[2] == true) and ((_180_)[3] == true)) then
      _181_ = "T"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "sx") and ((_180_)[2] == false) and ((_180_)[3] == false)) then
      _181_ = "s"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "sx") and ((_180_)[2] == true) and ((_180_)[3] == false)) then
      _181_ = "S"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "sx") and ((_180_)[2] == false) and ((_180_)[3] == true)) then
      _181_ = "x"
    elseif ((type(_180_) == "table") and ((_180_)[1] == "sx") and ((_180_)[2] == true) and ((_180_)[3] == true)) then
      _181_ = "X"
    else
    _181_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _176_ .. _181_)
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
  local _192_
  if from_reverse_cold_repeat_3f then
    _192_ = revert_plug_key
  else
    _192_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _192_))) then
    return "repeat"
  else
    local _194_
    if from_reverse_cold_repeat_3f then
      _194_ = repeat_plug_key
    else
      _194_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _194_)))) then
      return "revert"
    end
  end
end
local ft = {state = {cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}, dot = {["in"] = nil}}}
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
    local t_198_ = instant_state
    if (nil ~= t_198_) then
      t_198_ = (t_198_)["reverted?"]
    end
    reverted_instant_repeat_3f = t_198_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _200_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _200_(self.state.cold["reverse?"])
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
    local _206_ = opts.limit_ft_matches
    local function _207_()
      local group_limit = _206_
      return (group_limit > 0)
    end
    if ((nil ~= _206_) and _207_()) then
      local group_limit = _206_
      local matches_left_behind
      local function _209_()
        local _208_ = instant_state
        if _208_ then
          local _210_ = (_208_).stack
          if _210_ then
            return #_210_
          else
            return _210_
          end
        else
          return _208_
        end
      end
      matches_left_behind = (_209_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    else
      local _ = _206_
      return 0
    end
  end
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _217_
  if instant_repeat_3f then
    _217_ = instant_state["in"]
  elseif dot_repeat_3f then
    _217_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _217_ = self.state.cold["in"]
  else
    local _218_
    local function _219_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _220_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _218_ = (_219_() or _220_())
    if (_218_ == _3cbackspace_3e) then
      local function _222_()
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
      _217_ = (self.state.cold["in"] or _222_())
    elseif (nil ~= _218_) then
      local _in = _218_
      _217_ = _in
    else
    _217_ = nil
    end
  end
  if (nil ~= _217_) then
    local in1 = _217_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _227_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _227_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local _228_
        if opts.ignore_case then
          _228_ = "\\c"
        else
          _228_ = "\\C"
        end
        pattern = ("\\V" .. _228_ .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _231_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_232_ = _231_
        local line = _each_232_[1]
        local col = _each_232_[2]
        local pos = _each_232_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              local ch = (char_at_pos(pos, {}) or "\13")
              local ch0
              local function _234_()
                local t_233_ = opts.substitute_chars
                if (nil ~= t_233_) then
                  t_233_ = (t_233_)[ch]
                end
                return t_233_
              end
              ch0 = (_234_() or ch)
              api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {priority = hl.priority.label, virt_text = {{ch0, hl.group["one-char-match"]}}, virt_text_pos = "overlay"})
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
        local function _240_()
          if t_mode_3f0 then
            local function _241_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_241_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            end
          end
        end
        jump_to_21_2a(jump_pos, {["add-to-jumplist?"] = not instant_repeat_3f, ["inclusive-motion?"] = true, ["reverse?"] = reverse_3f0, adjust = _240_, mode = mode})
      end
      if op_mode_3f then
        do
          if dot_repeatable_op_3f then
            self.state.dot = {["in"] = in1}
            set_dot_repeat(replace_keycodes(get_plug_key("ft", reverse_3f0, t_mode_3f0, "dot")), count0)
          end
        end
        doau_when_exists("LightspeedFtLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      else
        highlight_cursor()
        vim.cmd("redraw")
        local _246_
        local function _247_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _248_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _246_ = (_247_() or _248_())
        if (nil ~= _246_) then
          local in2 = _246_
          local stack
          local function _250_()
            local t_249_ = instant_state
            if (nil ~= t_249_) then
              t_249_ = (t_249_).stack
            end
            return t_249_
          end
          stack = (_250_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _253_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_253_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = false, stack = stack})
          elseif (_253_ == "revert") then
            do
              local _254_ = table.remove(stack)
              if _254_ then
                vim.fn.cursor(_254_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = true, stack = stack})
          else
            local _ = _253_
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
local function get_targetable_windows(reverse_3f)
  local curr_win_id = vim.fn.win_getid()
  local _let_261_ = vim.split(vim.fn.string(vim.fn.winlayout()), tostring(curr_win_id))
  local left = _let_261_[1]
  local right = _let_261_[2]
  local ids
  local _262_
  if reverse_3f then
    _262_ = left
  else
    _262_ = right
  end
  ids = string.gmatch(_262_, "%d+")
  local visual_or_OP_mode_3f = (vim.fn.mode() ~= "n")
  local buf = api.nvim_win_get_buf
  local ids0
  do
    local tbl_12_auto = {}
    for id in ids do
      local _264_
      if not (visual_or_OP_mode_3f and (buf(id) ~= buf(curr_win_id))) then
        _264_ = id
      else
      _264_ = nil
      end
      tbl_12_auto[(#tbl_12_auto + 1)] = _264_
    end
    ids0 = tbl_12_auto
  end
  local ids1
  if reverse_3f then
    ids1 = vim.fn.reverse(ids0)
  else
    ids1 = ids0
  end
  local function _267_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  return map(_267_, ids1)
end
local function highlight_unique_chars(reverse_3f, _3ftarget_windows, omni_3f)
  local unique_chars = {}
  local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local _let_268_ = get_cursor_pos()
  local curline = _let_268_[1]
  local curcol = _let_268_[2]
  for _, w in ipairs((_3ftarget_windows or {curr_w})) do
    if _3ftarget_windows then
      api.nvim_set_current_win(w.winid)
    end
    local _let_270_ = get_horizontal_bounds({["match-width"] = 2})
    local left_bound = _let_270_[1]
    local right_bound = _let_270_[2]
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
          local _275_
          do
            local _274_ = unique_chars[ch0]
            if (nil ~= _274_) then
              local pos_already_there = _274_
              _275_ = false
            else
              local _0 = _274_
              _275_ = {lnum, col, w}
            end
          end
          unique_chars[ch0] = _275_
        end
      end
    end
  end
  if _3ftarget_windows then
    api.nvim_set_current_win(curr_w.winid)
  end
  for ch, pos in pairs(unique_chars) do
    local _281_ = pos
    if ((type(_281_) == "table") and (nil ~= (_281_)[1]) and (nil ~= (_281_)[2]) and (nil ~= (_281_)[3])) then
      local lnum = (_281_)[1]
      local col = (_281_)[2]
      local w = (_281_)[3]
      api.nvim_buf_add_highlight(w.bufnr, hl.ns, hl.group["unique-ch"], dec(lnum), dec(col), col)
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
    local _283_
    if opts.ignore_case then
      _283_ = "\\c"
    else
      _283_ = "\\C"
    end
    pattern = ("\\V" .. _283_ .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _286_ in onscreen_match_positions(pattern, reverse_3f, {["cross-window?"] = _3fwininfo, ["to-eol?"] = to_eol_3f}) do
    local _each_287_ = _286_
    local line = _each_287_[1]
    local col = _each_287_[2]
    local pos = _each_287_
    local target = {pos = pos, wininfo = _3fwininfo}
    if to_eol_3f then
      target["pair"] = {"\n", ""}
      table.insert(targets, target)
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _288_
      if reverse_3f then
        _288_ = dec
      else
        _288_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _288_(prev_match.col)))
      local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
      local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
      prev_match = {ch2 = ch2, col = col, line = line}
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
          local _290_ = prev_target
          if ((type(_290_) == "table") and ((type((_290_).pos) == "table") and (nil ~= ((_290_).pos)[1]) and (nil ~= ((_290_).pos)[2]))) then
            local prev_line = ((_290_).pos)[1]
            local prev_col = ((_290_).pos)[2]
            local function _292_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta < min_delta_to_prevent_squeezing)
            end
            close_to_prev_target_3f = ((line == prev_line) and _292_())
          else
          close_to_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        end
        if close_to_prev_target_3f then
          local _295_
          if reverse_3f then
            _295_ = target
          else
            _295_ = prev_target
          end
          _295_["squeezed?"] = true
        end
        if overlaps_prev_target_3f then
          local _298_
          if reverse_3f then
            _298_ = prev_target
          else
            _298_ = target
          end
          _298_["overlapped?"] = true
        end
        table.insert(targets, target)
        added_prev_match_3f = true
      end
    end
  end
  if next(targets) then
    return targets
  end
end
local function get_targets(input, reverse_3f, _3ftarget_windows, omni_3f)
  if omni_3f then
    local _304_ = get_targets_2a(input, true, nil, get_targets_2a(input, false, nil))
    if (nil ~= _304_) then
      local targets = _304_
      local calculate_screen_positions_3f = (vim.wo.wrap and (#targets < 200))
      local winid = vim.fn.win_getid()
      local _let_305_ = get_cursor_pos()
      local curline = _let_305_[1]
      local curcol = _let_305_[2]
      local curscreenpos = vim.fn.screenpos(winid, curline, curcol)
      local editor_grid_aspect_ratio = 0.3
      local to_eol_3f = (input == "\13")
      local function dist_from_cursor(target)
        local function _307_()
          if calculate_screen_positions_3f then
            return {abs((target.screenpos.col - curscreenpos.col)), abs((target.screenpos.row - curscreenpos.row))}
          else
            return {abs((target.pos[2] - curcol)), abs((target.pos[1] - curline))}
          end
        end
        local _let_306_ = _307_()
        local dx = _let_306_[1]
        local dy = _let_306_[2]
        local dx0
        local _308_
        if to_eol_3f then
          _308_ = 0
        else
          _308_ = 1
        end
        dx0 = (dx * editor_grid_aspect_ratio * _308_)
        return pow((pow(dx0, 2) + pow(dy, 2)), 0.5)
      end
      for _, _310_ in ipairs(targets) do
        local _each_311_ = _310_
        local t = _each_311_
        local _each_312_ = _each_311_["pos"]
        local line = _each_312_[1]
        local col = _each_312_[2]
        if calculate_screen_positions_3f then
          t["screenpos"] = vim.fn.screenpos(winid, line, col)
        end
        t["rank"] = dist_from_cursor(t)
      end
      local function _314_(_241, _242)
        return ((_241).rank < (_242).rank)
      end
      table.sort(targets, _314_)
      return targets
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
    end
  else
    return get_targets_2a(input, reverse_3f)
  end
end
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.ignore_case then
    local function _318_(self, k)
      return rawget(self, k:lower())
    end
    local function _319_(self, k, v)
      return rawset(self, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _318_, __newindex = _319_})
  end
  for _, _321_ in ipairs(targets) do
    local _each_322_ = _321_
    local target = _each_322_
    local _each_323_ = _each_322_["pair"]
    local _0 = _each_323_[1]
    local ch2 = _each_323_[2]
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function get_labels(sublist, to_eol_3f)
  if to_eol_3f then
    sublist["autojump?"] = false
  end
  if (not opts.safe_labels or empty_3f(opts.safe_labels)) then
    if (sublist["autojump?"] == nil) then
      sublist["autojump?"] = false
    end
    return opts.labels
  elseif (not opts.labels or empty_3f(opts.labels)) then
    if (sublist["autojump?"] == nil) then
      sublist["autojump?"] = true
    end
    return opts.safe_labels
  else
    local _328_ = sublist["autojump?"]
    if (_328_ == true) then
      return opts.safe_labels
    elseif (_328_ == false) then
      return opts.labels
    elseif (_328_ == nil) then
      sublist["autojump?"] = (not operator_pending_mode_3f() and (dec(#sublist) <= #opts.safe_labels))
      return get_labels(sublist)
    end
  end
end
local function set_labels(targets, to_eol_3f)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      local labels = get_labels(sublist, to_eol_3f)
      for i, target in ipairs(sublist) do
        local _331_
        if not (sublist["autojump?"] and (i == 1)) then
          local _332_
          local _334_
          if sublist["autojump?"] then
            _334_ = dec(i)
          else
            _334_ = i
          end
          _332_ = (_334_ % #labels)
          if (_332_ == 0) then
            _331_ = last(labels)
          elseif (nil ~= _332_) then
            local n = _332_
            _331_ = labels[n]
          else
          _331_ = nil
          end
        else
        _331_ = nil
        end
        target["label"] = _331_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _341_)
  local _arg_342_ = _341_
  local group_offset = _arg_342_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _343_
  if sublist["autojump?"] then
    _343_ = 2
  else
    _343_ = 1
  end
  primary_start = (offset + _343_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _345_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _345_ = "inactive"
      elseif (i <= primary_end) then
        _345_ = "active-primary"
      else
        _345_ = "active-secondary"
      end
    else
    _345_ = nil
    end
    target["label-state"] = _345_
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
      local _348_, _349_ = ch2, true
      if ((nil ~= _348_) and (nil ~= _349_)) then
        local k_10_auto = _348_
        local v_11_auto = _349_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _351_ in ipairs(targets) do
    local _each_352_ = _351_
    local target = _each_352_
    local label = _each_352_["label"]
    local label_state = _each_352_["label-state"]
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
local function set_beacon(_355_, _repeat)
  local _arg_356_ = _355_
  local target = _arg_356_
  local label = _arg_356_["label"]
  local label_state = _arg_356_["label-state"]
  local overlapped_3f = _arg_356_["overlapped?"]
  local _arg_357_ = _arg_356_["pair"]
  local ch1 = _arg_357_[1]
  local ch2 = _arg_357_[2]
  local _arg_358_ = _arg_356_["pos"]
  local _ = _arg_358_[1]
  local col = _arg_358_[2]
  local left_bound = _arg_358_[3]
  local right_bound = _arg_358_[4]
  local shortcut_3f = _arg_356_["shortcut?"]
  local squeezed_3f = _arg_356_["squeezed?"]
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local ch10
  if to_eol_3f then
    ch10 = "\13"
  else
    ch10 = ch1
  end
  local function _361_(_241)
    local function _363_()
      local t_362_ = opts.substitute_chars
      if (nil ~= t_362_) then
        t_362_ = (t_362_)[_241]
      end
      return t_362_
    end
    return (_363_() or _241)
  end
  local _let_360_ = map(_361_, {ch10, ch2})
  local ch11 = _let_360_[1]
  local ch20 = _let_360_[2]
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
    local _365_ = label_state
    if (_365_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hg["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch11 .. ch20), hg["unlabeled-match"]}}}
        end
      else
      target.beacon = nil
      end
    elseif (_365_ == "active-primary") then
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
        local _369_
        if squeezed_3f0 then
          _369_ = 1
        else
          _369_ = 2
        end
        target.beacon = {_369_, {shortcut_24}}
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
    elseif (_365_ == "active-secondary") then
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
        local _375_
        if squeezed_3f0 then
          _375_ = 1
        else
          _375_ = 2
        end
        target.beacon = {_375_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_365_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _380_)
  local _arg_381_ = _380_
  local _repeat = _arg_381_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, ghost_beacons_3f, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_382_ = target_list[i]
    local target = _let_382_
    local _let_383_ = _let_382_["pos"]
    local line = _let_383_[1]
    local col = _let_383_[2]
    local _384_ = target.beacon
    if ((type(_384_) == "table") and (nil ~= (_384_)[1]) and (nil ~= (_384_)[2]) and true) then
      local offset = (_384_)[1]
      local chunks = (_384_)[2]
      local _3fleft_off_3f = (_384_)[3]
      local function _386_()
        local t_385_ = target.wininfo
        if (nil ~= t_385_) then
          t_385_ = (t_385_).bufnr
        end
        return t_385_
      end
      local _388_
      if _3fleft_off_3f then
        _388_ = 0
      else
      _388_ = nil
      end
      api.nvim_buf_set_extmark((_386_() or 0), hl.ns, dec(line), dec((col + offset)), {priority = hl.priority.label, virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _388_})
      if ghost_beacons_3f then
        local curcol = vim.fn.col(".")
        local col_delta = abs((curcol - col))
        local min_col_delta = 5
        if (col_delta > min_col_delta) then
          local chunks0
          do
            local _390_ = target["label-state"]
            if (_390_ == "active-primary") then
              chunks0 = {{target.label, hl.group["label-overlapped"]}}
            elseif (_390_ == "active-secondary") then
              chunks0 = {{target.label, hl.group["label-distant-overlapped"]}}
            else
            chunks0 = nil
            end
          end
          api.nvim_buf_set_extmark(0, hl.ns, dec(line), 0, {priority = hl.priority.label, virt_text = chunks0, virt_text_pos = "overlay", virt_text_win_col = dec(vim.fn.virtcol("."))})
        end
      end
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _395_ in ipairs(target_list) do
    local _each_396_ = _395_
    local target = _each_396_
    local label = _each_396_["label"]
    local label_state = _each_396_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _398_ = opts.jump_to_unique_chars
  if ((type(_398_) == "table") and (nil ~= (_398_).safety_timeout)) then
    local timeout = (_398_).safety_timeout
    local _399_ = get_input(timeout)
    if (nil ~= _399_) then
      local input = _399_
      if (input ~= char_to_ignore) then
        return vim.fn.feedkeys(input, "i")
      end
    end
  end
end
local sx = {state = {cold = {["reverse?"] = nil, ["x-mode?"] = nil, in1 = nil, in2 = nil}, dot = {in1 = nil, in2 = nil, in3 = nil}}}
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
    local function _404_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _404_(self.state.cold["reverse?"])
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
  local function _408_()
    if cross_window_3f then
      return get_targetable_windows(reverse_3f0)
    end
  end
  local function _409_()
    if instant_repeat_3f then
      return instant_state["target-windows"]
    end
  end
  _3ftarget_windows = (_408_() or _409_())
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
      local _410_
      local function _411_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _412_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _410_ = (_411_() or _412_())
      local function _414_()
        return not omni_3f
      end
      if ((_410_ == "\9") and _414_()) then
        sx:go(not reverse_3f0, x_mode_3f0, false, cross_window_3f)
        return nil
      elseif (_410_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _415_()
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
        return (self.state.cold.in1 or _415_())
      elseif (nil ~= _410_) then
        local _in = _410_
        return _in
      end
    end
  end
  local function update_state_2a(in1)
    local function _421_(_419_)
      local _arg_420_ = _419_
      local cold = _arg_420_["cold"]
      local dot = _arg_420_["dot"]
      if new_search_3f then
        if cold then
          local _422_ = cold
          _422_["in1"] = in1
          _422_["x-mode?"] = x_mode_3f0
          _422_["reverse?"] = reverse_3f0
          self.state.cold = _422_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _424_ = dot
              _424_["in1"] = in1
              _424_["x-mode?"] = x_mode_3f0
              self.state.dot = _424_
            end
            return nil
          end
        end
      end
    end
    return _421_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _428_(target, _3fto_pre_eol_3f, _3fsave_winview_3f)
      if target.wininfo then
        api.nvim_set_current_win(target.wininfo.winid)
        if _3fsave_winview_3f then
          target["winview"] = vim.fn.winsaveview()
        end
      end
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      local function _431_()
        if to_eol_3f then
          if op_mode_3f then
            return push_cursor_21("fwd")
          end
        elseif to_pre_eol_3f0 then
          if (op_mode_3f and x_mode_3f0) then
            return push_cursor_21("fwd")
          end
        elseif x_mode_3f0 then
          push_cursor_21("fwd")
          if reverse_3f0 then
            return push_cursor_21("fwd")
          end
        end
      end
      adjusted_pos = jump_to_21_2a(target.pos, {["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["reverse?"] = reverse_3f0, adjust = _431_, mode = mode})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _428_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _437_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_436_ = _437_()
    local startline = _let_436_[1]
    local startcol = _let_436_[2]
    local start = _let_436_
    local function _439_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_438_ = _439_()
    local _ = _let_438_[1]
    local endcol = _let_438_[2]
    local _end = _let_438_
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
      highlight_range(hl.group["pending-op-area"], map(dec, start), map(dec, _end), {["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["motion-force"] = motion_force})
    end
    return vim.cmd("redraw")
  end
  local function get_sublist(targets, ch)
    local _444_ = targets.sublists[ch]
    if (nil ~= _444_) then
      local sublist = _444_
      local _let_445_ = sublist
      local _let_446_ = _let_445_[1]
      local _let_447_ = _let_446_["pos"]
      local line = _let_447_[1]
      local col = _let_447_[2]
      local rest = {(table.unpack or unpack)(_let_445_, 2)}
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
  local function get_last_input(sublist, start_idx)
    local next_group_key = replace_keycodes(opts.special_keys.next_match_group)
    local prev_group_key = replace_keycodes(opts.special_keys.prev_match_group)
    local function recur(group_offset, initial_invoc_3f)
      local _451_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _451_ = "cold"
      elseif instant_repeat_3f then
        if sublist["autojump?"] then
          _451_ = "instant"
        else
          _451_ = "instant-unsafe"
        end
      else
      _451_ = nil
      end
      set_beacons(sublist, {["repeat"] = _451_})
      do
        if not (cold_repeat_3f or instant_repeat_3f) then
          grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
        end
        do
          light_up_beacons(sublist, (linewise_3f and to_eol_3f and not instant_repeat_3f), start_idx)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _455_
      do
        local res_2_auto
        do
          local function _456_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_456_())
        end
        hl:cleanup(_3ftarget_windows)
        _455_ = res_2_auto
      end
      if (nil ~= _455_) then
        local input = _455_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _458_
          do
            local _457_ = input
            if (_457_ == next_group_key) then
              _458_ = inc
            else
              local _ = _457_
              _458_ = dec
            end
          end
          group_offset_2a = clamp(_458_(group_offset), 0, max_offset)
          set_label_states_for_sublist(sublist, {["group-offset"] = group_offset_2a})
          return recur(group_offset_2a)
        else
          return {input, group_offset}
        end
      end
    end
    return recur(0, true)
  end
  local function restore_view_on_winleave(curr_target, next_target)
    local _465_
    do
      local t_464_ = curr_target
      if (nil ~= t_464_) then
        t_464_ = (t_464_).wininfo
      end
      if (nil ~= t_464_) then
        t_464_ = (t_464_).winid
      end
      _465_ = t_464_
    end
    local _469_
    do
      local t_468_ = next_target
      if (nil ~= t_468_) then
        t_468_ = (t_468_).wininfo
      end
      if (nil ~= t_468_) then
        t_468_ = (t_468_).winid
      end
      _469_ = t_468_
    end
    if (not instant_repeat_3f and (_465_ ~= _469_)) then
      if curr_target.winview then
        return vim.fn.winrestview(curr_target.winview)
      end
    end
  end
  enter("sx")
  if not repeat_invoc then
    echo("")
    if not (cold_repeat_3f or instant_repeat_3f) then
      grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
    end
    do
      if opts.jump_to_unique_chars then
        highlight_unique_chars(reverse_3f0, _3ftarget_windows, omni_3f)
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _477_ = get_first_input()
  if (nil ~= _477_) then
    local in1 = _477_
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
    local _479_
    local function _481_()
      local t_480_ = instant_state
      if (nil ~= t_480_) then
        t_480_ = (t_480_).sublist
      end
      return t_480_
    end
    local function _483_()
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
    _479_ = (_481_() or get_targets(in1, reverse_3f0, _3ftarget_windows, omni_3f) or _483_())
    local function _485_()
      local _0 = (((_479_)[1]).pair)[1]
      local ch2 = (((_479_)[1]).pair)[2]
      local only = (_479_)[1]
      return opts.jump_to_unique_chars
    end
    if (((type(_479_) == "table") and ((type((_479_)[1]) == "table") and ((type(((_479_)[1]).pair) == "table") and true and (nil ~= (((_479_)[1]).pair)[2]))) and ((_479_)[2] == nil)) and _485_()) then
      local _0 = (((_479_)[1]).pair)[1]
      local ch2 = (((_479_)[1]).pair)[2]
      local only = (_479_)[1]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
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
    elseif (nil ~= _479_) then
      local targets = _479_
      if not instant_repeat_3f then
        local _490_ = targets
        populate_sublists(_490_)
        set_labels(_490_, to_eol_3f)
        set_label_states(_490_)
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _492_ = targets
          set_shortcuts_and_populate_shortcuts_map(_492_)
          set_beacons(_492_, {["repeat"] = nil})
        end
        if not (cold_repeat_3f or instant_repeat_3f) then
          grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
        end
        do
          light_up_beacons(targets, (linewise_3f and to_eol_3f and not instant_repeat_3f))
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _495_
      local function _496_()
        if to_eol_3f then
          return ""
        end
      end
      local function _497_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _498_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _495_ = (prev_in2 or _496_() or _497_() or _498_())
      if (nil ~= _495_) then
        local in2 = _495_
        local _500_
        do
          local t_501_ = targets.shortcuts
          if (nil ~= t_501_) then
            t_501_ = (t_501_)[in2]
          end
          _500_ = t_501_
        end
        if ((type(_500_) == "table") and ((type((_500_).pair) == "table") and true and (nil ~= ((_500_).pair)[2]))) then
          local _0 = ((_500_).pair)[1]
          local ch2 = ((_500_).pair)[2]
          local shortcut = _500_
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut, (ch2 == "\13"))
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _0 = _500_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _504_
          local function _506_()
            local t_505_ = instant_state
            if (nil ~= t_505_) then
              t_505_ = (t_505_).sublist
            end
            return t_505_
          end
          local function _508_()
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
          _504_ = (_506_() or get_sublist(targets, in2) or _508_())
          if ((type(_504_) == "table") and (nil ~= (_504_)[1]) and ((_504_)[2] == nil)) then
            local only = (_504_)[1]
            do
              if dot_repeatable_op_3f then
                set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
              end
              update_state({dot = {in2 = in2, in3 = (opts.labels or opts.safe_labels)[1]}})
              jump_to_21(only)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif ((type(_504_) == "table") and (nil ~= (_504_)[1])) then
            local first = (_504_)[1]
            local sublist = _504_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _512_()
              local t_511_ = instant_state
              if (nil ~= t_511_) then
                t_511_ = (t_511_).idx
              end
              return t_511_
            end
            local function _514_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_512_() or _514_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first, nil, true)
            end
            local _517_
            local function _518_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              end
            end
            local function _519_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _517_ = (_518_() or get_last_input(sublist, inc(curr_idx)) or _519_())
            if ((type(_517_) == "table") and (nil ~= (_517_)[1]) and (nil ~= (_517_)[2])) then
              local in3 = (_517_)[1]
              local group_offset = (_517_)[2]
              local _521_
              if not (op_mode_3f or (group_offset > 0)) then
                _521_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
              _521_ = nil
              end
              if (nil ~= _521_) then
                local action = _521_
                local idx
                do
                  local _523_ = action
                  if (_523_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_523_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                  idx = nil
                  end
                end
                local neighbor = sublist[idx]
                restore_view_on_winleave(first, neighbor)
                jump_to_21(neighbor)
                return sx:go(reverse_3f0, x_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["target-windows"] = _3ftarget_windows, idx = idx, in1 = in1, in2 = in2, sublist = sublist})
              else
                local _1 = _521_
                local _525_
                if not (instant_repeat_3f and not autojump_3f) then
                  _525_ = get_target_with_active_primary_label(sublist, in3)
                else
                _525_ = nil
                end
                if (nil ~= _525_) then
                  local target = _525_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _528_
                    if (group_offset > 0) then
                      _528_ = nil
                    else
                      _528_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _528_}})
                    restore_view_on_winleave(first, target)
                    jump_to_21(target)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _2 = _525_
                  if (autojump_3f or instant_repeat_3f) then
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
    local _let_541_ = vim.split(opt, ".", true)
    local _0 = _let_541_[1]
    local scope = _let_541_[2]
    local name = _let_541_[3]
    local _542_
    if (opt == "vim.wo.scrolloff") then
      _542_ = api.nvim_eval("&l:scrolloff")
    else
      _542_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _542_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_544_ = vim.split(opt, ".", true)
    local _ = _let_544_[1]
    local scope = _let_544_[2]
    local name = _let_544_[3]
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
  for _, _545_ in ipairs(plug_keys) do
    local _each_546_ = _545_
    local lhs = _each_546_[1]
    local rhs_call = _each_546_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _547_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_548_ = _547_
    local lhs = _each_548_[1]
    local rhs_call = _each_548_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"n", "gs", "<Plug>Lightspeed_gs"}, {"n", "gS", "<Plug>Lightspeed_gS"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _549_ in ipairs(default_keymaps) do
    local _each_550_ = _549_
    local mode = _each_550_[1]
    local lhs = _each_550_[2]
    local rhs = _each_550_[3]
    if ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0)) then
      api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
    end
  end
  return nil
end
init_highlight()
set_plug_keys()
if not vim.g.lightspeed_no_default_keymaps then
  set_default_keymaps()
end
vim.cmd("augroup lightspeed_reinit_highlight\n   autocmd!\n   autocmd ColorScheme * lua require'lightspeed'.init_highlight()\n   augroup end")
vim.cmd("augroup lightspeed_editor_opts\n   autocmd!\n   autocmd User LightspeedEnter lua require'lightspeed'.save_editor_opts(); require'lightspeed'.set_temporary_editor_opts()\n   autocmd User LightspeedLeave lua require'lightspeed'.restore_editor_opts()\n   augroup end")
return {ft = ft, init_highlight = init_highlight, opts = opts, restore_editor_opts = restore_editor_opts, save_editor_opts = save_editor_opts, set_default_keymaps = set_default_keymaps, set_temporary_editor_opts = set_temporary_editor_opts, setup = setup, sx = sx}
