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
  local function _22_(t, k)
    if contains_3f(removed_opts, k) then
      return api.nvim_echo(get_warning_msg({k}), true, {})
    end
  end
  guard = _22_
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
local function _26_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {cleanup = _26_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace(""), priority = {cursor = 65535, greywash = 65533, label = 65534}}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _29_
  do
    local _28_ = bg
    if (_28_ == "light") then
      _29_ = "#f02077"
    else
      local _ = _28_
      _29_ = "#ff2f87"
    end
  end
  local _34_
  do
    local _33_ = bg
    if (_33_ == "light") then
      _34_ = "#ff4090"
    else
      local _ = _33_
      _34_ = "#e01067"
    end
  end
  local _39_
  do
    local _38_ = bg
    if (_38_ == "light") then
      _39_ = "Blue"
    else
      local _ = _38_
      _39_ = "Cyan"
    end
  end
  local _44_
  do
    local _43_ = bg
    if (_43_ == "light") then
      _44_ = "#399d9f"
    else
      local _ = _43_
      _44_ = "#99ddff"
    end
  end
  local _49_
  do
    local _48_ = bg
    if (_48_ == "light") then
      _49_ = "Cyan"
    else
      local _ = _48_
      _49_ = "Blue"
    end
  end
  local _54_
  do
    local _53_ = bg
    if (_53_ == "light") then
      _54_ = "#59bdbf"
    else
      local _ = _53_
      _54_ = "#79bddf"
    end
  end
  local _59_
  do
    local _58_ = bg
    if (_58_ == "light") then
      _59_ = "#cc9999"
    else
      local _ = _58_
      _59_ = "#b38080"
    end
  end
  local _64_
  do
    local _63_ = bg
    if (_63_ == "light") then
      _64_ = "Black"
    else
      local _ = _63_
      _64_ = "White"
    end
  end
  local _69_
  do
    local _68_ = bg
    if (_68_ == "light") then
      _69_ = "#272020"
    else
      local _ = _68_
      _69_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _29_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _34_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _39_, gui = "bold,underline", guibg = "NONE", guifg = _44_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _49_, gui = "underline", guifg = _54_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _59_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _64_, gui = "bold", guibg = "NONE", guifg = _69_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _73_ in ipairs(groupdefs) do
    local _each_74_ = _73_
    local group = _each_74_[1]
    local attrs = _each_74_[2]
    local attrs_str
    local _75_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _75_ = tbl_12_auto
    end
    attrs_str = table.concat(_75_, " ")
    local _76_
    if force_3f then
      _76_ = ""
    else
      _76_ = "default "
    end
    vim.cmd(("highlight " .. _76_ .. group .. " " .. attrs_str))
  end
  for _, _78_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_79_ = _78_
    local from_group = _each_79_[1]
    local to_group = _each_79_[2]
    local _80_
    if force_3f then
      _80_ = ""
    else
      _80_ = "default "
    end
    vim.cmd(("highlight " .. _80_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f, _3ftarget_windows, omni_3f)
  if (_3ftarget_windows or omni_3f) then
    for _, win in ipairs((_3ftarget_windows or {vim.fn.getwininfo(vim.fn.win_getid())[1]})) do
      vim.highlight.range(win.bufnr, hl.ns, hl.group.greywash, {dec(win.topline), 0}, {win.botline, -1}, "v", false, hl.priority.greywash)
    end
    return nil
  else
    local _let_82_ = map(dec, get_cursor_pos())
    local curline = _let_82_[1]
    local curcol = _let_82_[2]
    local _let_83_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
    local win_top = _let_83_[1]
    local win_bot = _let_83_[2]
    local function _85_()
      if reverse_3f then
        return {{win_top, 0}, {curline, curcol}}
      else
        return {{curline, inc(curcol)}, {win_bot, -1}}
      end
    end
    local _let_84_ = _85_()
    local start = _let_84_[1]
    local finish = _let_84_[2]
    return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish, "v", false, hl.priority.greywash)
  end
end
local function highlight_range(hl_group, _87_, _89_, _91_)
  local _arg_88_ = _87_
  local startline = _arg_88_[1]
  local startcol = _arg_88_[2]
  local start = _arg_88_
  local _arg_90_ = _89_
  local endline = _arg_90_[1]
  local endcol = _arg_90_[2]
  local _end = _arg_90_
  local _arg_92_ = _91_
  local inclusive_motion_3f = _arg_92_["inclusive-motion?"]
  local motion_force = _arg_92_["motion-force"]
  local hl_range
  local function _93_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, "v", end_inclusive_3f, hl.priority.label)
  end
  hl_range = _93_
  local _94_ = motion_force
  if (_94_ == _3cctrl_v_3e) then
    local _let_95_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_95_[1]
    local endcol0 = _let_95_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_94_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_94_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  elseif (_94_ == nil) then
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
  local function _98_()
    local _97_ = direction
    if (_97_ == "fwd") then
      return "W"
    elseif (_97_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _98_())
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
local function jump_to_21_2a(target, _100_)
  local _arg_101_ = _100_
  local add_to_jumplist_3f = _arg_101_["add-to-jumplist?"]
  local adjust = _arg_101_["adjust"]
  local inclusive_motion_3f = _arg_101_["inclusive-motion?"]
  local mode = _arg_101_["mode"]
  local reverse_3f = _arg_101_["reverse?"]
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
    local _104_ = motion_force
    if (_104_ == nil) then
      if not cursor_before_eof_3f() then
        push_cursor_21("fwd")
      else
        vim.cmd("set virtualedit=onemore")
        vim.cmd("norm! l")
        vim.cmd(restore_virtualedit_autocmd)
      end
    elseif (_104_ == "V") then
    elseif (_104_ == _3cctrl_v_3e) then
    elseif (_104_ == "v") then
      push_cursor_21("bwd")
    end
  end
  return adjusted_pos
end
local function get_onscreen_lines(_108_)
  local _arg_109_ = _108_
  local get_full_window_3f = _arg_109_["get-full-window?"]
  local reverse_3f = _arg_109_["reverse?"]
  local skip_folds_3f = _arg_109_["skip-folds?"]
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
    local _112_
    if reverse_3f then
      _112_ = (lnum >= wintop)
    else
      _112_ = (lnum <= winbot)
    end
    if not _112_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _114_
      if reverse_3f then
        _114_ = dec
      else
        _114_ = inc
      end
      lnum = _114_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _116_
      if reverse_3f then
        _116_ = dec
      else
        _116_ = inc
      end
      lnum = _116_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_119_)
  local _arg_120_ = _119_
  local match_width = _arg_120_["match-width"]
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = dec(vim.fn.wincol())
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - offset_in_editable_win)
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _121_)
  local _arg_122_ = _121_
  local cross_window_3f = _arg_122_["cross-window?"]
  local ft_search_3f = _arg_122_["ft-search?"]
  local limit = _arg_122_["limit"]
  local to_eol_3f = _arg_122_["to-eol?"]
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
  local function _125_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _125_
  local _127_
  if ft_search_3f then
    _127_ = 1
  else
    _127_ = 2
  end
  local _let_126_ = get_horizontal_bounds({["match-width"] = _127_})
  local left_bound = _let_126_[1]
  local right_bound = _let_126_[2]
  local function reach_right_bound()
    while ((vim.fn.virtcol(".") < right_bound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
      vim.cmd("norm! l")
    end
    return nil
  end
  local function skip_to_fold_edge_21()
    local _129_
    local _130_
    if reverse_3f then
      _130_ = vim.fn.foldclosed
    else
      _130_ = vim.fn.foldclosedend
    end
    _129_ = _130_(vim.fn.line("."))
    if (_129_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _129_) then
      local fold_edge = _129_
      vim.fn.cursor(fold_edge, 0)
      local function _132_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _132_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_134_ = {vim.fn.line("."), vim.fn.virtcol(".")}
    local line = _local_134_[1]
    local virtcol = _local_134_[2]
    local from_pos = _local_134_
    local _135_
    if (virtcol < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _135_ = {dec(line), right_bound}
        else
        _135_ = nil
        end
      else
        _135_ = {line, left_bound}
      end
    elseif (virtcol > right_bound) then
      if reverse_3f then
        _135_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _135_ = {inc(line), left_bound}
        else
        _135_ = nil
        end
      end
    else
    _135_ = nil
    end
    if (nil ~= _135_) then
      local to_pos = _135_
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
    local function _144_()
      if reverse_3f then
        return {winbot, right_bound}
      else
        return {wintop, left_bound}
      end
    end
    vim.fn.cursor(_144_())
    if reverse_3f then
      reach_right_bound()
    end
  end
  local function recur(match_at_curpos_3f)
    local match_at_curpos_3f0
    local function _147_()
      if win_enter_3f then
        win_enter_3f = false
        return true
      end
    end
    match_at_curpos_3f0 = (match_at_curpos_3f or _147_())
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _148_
      local _149_
      if match_at_curpos_3f0 then
        _149_ = "c"
      else
        _149_ = ""
      end
      _148_ = vim.fn.searchpos(pattern, (opts0 .. _149_), stopline)
      if ((type(_148_) == "table") and ((_148_)[1] == 0) and true) then
        local _ = (_148_)[2]
        return cleanup()
      elseif ((type(_148_) == "table") and (nil ~= (_148_)[1]) and (nil ~= (_148_)[2])) then
        local line = (_148_)[1]
        local col = (_148_)[2]
        local pos = _148_
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
              else
                local _ = _155_
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
  local _let_162_ = (_3fpos or get_cursor_pos())
  local line = _let_162_[1]
  local col = _let_162_[2]
  local pos = _let_162_
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
  local _165_ = mode
  if (_165_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_165_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
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
  local _175_
  do
    local _174_ = repeat_invoc
    if (_174_ == "dot") then
      _175_ = "dotrepeat_"
    else
      local _ = _174_
      _175_ = ""
    end
  end
  local _180_
  do
    local _179_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((type(_179_) == "table") and ((_179_)[1] == "ft") and ((_179_)[2] == false) and ((_179_)[3] == false)) then
      _180_ = "f"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "ft") and ((_179_)[2] == true) and ((_179_)[3] == false)) then
      _180_ = "F"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "ft") and ((_179_)[2] == false) and ((_179_)[3] == true)) then
      _180_ = "t"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "ft") and ((_179_)[2] == true) and ((_179_)[3] == true)) then
      _180_ = "T"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "sx") and ((_179_)[2] == false) and ((_179_)[3] == false)) then
      _180_ = "s"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "sx") and ((_179_)[2] == true) and ((_179_)[3] == false)) then
      _180_ = "S"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "sx") and ((_179_)[2] == false) and ((_179_)[3] == true)) then
      _180_ = "x"
    elseif ((type(_179_) == "table") and ((_179_)[1] == "sx") and ((_179_)[2] == true) and ((_179_)[3] == true)) then
      _180_ = "X"
    else
    _180_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _175_ .. _180_)
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
  local _191_
  if from_reverse_cold_repeat_3f then
    _191_ = revert_plug_key
  else
    _191_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _191_))) then
    return "repeat"
  else
    local _193_
    if from_reverse_cold_repeat_3f then
      _193_ = repeat_plug_key
    else
      _193_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _193_)))) then
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
    local t_197_ = instant_state
    if (nil ~= t_197_) then
      t_197_ = (t_197_)["reverted?"]
    end
    reverted_instant_repeat_3f = t_197_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _199_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _199_(self.state.cold["reverse?"])
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
    local _205_ = opts.limit_ft_matches
    local function _206_()
      local group_limit = _205_
      return (group_limit > 0)
    end
    if ((nil ~= _205_) and _206_()) then
      local group_limit = _205_
      local matches_left_behind
      local function _208_()
        local _207_ = instant_state
        if _207_ then
          local _209_ = (_207_).stack
          if _209_ then
            return #_209_
          else
            return _209_
          end
        else
          return _207_
        end
      end
      matches_left_behind = (_208_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    else
      local _ = _205_
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
  local _216_
  if instant_repeat_3f then
    _216_ = instant_state["in"]
  elseif dot_repeat_3f then
    _216_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _216_ = self.state.cold["in"]
  else
    local _217_
    local function _218_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _219_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _217_ = (_218_() or _219_())
    if (_217_ == _3cbackspace_3e) then
      local function _221_()
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
      _216_ = (self.state.cold["in"] or _221_())
    elseif (nil ~= _217_) then
      local _in = _217_
      _216_ = _in
    else
    _216_ = nil
    end
  end
  if (nil ~= _216_) then
    local in1 = _216_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _226_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _226_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local _227_
        if opts.ignore_case then
          _227_ = "\\c"
        else
          _227_ = "\\C"
        end
        pattern = ("\\V" .. _227_ .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _230_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_231_ = _230_
        local line = _each_231_[1]
        local col = _each_231_[2]
        local pos = _each_231_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              local ch = (char_at_pos(pos, {}) or "\13")
              local ch0
              local function _233_()
                local t_232_ = opts.substitute_chars
                if (nil ~= t_232_) then
                  t_232_ = (t_232_)[ch]
                end
                return t_232_
              end
              ch0 = (_233_() or ch)
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
        local function _239_()
          if t_mode_3f0 then
            local function _240_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_240_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            end
          end
        end
        jump_to_21_2a(jump_pos, {["add-to-jumplist?"] = not instant_repeat_3f, ["inclusive-motion?"] = true, ["reverse?"] = reverse_3f0, adjust = _239_, mode = mode})
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
        local _245_
        local function _246_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _247_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _245_ = (_246_() or _247_())
        if (nil ~= _245_) then
          local in2 = _245_
          local stack
          local function _249_()
            local t_248_ = instant_state
            if (nil ~= t_248_) then
              t_248_ = (t_248_).stack
            end
            return t_248_
          end
          stack = (_249_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _252_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_252_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = false, stack = stack})
          elseif (_252_ == "revert") then
            do
              local _253_ = table.remove(stack)
              if _253_ then
                vim.fn.cursor(_253_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = true, stack = stack})
          else
            local _ = _252_
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
  local _let_260_ = vim.split(vim.fn.string(vim.fn.winlayout()), tostring(curr_win_id))
  local left = _let_260_[1]
  local right = _let_260_[2]
  local ids
  local _261_
  if reverse_3f then
    _261_ = left
  else
    _261_ = right
  end
  ids = string.gmatch(_261_, "%d+")
  local visual_or_OP_mode_3f = (vim.fn.mode() ~= "n")
  local buf = api.nvim_win_get_buf
  local ids0
  do
    local tbl_12_auto = {}
    for id in ids do
      local _263_
      if not (visual_or_OP_mode_3f and (buf(id) ~= buf(curr_win_id))) then
        _263_ = id
      else
      _263_ = nil
      end
      tbl_12_auto[(#tbl_12_auto + 1)] = _263_
    end
    ids0 = tbl_12_auto
  end
  local ids1
  if reverse_3f then
    ids1 = vim.fn.reverse(ids0)
  else
    ids1 = ids0
  end
  local function _266_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  return map(_266_, ids1)
end
local function highlight_unique_chars(reverse_3f, _3ftarget_windows, omni_3f)
  local unique_chars = {}
  local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local _let_267_ = get_cursor_pos()
  local curline = _let_267_[1]
  local curcol = _let_267_[2]
  for _, w in ipairs((_3ftarget_windows or {curr_w})) do
    if _3ftarget_windows then
      api.nvim_set_current_win(w.winid)
    end
    local _let_269_ = get_horizontal_bounds({["match-width"] = 2})
    local left_bound = _let_269_[1]
    local right_bound = _let_269_[2]
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
          local _274_
          do
            local _273_ = unique_chars[ch0]
            if (nil ~= _273_) then
              local pos_already_there = _273_
              _274_ = false
            else
              local _0 = _273_
              _274_ = {lnum, col, w}
            end
          end
          unique_chars[ch0] = _274_
        end
      end
    end
  end
  if _3ftarget_windows then
    api.nvim_set_current_win(curr_w.winid)
  end
  for ch, pos in pairs(unique_chars) do
    local _280_ = pos
    if ((type(_280_) == "table") and (nil ~= (_280_)[1]) and (nil ~= (_280_)[2]) and (nil ~= (_280_)[3])) then
      local lnum = (_280_)[1]
      local col = (_280_)[2]
      local w = (_280_)[3]
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
    local _282_
    if opts.ignore_case then
      _282_ = "\\c"
    else
      _282_ = "\\C"
    end
    pattern = ("\\V" .. _282_ .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _285_ in onscreen_match_positions(pattern, reverse_3f, {["cross-window?"] = _3fwininfo, ["to-eol?"] = to_eol_3f}) do
    local _each_286_ = _285_
    local line = _each_286_[1]
    local col = _each_286_[2]
    local pos = _each_286_
    local target = {pos = pos, wininfo = _3fwininfo}
    if to_eol_3f then
      target["pair"] = {"\n", ""}
      table.insert(targets, target)
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _287_
      if reverse_3f then
        _287_ = dec
      else
        _287_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _287_(prev_match.col)))
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
          local _289_ = prev_target
          if ((type(_289_) == "table") and ((type((_289_).pos) == "table") and (nil ~= ((_289_).pos)[1]) and (nil ~= ((_289_).pos)[2]))) then
            local prev_line = ((_289_).pos)[1]
            local prev_col = ((_289_).pos)[2]
            local function _291_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta < min_delta_to_prevent_squeezing)
            end
            close_to_prev_target_3f = ((line == prev_line) and _291_())
          else
          close_to_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        end
        if close_to_prev_target_3f then
          local _294_
          if reverse_3f then
            _294_ = target
          else
            _294_ = prev_target
          end
          _294_["squeezed?"] = true
        end
        if overlaps_prev_target_3f then
          local _297_
          if reverse_3f then
            _297_ = prev_target
          else
            _297_ = target
          end
          _297_["overlapped?"] = true
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
    local fwd_targets = get_targets_2a(input, false)
    local targets = get_targets_2a(input, true, nil, fwd_targets)
    local calculate_screen_positions_3f = (vim.wo.wrap and (#targets < 200))
    local winid = vim.fn.win_getid()
    local _let_303_ = get_cursor_pos()
    local curline = _let_303_[1]
    local curcol = _let_303_[2]
    local curscreenpos = vim.fn.screenpos(winid, curline, curcol)
    local editor_grid_aspect_ratio = 0.3
    local to_eol_3f = (input == "\13")
    local function dist_from_cursor(target)
      local function _305_()
        if calculate_screen_positions_3f then
          return {abs((target.screenpos.col - curscreenpos.col)), abs((target.screenpos.row - curscreenpos.row))}
        else
          return {abs((target.pos[2] - curcol)), abs((target.pos[1] - curline))}
        end
      end
      local _let_304_ = _305_()
      local dx = _let_304_[1]
      local dy = _let_304_[2]
      local dx0
      local _306_
      if to_eol_3f then
        _306_ = 0
      else
        _306_ = 1
      end
      dx0 = (dx * editor_grid_aspect_ratio * _306_)
      return math.pow((math.pow(dx0, 2) + math.pow(dy, 2)), 0.5)
    end
    local function by_dist_from_cursor(t1, t2)
      return (dist_from_cursor(t1) < dist_from_cursor(t2))
    end
    if next(targets) then
      if calculate_screen_positions_3f then
        for _, _308_ in ipairs(targets) do
          local _each_309_ = _308_
          local t = _each_309_
          local _each_310_ = _each_309_["pos"]
          local line = _each_310_[1]
          local col = _each_310_[2]
          t["screenpos"] = vim.fn.screenpos(winid, line, col)
        end
      end
      table.sort(targets, by_dist_from_cursor)
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
    local function _315_(self, k)
      return rawget(self, k:lower())
    end
    local function _316_(self, k, v)
      return rawset(self, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _315_, __newindex = _316_})
  end
  for _, _318_ in ipairs(targets) do
    local _each_319_ = _318_
    local target = _each_319_
    local _each_320_ = _each_319_["pair"]
    local _0 = _each_320_[1]
    local ch2 = _each_320_[2]
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
    local _325_ = sublist["autojump?"]
    if (_325_ == true) then
      return opts.safe_labels
    elseif (_325_ == false) then
      return opts.labels
    elseif (_325_ == nil) then
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
        local _328_
        if not (sublist["autojump?"] and (i == 1)) then
          local _329_
          local _331_
          if sublist["autojump?"] then
            _331_ = dec(i)
          else
            _331_ = i
          end
          _329_ = (_331_ % #labels)
          if (_329_ == 0) then
            _328_ = last(labels)
          elseif (nil ~= _329_) then
            local n = _329_
            _328_ = labels[n]
          else
          _328_ = nil
          end
        else
        _328_ = nil
        end
        target["label"] = _328_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _338_)
  local _arg_339_ = _338_
  local group_offset = _arg_339_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _340_
  if sublist["autojump?"] then
    _340_ = 2
  else
    _340_ = 1
  end
  primary_start = (offset + _340_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _342_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _342_ = "inactive"
      elseif (i <= primary_end) then
        _342_ = "active-primary"
      else
        _342_ = "active-secondary"
      end
    else
    _342_ = nil
    end
    target["label-state"] = _342_
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
      local _345_, _346_ = ch2, true
      if ((nil ~= _345_) and (nil ~= _346_)) then
        local k_10_auto = _345_
        local v_11_auto = _346_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _348_ in ipairs(targets) do
    local _each_349_ = _348_
    local target = _each_349_
    local label = _each_349_["label"]
    local label_state = _each_349_["label-state"]
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
local function set_beacon(_352_, _repeat)
  local _arg_353_ = _352_
  local target = _arg_353_
  local label = _arg_353_["label"]
  local label_state = _arg_353_["label-state"]
  local overlapped_3f = _arg_353_["overlapped?"]
  local _arg_354_ = _arg_353_["pair"]
  local ch1 = _arg_354_[1]
  local ch2 = _arg_354_[2]
  local _arg_355_ = _arg_353_["pos"]
  local _ = _arg_355_[1]
  local col = _arg_355_[2]
  local left_bound = _arg_355_[3]
  local right_bound = _arg_355_[4]
  local shortcut_3f = _arg_353_["shortcut?"]
  local squeezed_3f = _arg_353_["squeezed?"]
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local ch10
  if to_eol_3f then
    ch10 = "\13"
  else
    ch10 = ch1
  end
  local function _358_(_241)
    local function _360_()
      local t_359_ = opts.substitute_chars
      if (nil ~= t_359_) then
        t_359_ = (t_359_)[_241]
      end
      return t_359_
    end
    return (_360_() or _241)
  end
  local _let_357_ = map(_358_, {ch10, ch2})
  local ch11 = _let_357_[1]
  local ch20 = _let_357_[2]
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
    local _362_ = label_state
    if (_362_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hg["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch11 .. ch20), hg["unlabeled-match"]}}}
        end
      else
      target.beacon = nil
      end
    elseif (_362_ == "active-primary") then
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
        local _366_
        if squeezed_3f0 then
          _366_ = 1
        else
          _366_ = 2
        end
        target.beacon = {_366_, {shortcut_24}}
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
    elseif (_362_ == "active-secondary") then
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
        local _372_
        if squeezed_3f0 then
          _372_ = 1
        else
          _372_ = 2
        end
        target.beacon = {_372_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_362_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _377_)
  local _arg_378_ = _377_
  local _repeat = _arg_378_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, ghost_beacons_3f, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_379_ = target_list[i]
    local target = _let_379_
    local _let_380_ = _let_379_["pos"]
    local line = _let_380_[1]
    local col = _let_380_[2]
    local _381_ = target.beacon
    if ((type(_381_) == "table") and (nil ~= (_381_)[1]) and (nil ~= (_381_)[2]) and true) then
      local offset = (_381_)[1]
      local chunks = (_381_)[2]
      local _3fleft_off_3f = (_381_)[3]
      local function _383_()
        local t_382_ = target.wininfo
        if (nil ~= t_382_) then
          t_382_ = (t_382_).bufnr
        end
        return t_382_
      end
      local _385_
      if _3fleft_off_3f then
        _385_ = 0
      else
      _385_ = nil
      end
      api.nvim_buf_set_extmark((_383_() or 0), hl.ns, dec(line), dec((col + offset)), {priority = hl.priority.label, virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _385_})
      if ghost_beacons_3f then
        local curcol = vim.fn.col(".")
        local col_delta = abs((curcol - col))
        local min_col_delta = 5
        if (col_delta > min_col_delta) then
          local chunks0
          do
            local _387_ = target["label-state"]
            if (_387_ == "active-primary") then
              chunks0 = {{target.label, hl.group["label-overlapped"]}}
            elseif (_387_ == "active-secondary") then
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
  for _, _392_ in ipairs(target_list) do
    local _each_393_ = _392_
    local target = _each_393_
    local label = _each_393_["label"]
    local label_state = _each_393_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _395_ = opts.jump_to_unique_chars
  if ((type(_395_) == "table") and (nil ~= (_395_).safety_timeout)) then
    local timeout = (_395_).safety_timeout
    local _396_ = get_input(timeout)
    if (nil ~= _396_) then
      local input = _396_
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
  local dot_repeatable_op_3f = (op_mode_3f and (vim.v.operator ~= "y"))
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
    local function _401_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _401_(self.state.cold["reverse?"])
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
  local function _405_()
    if cross_window_3f then
      return get_targetable_windows(reverse_3f0)
    end
  end
  local function _406_()
    if instant_repeat_3f then
      return instant_state["target-windows"]
    end
  end
  _3ftarget_windows = (_405_() or _406_())
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
      local _407_
      local function _408_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _409_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _407_ = (_408_() or _409_())
      local function _411_()
        return not omni_3f
      end
      if ((_407_ == "\9") and _411_()) then
        sx:go(not reverse_3f0, x_mode_3f0, false, cross_window_3f)
        return nil
      elseif (_407_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _412_()
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
        return (self.state.cold.in1 or _412_())
      elseif (nil ~= _407_) then
        local _in = _407_
        return _in
      end
    end
  end
  local function update_state_2a(in1)
    local function _418_(_416_)
      local _arg_417_ = _416_
      local cold = _arg_417_["cold"]
      local dot = _arg_417_["dot"]
      if new_search_3f then
        if cold then
          local _419_ = cold
          _419_["in1"] = in1
          _419_["x-mode?"] = x_mode_3f0
          _419_["reverse?"] = reverse_3f0
          self.state.cold = _419_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _421_ = dot
              _421_["in1"] = in1
              _421_["x-mode?"] = x_mode_3f0
              self.state.dot = _421_
            end
            return nil
          end
        end
      end
    end
    return _418_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _425_(target, _3fto_pre_eol_3f, _3fsave_winview_3f)
      if target.wininfo then
        api.nvim_set_current_win(target.wininfo.winid)
        if _3fsave_winview_3f then
          target["winview"] = vim.fn.winsaveview()
        end
      end
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      local function _428_()
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
      adjusted_pos = jump_to_21_2a(target.pos, {["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["reverse?"] = reverse_3f0, adjust = _428_, mode = mode})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _425_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _434_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_433_ = _434_()
    local startline = _let_433_[1]
    local startcol = _let_433_[2]
    local start = _let_433_
    local function _436_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_435_ = _436_()
    local _ = _let_435_[1]
    local endcol = _let_435_[2]
    local _end = _let_435_
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
    local _441_ = targets.sublists[ch]
    if (nil ~= _441_) then
      local sublist = _441_
      local _let_442_ = sublist
      local _let_443_ = _let_442_[1]
      local _let_444_ = _let_443_["pos"]
      local line = _let_444_[1]
      local col = _let_444_[2]
      local rest = {(table.unpack or unpack)(_let_442_, 2)}
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
      local _448_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _448_ = "cold"
      elseif instant_repeat_3f then
        if sublist["autojump?"] then
          _448_ = "instant"
        else
          _448_ = "instant-unsafe"
        end
      else
      _448_ = nil
      end
      set_beacons(sublist, {["repeat"] = _448_})
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
      local _452_
      do
        local res_2_auto
        do
          local function _453_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_453_())
        end
        hl:cleanup(_3ftarget_windows)
        _452_ = res_2_auto
      end
      if (nil ~= _452_) then
        local input = _452_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _455_
          do
            local _454_ = input
            if (_454_ == next_group_key) then
              _455_ = inc
            else
              local _ = _454_
              _455_ = dec
            end
          end
          group_offset_2a = clamp(_455_(group_offset), 0, max_offset)
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
    local _462_
    do
      local t_461_ = curr_target
      if (nil ~= t_461_) then
        t_461_ = (t_461_).wininfo
      end
      if (nil ~= t_461_) then
        t_461_ = (t_461_).winid
      end
      _462_ = t_461_
    end
    local _466_
    do
      local t_465_ = next_target
      if (nil ~= t_465_) then
        t_465_ = (t_465_).wininfo
      end
      if (nil ~= t_465_) then
        t_465_ = (t_465_).winid
      end
      _466_ = t_465_
    end
    if (not instant_repeat_3f and (_462_ ~= _466_)) then
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
  local _474_ = get_first_input()
  if (nil ~= _474_) then
    local in1 = _474_
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
    local _476_
    local function _478_()
      local t_477_ = instant_state
      if (nil ~= t_477_) then
        t_477_ = (t_477_).sublist
      end
      return t_477_
    end
    local function _480_()
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
    _476_ = (_478_() or get_targets(in1, reverse_3f0, _3ftarget_windows, omni_3f) or _480_())
    local function _482_()
      local only = (_476_)[1]
      local _0 = (((_476_)[1]).pair)[1]
      local ch2 = (((_476_)[1]).pair)[2]
      return opts.jump_to_unique_chars
    end
    if (((type(_476_) == "table") and ((type((_476_)[1]) == "table") and ((type(((_476_)[1]).pair) == "table") and true and (nil ~= (((_476_)[1]).pair)[2]))) and ((_476_)[2] == nil)) and _482_()) then
      local only = (_476_)[1]
      local _0 = (((_476_)[1]).pair)[1]
      local ch2 = (((_476_)[1]).pair)[2]
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
    elseif (nil ~= _476_) then
      local targets = _476_
      if not instant_repeat_3f then
        local _487_ = targets
        populate_sublists(_487_)
        set_labels(_487_, to_eol_3f)
        set_label_states(_487_)
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _489_ = targets
          set_shortcuts_and_populate_shortcuts_map(_489_)
          set_beacons(_489_, {["repeat"] = nil})
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
      local _492_
      local function _493_()
        if to_eol_3f then
          return ""
        end
      end
      local function _494_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _495_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _492_ = (prev_in2 or _493_() or _494_() or _495_())
      if (nil ~= _492_) then
        local in2 = _492_
        local _497_
        do
          local t_498_ = targets.shortcuts
          if (nil ~= t_498_) then
            t_498_ = (t_498_)[in2]
          end
          _497_ = t_498_
        end
        if ((type(_497_) == "table") and ((type((_497_).pair) == "table") and true and (nil ~= ((_497_).pair)[2]))) then
          local shortcut = _497_
          local _0 = ((_497_).pair)[1]
          local ch2 = ((_497_).pair)[2]
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
          local _0 = _497_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _501_
          local function _503_()
            local t_502_ = instant_state
            if (nil ~= t_502_) then
              t_502_ = (t_502_).sublist
            end
            return t_502_
          end
          local function _505_()
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
          _501_ = (_503_() or get_sublist(targets, in2) or _505_())
          if ((type(_501_) == "table") and (nil ~= (_501_)[1]) and ((_501_)[2] == nil)) then
            local only = (_501_)[1]
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
          elseif ((type(_501_) == "table") and (nil ~= (_501_)[1])) then
            local first = (_501_)[1]
            local sublist = _501_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _509_()
              local t_508_ = instant_state
              if (nil ~= t_508_) then
                t_508_ = (t_508_).idx
              end
              return t_508_
            end
            local function _511_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_509_() or _511_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first, nil, true)
            end
            local _514_
            local function _515_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              end
            end
            local function _516_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _514_ = (_515_() or get_last_input(sublist, inc(curr_idx)) or _516_())
            if ((type(_514_) == "table") and (nil ~= (_514_)[1]) and (nil ~= (_514_)[2])) then
              local in3 = (_514_)[1]
              local group_offset = (_514_)[2]
              local _518_
              if not (op_mode_3f or (group_offset > 0)) then
                _518_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
              _518_ = nil
              end
              if (nil ~= _518_) then
                local action = _518_
                local idx
                do
                  local _520_ = action
                  if (_520_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_520_ == "revert") then
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
                local _1 = _518_
                local _522_
                if not (instant_repeat_3f and not autojump_3f) then
                  _522_ = get_target_with_active_primary_label(sublist, in3)
                else
                _522_ = nil
                end
                if (nil ~= _522_) then
                  local target = _522_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _525_
                    if (group_offset > 0) then
                      _525_ = nil
                    else
                      _525_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _525_}})
                    restore_view_on_winleave(first, target)
                    jump_to_21(target)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _2 = _522_
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
    local _let_538_ = vim.split(opt, ".", true)
    local _0 = _let_538_[1]
    local scope = _let_538_[2]
    local name = _let_538_[3]
    local _539_
    if (opt == "vim.wo.scrolloff") then
      _539_ = api.nvim_eval("&l:scrolloff")
    else
      _539_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _539_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_541_ = vim.split(opt, ".", true)
    local _ = _let_541_[1]
    local scope = _let_541_[2]
    local name = _let_541_[3]
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
  for _, _542_ in ipairs(plug_keys) do
    local _each_543_ = _542_
    local lhs = _each_543_[1]
    local rhs_call = _each_543_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _544_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_545_ = _544_
    local lhs = _each_545_[1]
    local rhs_call = _each_545_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"n", "gs", "<Plug>Lightspeed_gs"}, {"n", "gS", "<Plug>Lightspeed_gS"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _546_ in ipairs(default_keymaps) do
    local _each_547_ = _546_
    local mode = _each_547_[1]
    local lhs = _each_547_[2]
    local rhs = _each_547_[3]
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
