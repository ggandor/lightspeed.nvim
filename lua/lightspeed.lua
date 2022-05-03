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
  local function _25_(t, k)
    if contains_3f(removed_opts, k) then
      return api.nvim_echo(get_warning_msg({k}), true, {})
    else
      return nil
    end
  end
  guard = _25_
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
local function _29_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  else
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {group = {label = "LightspeedLabel", ["label-distant"] = "LightspeedLabelDistant", ["label-overlapped"] = "LightspeedLabelOverlapped", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", shortcut = "LightspeedShortcut", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", ["one-char-match"] = "LightspeedOneCharMatch", ["unique-ch"] = "LightspeedUniqueChar", ["pending-op-area"] = "LightspeedPendingOpArea", greywash = "LightspeedGreyWash", cursor = "LightspeedCursor"}, priority = {cursor = 65535, label = 65534, greywash = 65533}, ns = api.nvim_create_namespace(""), cleanup = _29_}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _32_
  do
    local _31_ = bg
    if (_31_ == "light") then
      _32_ = "#f02077"
    elseif true then
      local _ = _31_
      _32_ = "#ff2f87"
    else
      _32_ = nil
    end
  end
  local _37_
  do
    local _36_ = bg
    if (_36_ == "light") then
      _37_ = "#399d9f"
    elseif true then
      local _ = _36_
      _37_ = "#99ddff"
    else
      _37_ = nil
    end
  end
  local _42_
  do
    local _41_ = bg
    if (_41_ == "light") then
      _42_ = "Blue"
    elseif true then
      local _ = _41_
      _42_ = "Cyan"
    else
      _42_ = nil
    end
  end
  local _47_
  do
    local _46_ = bg
    if (_46_ == "light") then
      _47_ = "#cc9999"
    elseif true then
      local _ = _46_
      _47_ = "#b38080"
    else
      _47_ = nil
    end
  end
  local _52_
  do
    local _51_ = bg
    if (_51_ == "light") then
      _52_ = "#272020"
    elseif true then
      local _ = _51_
      _52_ = "#f3ecec"
    else
      _52_ = nil
    end
  end
  local _57_
  do
    local _56_ = bg
    if (_56_ == "light") then
      _57_ = "Black"
    elseif true then
      local _ = _56_
      _57_ = "White"
    else
      _57_ = nil
    end
  end
  groupdefs = {[hl.group.label] = {guifg = _32_, ctermfg = "Red", guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}, [hl.group["label-distant"]] = {guifg = _37_, ctermfg = _42_, guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}, [hl.group.shortcut] = {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold", cterm = "bold"}, [hl.group["masked-ch"]] = {guifg = _47_, ctermfg = "DarkGrey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}, [hl.group["unlabeled-match"]] = {guifg = _52_, ctermfg = _57_, guibg = "NONE", ctermbg = "NONE", gui = "bold", cterm = "bold"}, [hl.group.greywash] = {guifg = "#777777", ctermfg = "Grey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}}
  for name, hl_def_map in pairs(groupdefs) do
    local attrs_str
    local _61_
    do
      local tbl_15_auto = {}
      local i_16_auto = #tbl_15_auto
      for k, v in pairs(hl_def_map) do
        local val_17_auto = (k .. "=" .. v)
        if (nil ~= val_17_auto) then
          i_16_auto = (i_16_auto + 1)
          do end (tbl_15_auto)[i_16_auto] = val_17_auto
        else
        end
      end
      _61_ = tbl_15_auto
    end
    attrs_str = table.concat(_61_, " ")
    local function _63_()
      if force_3f then
        return ""
      else
        return "default "
      end
    end
    vim.cmd(("highlight " .. _63_() .. name .. " " .. attrs_str))
  end
  for from_group, to_group in pairs({[hl.group["unique-ch"]] = hl.group["unlabeled-match"], [hl.group["label-overlapped"]] = hl.group.label, [hl.group["label-distant-overlapped"]] = hl.group["label-distant"], [hl.group["one-char-match"]] = hl.group.shortcut, [hl.group["shortcut-overlapped"]] = hl.group.shortcut, [hl.group["pending-op-area"]] = "IncSearch", [hl.group.cursor] = "Cursor"}) do
    local function _64_()
      if force_3f then
        return "! "
      else
        return " default "
      end
    end
    vim.cmd(("highlight" .. _64_() .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f, _3ftarget_windows, omni_3f)
  if (_3ftarget_windows or omni_3f) then
    for _, win in ipairs((_3ftarget_windows or {vim.fn.getwininfo(vim.fn.win_getid())[1]})) do
      highlight_range_compat(win.bufnr, hl.ns, hl.group.greywash, {dec(win.topline), 0}, {dec(win.botline), -1}, {priority = hl.priority.greywash})
    end
    return nil
  else
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
    return highlight_range_compat(0, hl.ns, hl.group.greywash, start, finish, {priority = hl.priority.greywash})
  end
end
local function highlight_range(hl_group, _70_, _72_, _74_)
  local _arg_71_ = _70_
  local startline = _arg_71_[1]
  local startcol = _arg_71_[2]
  local start = _arg_71_
  local _arg_73_ = _72_
  local endline = _arg_73_[1]
  local endcol = _arg_73_[2]
  local _end = _arg_73_
  local _arg_75_ = _74_
  local motion_force = _arg_75_["motion-force"]
  local inclusive_motion_3f = _arg_75_["inclusive-motion?"]
  local hl_range
  local function _76_(start0, _end0, end_inclusive_3f)
    return highlight_range_compat(0, hl.ns, hl_group, start0, _end0, {inclusive = end_inclusive_3f, priority = hl.priority.label})
  end
  hl_range = _76_
  local _77_ = motion_force
  if (_77_ == _3cctrl_v_3e) then
    local _let_78_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_78_[1]
    local endcol0 = _let_78_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_77_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_77_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  elseif (_77_ == nil) then
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
  local function _81_()
    local _80_ = direction
    if (_80_ == "fwd") then
      return "W"
    elseif (_80_ == "bwd") then
      return "bW"
    else
      return nil
    end
  end
  return vim.fn.search("\\_.", _81_())
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
local function jump_to_21_2a(target, _83_)
  local _arg_84_ = _83_
  local mode = _arg_84_["mode"]
  local reverse_3f = _arg_84_["reverse?"]
  local inclusive_motion_3f = _arg_84_["inclusive-motion?"]
  local add_to_jumplist_3f = _arg_84_["add-to-jumplist?"]
  local adjust = _arg_84_["adjust"]
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
    local _87_ = motion_force
    if (_87_ == nil) then
      if not cursor_before_eof_3f() then
        push_cursor_21("fwd")
      else
        vim.cmd("set virtualedit=onemore")
        vim.cmd("norm! l")
        vim.cmd(restore_virtualedit_autocmd)
      end
    elseif (_87_ == "V") then
    elseif (_87_ == _3cctrl_v_3e) then
    elseif (_87_ == "v") then
      push_cursor_21("bwd")
    else
    end
  else
  end
  return adjusted_pos
end
local function highlight_cursor(_3fpos)
  local _let_91_ = (_3fpos or get_cursor_pos())
  local line = _let_91_[1]
  local col = _let_91_[2]
  local pos = _let_91_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {virt_text = {{ch_at_curpos, hl.group.cursor}}, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.cursor})
end
local function handle_interrupted_change_op_21()
  local seq
  local function _92_()
    if (vim.fn.col(".") > 1) then
      return "<RIGHT>"
    else
      return ""
    end
  end
  seq = ("<C-\\><C-G>" .. _92_())
  return api.nvim_feedkeys(replace_keycodes(seq), "n", true)
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
  local _94_ = mode
  if (_94_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_94_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  else
    return nil
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _96_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _96_
  local getchar_timeout
  local function _97_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    else
      return nil
    end
  end
  getchar_timeout = _97_
  local ok_3f, ch = nil, nil
  local function _99_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_99_())
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
local function ignore_input_until_timeout(input_to_ignore, timeout)
  local _102_ = get_input(timeout)
  if (nil ~= _102_) then
    local input = _102_
    if (input ~= input_to_ignore) then
      return vim.fn.feedkeys(input, "i")
    else
      return nil
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
  local function _107_()
    local _106_ = repeat_invoc
    if (_106_ == "dot") then
      return "dotrepeat_"
    elseif true then
      local _ = _106_
      return ""
    else
      return nil
    end
  end
  local function _110_()
    local _109_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((_G.type(_109_) == "table") and ((_109_)[1] == "ft") and ((_109_)[2] == false) and ((_109_)[3] == false)) then
      return "f"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "ft") and ((_109_)[2] == true) and ((_109_)[3] == false)) then
      return "F"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "ft") and ((_109_)[2] == false) and ((_109_)[3] == true)) then
      return "t"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "ft") and ((_109_)[2] == true) and ((_109_)[3] == true)) then
      return "T"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "sx") and ((_109_)[2] == false) and ((_109_)[3] == false)) then
      return "s"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "sx") and ((_109_)[2] == true) and ((_109_)[3] == false)) then
      return "S"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "sx") and ((_109_)[2] == false) and ((_109_)[3] == true)) then
      return "x"
    elseif ((_G.type(_109_) == "table") and ((_109_)[1] == "sx") and ((_109_)[2] == true) and ((_109_)[3] == true)) then
      return "X"
    else
      return nil
    end
  end
  return ("<Plug>Lightspeed_" .. _107_() .. _110_())
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
  local function _113_()
    local _114_
    if from_reverse_cold_repeat_3f then
      _114_ = revert_plug_key
    else
      _114_ = repeat_plug_key
    end
    return ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _114_))
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or _113_()) then
    return "repeat"
  else
    local function _116_()
      local _117_
      if from_reverse_cold_repeat_3f then
        _117_ = repeat_plug_key
      else
        _117_ = revert_plug_key
      end
      return ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _117_))
    end
    if (instant_repeat_3f and ((_in == "\9") or _116_())) then
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
    local t_121_ = instant_state
    if (nil ~= t_121_) then
      t_121_ = (t_121_)["reverted?"]
    else
    end
    reverted_instant_repeat_3f = t_121_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _123_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _123_(self.state.cold["reverse?"])
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
  local function match_positions(pattern, reverse_3f1, limit)
    local view = vim.fn.winsaveview()
    local cleanup
    local function _129_()
      vim.fn.winrestview(view)
      return nil
    end
    cleanup = _129_
    local match_count = 0
    local function _130_()
      if (limit and (match_count >= limit)) then
        return cleanup()
      else
        local _131_
        local function _132_()
          if reverse_3f1 then
            return "bW"
          else
            return "W"
          end
        end
        _131_ = vim.fn.searchpos(pattern, _132_())
        if ((_G.type(_131_) == "table") and ((_131_)[1] == 0) and true) then
          local _ = (_131_)[2]
          return cleanup()
        elseif ((_G.type(_131_) == "table") and (nil ~= (_131_)[1]) and (nil ~= (_131_)[2])) then
          local line = (_131_)[1]
          local col = (_131_)[2]
          local pos = _131_
          match_count = (match_count + 1)
          return pos
        else
          return nil
        end
      end
    end
    return _130_
  end
  local function get_num_of_matches_to_be_highlighted()
    local _135_ = opts.limit_ft_matches
    local function _136_()
      local group_limit = _135_
      return (group_limit > 0)
    end
    if ((nil ~= _135_) and _136_()) then
      local group_limit = _135_
      local matches_left_behind
      local function _137_()
        local _138_ = instant_state
        if (nil ~= _138_) then
          local _139_ = (_138_).stack
          if (nil ~= _139_) then
            return #_139_
          else
            return _139_
          end
        else
          return _138_
        end
      end
      matches_left_behind = (_137_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    elseif true then
      local _ = _135_
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
  local _146_
  if instant_repeat_3f then
    _146_ = instant_state["in"]
  elseif dot_repeat_3f then
    _146_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _146_ = self.state.cold["in"]
  else
    local _147_
    local function _148_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      api.nvim_buf_clear_namespace(0, hl.ns, 0, -1)
      return res_2_auto
    end
    local function _149_()
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
    _147_ = (_148_() or _149_())
    if (_147_ == _3cbackspace_3e) then
      local function _151_()
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
      _146_ = (self.state.cold["in"] or _151_())
    elseif (nil ~= _147_) then
      local _in = _147_
      _146_ = _in
    else
      _146_ = nil
    end
  end
  if (nil ~= _146_) then
    local in1 = _146_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    else
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _156_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _156_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local function _157_()
          if opts.ignore_case then
            return "\\c"
          else
            return "\\C"
          end
        end
        pattern = ("\\V" .. _157_() .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _159_ in match_positions(pattern, reverse_3f0, limit) do
        local _each_160_ = _159_
        local line = _each_160_[1]
        local col = _each_160_[2]
        local pos = _each_160_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              local ch = (char_at_pos(pos, {}) or "\13")
              local ch0
              local function _161_()
                local t_162_ = opts.substitute_chars
                if (nil ~= t_162_) then
                  t_162_ = (t_162_)[ch]
                else
                end
                return t_162_
              end
              ch0 = (_161_() or ch)
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
        local function _168_()
          if t_mode_3f0 then
            local function _169_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_169_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            else
              return nil
            end
          else
            return nil
          end
        end
        jump_to_21_2a(jump_pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = true, ["add-to-jumplist?"] = not instant_repeat_3f, adjust = _168_})
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
        local _174_
        local function _175_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          api.nvim_buf_clear_namespace(0, hl.ns, 0, -1)
          return res_2_auto
        end
        local function _176_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _174_ = (_175_() or _176_())
        if (nil ~= _174_) then
          local in2 = _174_
          local stack
          local function _177_()
            local t_178_ = instant_state
            if (nil ~= t_178_) then
              t_178_ = (t_178_).stack
            else
            end
            return t_178_
          end
          stack = (_177_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _181_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_181_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, stack = stack, ["reverted?"] = false, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
          elseif (_181_ == "revert") then
            do
              local _182_ = table.remove(stack)
              if (nil ~= _182_) then
                vim.fn.cursor(_182_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, stack = stack, ["reverted?"] = true, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
          elseif true then
            local _ = _181_
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
local function get_horizontal_bounds()
  local match_width = 2
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = dec(vim.fn.wincol())
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - offset_in_editable_win)
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _189_)
  local _arg_190_ = _189_
  local cross_window_3f = _arg_190_["cross-window?"]
  local to_eol_3f = _arg_190_["to-eol?"]
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
  local function _193_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _193_
  local _let_194_ = get_horizontal_bounds()
  local left_bound = _let_194_[1]
  local right_bound = _let_194_[2]
  local function reach_right_bound()
    while ((vim.fn.virtcol(".") < right_bound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
      vim.cmd("norm! l")
    end
    return nil
  end
  local function skip_to_fold_edge_21()
    local _195_
    local _196_
    if reverse_3f then
      _196_ = vim.fn.foldclosed
    else
      _196_ = vim.fn.foldclosedend
    end
    _195_ = _196_(vim.fn.line("."))
    if (_195_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _195_) then
      local fold_edge = _195_
      vim.fn.cursor(fold_edge, 0)
      local function _198_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _198_())
      return "moved-the-cursor"
    else
      return nil
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_200_ = {vim.fn.line("."), vim.fn.virtcol(".")}
    local line = _local_200_[1]
    local virtcol = _local_200_[2]
    local from_pos = _local_200_
    local _201_
    if (virtcol < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _201_ = {dec(line), right_bound}
        else
          _201_ = nil
        end
      else
        _201_ = {line, left_bound}
      end
    elseif (virtcol > right_bound) then
      if reverse_3f then
        _201_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _201_ = {inc(line), left_bound}
        else
          _201_ = nil
        end
      end
    else
      _201_ = nil
    end
    if (nil ~= _201_) then
      local to_pos = _201_
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
    local function _210_()
      if reverse_3f then
        return {winbot, right_bound}
      else
        return {wintop, left_bound}
      end
    end
    vim.fn.cursor(_210_())
    if reverse_3f then
      reach_right_bound()
    else
    end
  else
  end
  local function recur(match_at_curpos_3f)
    local match_at_curpos_3f0
    local function _213_()
      if win_enter_3f then
        win_enter_3f = false
        return true
      else
        return nil
      end
    end
    match_at_curpos_3f0 = (match_at_curpos_3f or _213_())
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _215_
      local function _216_()
        if match_at_curpos_3f0 then
          return "c"
        else
          return ""
        end
      end
      _215_ = vim.fn.searchpos(pattern, (opts0 .. _216_()), stopline)
      if ((_G.type(_215_) == "table") and ((_215_)[1] == 0) and true) then
        local _ = (_215_)[2]
        return cleanup()
      elseif ((_G.type(_215_) == "table") and (nil ~= (_215_)[1]) and (nil ~= (_215_)[2])) then
        local line = (_215_)[1]
        local col = (_215_)[2]
        local pos = _215_
        local _217_ = skip_to_fold_edge_21()
        if (_217_ == "moved-the-cursor") then
          return recur(false)
        elseif (_217_ == "not-in-fold") then
          if (vim.wo.wrap or (function(_218_,_219_,_220_) return (_218_ <= _219_) and (_219_ <= _220_) end)(left_bound,col,right_bound) or to_eol_3f) then
            match_count = (match_count + 1)
            return {line, col, left_bound, right_bound}
          else
            local _221_ = skip_to_next_in_window_pos_21()
            if (_221_ == "moved-the-cursor") then
              return recur(true)
            elseif true then
              local _ = _221_
              return cleanup()
            else
              return nil
            end
          end
        else
          return nil
        end
      else
        return nil
      end
    end
  end
  return recur
end
local function user_forced_autojump_3f()
  return (not opts.labels or empty_3f(opts.labels))
end
local function user_forced_no_autojump_3f()
  return (not opts.safe_labels or empty_3f(opts.safe_labels))
end
local function get_targetable_windows(reverse_3f, omni_3f)
  local curr_win_id = vim.fn.win_getid()
  local _let_227_ = vim.split(vim.fn.string(vim.fn.winlayout()), tostring(curr_win_id))
  local left = _let_227_[1]
  local right = _let_227_[2]
  local ids
  local _228_
  if omni_3f then
    _228_ = (left .. right)
  elseif reverse_3f then
    _228_ = left
  else
    _228_ = right
  end
  ids = string.gmatch(_228_, "%d+")
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
  local function _233_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  return map(_233_, ids1)
end
local function get_onscreen_lines(_234_)
  local _arg_235_ = _234_
  local get_full_window_3f = _arg_235_["get-full-window?"]
  local reverse_3f = _arg_235_["reverse?"]
  local skip_folds_3f = _arg_235_["skip-folds?"]
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
    local _238_
    if reverse_3f then
      _238_ = (lnum >= wintop)
    else
      _238_ = (lnum <= winbot)
    end
    if not _238_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _240_
      if reverse_3f then
        _240_ = dec
      else
        _240_ = inc
      end
      lnum = _240_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _242_
      if reverse_3f then
        _242_ = dec
      else
        _242_ = inc
      end
      lnum = _242_(lnum)
    end
  end
  return lines
end
local function get_unique_chars(reverse_3f, _3ftarget_windows, omni_3f)
  local unique_chars = {}
  local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local _let_245_ = get_cursor_pos()
  local curline = _let_245_[1]
  local curcol = _let_245_[2]
  for _, w in ipairs((_3ftarget_windows or {curr_w})) do
    if _3ftarget_windows then
      api.nvim_set_current_win(w.winid)
    else
    end
    local _let_247_ = get_horizontal_bounds({["match-width"] = 2})
    local left_bound = _let_247_[1]
    local right_bound = _let_247_[2]
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
          local orig_ch = line:sub(col, col)
          local ch
          if opts.ignore_case then
            ch = orig_ch:lower()
          else
            ch = orig_ch
          end
          local _252_
          do
            local _251_ = unique_chars[ch]
            if (_251_ == nil) then
              _252_ = {lnum, col, w, orig_ch}
            elseif true then
              local _0 = _251_
              _252_ = false
            else
              _252_ = nil
            end
          end
          unique_chars[ch] = _252_
        else
        end
      end
    end
  end
  if _3ftarget_windows then
    api.nvim_set_current_win(curr_w.winid)
  else
  end
  local tbl_15_auto = {}
  local i_16_auto = #tbl_15_auto
  for k, v in pairs(unique_chars) do
    local val_17_auto
    do
      local _258_ = v
      if ((_G.type(_258_) == "table") and (nil ~= (_258_)[1]) and (nil ~= (_258_)[2]) and (nil ~= (_258_)[3]) and (nil ~= (_258_)[4])) then
        local lnum = (_258_)[1]
        local col = (_258_)[2]
        local w = (_258_)[3]
        local orig_ch = (_258_)[4]
        val_17_auto = {pos = {lnum, col}, wininfo = w, beacon = {0, {{orig_ch, hl.group["unique-ch"]}}}}
      else
        val_17_auto = nil
      end
    end
    if (nil ~= val_17_auto) then
      i_16_auto = (i_16_auto + 1)
      do end (tbl_15_auto)[i_16_auto] = val_17_auto
    else
    end
  end
  return tbl_15_auto
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
    local function _261_()
      if opts.ignore_case then
        return "\\c"
      else
        return "\\C"
      end
    end
    pattern = ("\\V" .. _261_() .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _263_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f, ["cross-window?"] = _3fwininfo}) do
    local _each_264_ = _263_
    local line = _each_264_[1]
    local col = _each_264_[2]
    local pos = _each_264_
    local target = {pos = pos, wininfo = _3fwininfo}
    if to_eol_3f then
      target["pair"] = {"\n", ""}
      table.insert(targets, target)
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _265_
      if reverse_3f then
        _265_ = dec
      else
        _265_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _265_(prev_match.col)))
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
          local _267_ = prev_target
          if ((_G.type(_267_) == "table") and ((_G.type((_267_).pos) == "table") and (nil ~= ((_267_).pos)[1]) and (nil ~= ((_267_).pos)[2]))) then
            local prev_line = ((_267_).pos)[1]
            local prev_col = ((_267_).pos)[2]
            local function _269_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta < min_delta_to_prevent_squeezing)
            end
            close_to_prev_target_3f = ((line == prev_line) and _269_())
          else
            close_to_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        else
        end
        if close_to_prev_target_3f then
          local _272_
          if reverse_3f then
            _272_ = target
          else
            _272_ = prev_target
          end
          _272_["squeezed?"] = true
        else
        end
        if overlaps_prev_target_3f then
          local _275_
          if reverse_3f then
            _275_ = prev_target
          else
            _275_ = target
          end
          _275_["overlapped?"] = true
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
local function distance(_281_, _283_, vertical_only_3f)
  local _arg_282_ = _281_
  local line1 = _arg_282_[1]
  local col1 = _arg_282_[2]
  local _arg_284_ = _283_
  local line2 = _arg_284_[1]
  local col2 = _arg_284_[2]
  local editor_grid_aspect_ratio = 0.3
  local _let_285_ = {abs((col1 - col2)), abs((line1 - line2))}
  local dx = _let_285_[1]
  local dy = _let_285_[2]
  local dx0
  local function _286_()
    if vertical_only_3f then
      return 0
    else
      return 1
    end
  end
  dx0 = (dx * editor_grid_aspect_ratio * _286_())
  return pow((pow(dx0, 2) + pow(dy, 2)), 0.5)
end
local function get_targets(input, reverse_3f, _3ftarget_windows, omni_3f)
  local to_eol_3f = (input == "\13")
  local function calculate_screen_positions_3f(targets)
    return (vim.wo.wrap and (#targets < 200))
  end
  if _3ftarget_windows then
    local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
    local cursor_positions = {}
    local targets = {}
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_set_current_win(w.winid)
      do end (cursor_positions)[w.winid] = get_cursor_pos()
      get_targets_2a(input, reverse_3f, w, targets)
    end
    api.nvim_set_current_win(curr_w.winid)
    if next(targets) then
      if omni_3f then
        local calculate_screen_positions_3f0 = calculate_screen_positions_3f(targets)
        if calculate_screen_positions_3f0 then
          for winid, _287_ in pairs(cursor_positions) do
            local _each_288_ = _287_
            local line = _each_288_[1]
            local col = _each_288_[2]
            local screenpos = vim.fn.screenpos(winid, line, col)
            do end (cursor_positions)[winid] = {screenpos.row, screenpos.col}
          end
        else
        end
        for _, _290_ in ipairs(targets) do
          local _each_291_ = _290_
          local _each_292_ = _each_291_["pos"]
          local line = _each_292_[1]
          local col = _each_292_[2]
          local _each_293_ = _each_291_["wininfo"]
          local winid = _each_293_["winid"]
          local t = _each_291_
          if calculate_screen_positions_3f0 then
            local screenpos = vim.fn.screenpos(winid, line, col)
            do end (t)["screenpos"] = {screenpos.row, screenpos.col}
          else
          end
          local cursor_pos = cursor_positions[winid]
          local pos = (t.screenpos or t.pos)
          do end (t)["rank"] = distance(pos, cursor_pos, to_eol_3f)
        end
        local function _295_(_241, _242)
          return ((_241).rank < (_242).rank)
        end
        table.sort(targets, _295_)
      else
      end
      return targets
    else
      return nil
    end
  elseif omni_3f then
    local _298_ = get_targets_2a(input, true, nil, get_targets_2a(input, false))
    if (nil ~= _298_) then
      local targets = _298_
      local winid = vim.fn.win_getid()
      local calculate_screen_positions_3f0 = calculate_screen_positions_3f(targets)
      local _let_299_ = get_cursor_pos()
      local curline = _let_299_[1]
      local curcol = _let_299_[2]
      local curpos = _let_299_
      local curscreenpos = vim.fn.screenpos(winid, curline, curcol)
      local cursor_pos
      if calculate_screen_positions_3f0 then
        cursor_pos = {curscreenpos.row, curscreenpos.col}
      else
        cursor_pos = curpos
      end
      for _, _301_ in ipairs(targets) do
        local _each_302_ = _301_
        local _each_303_ = _each_302_["pos"]
        local line = _each_303_[1]
        local col = _each_303_[2]
        local t = _each_302_
        if calculate_screen_positions_3f0 then
          local screenpos = vim.fn.screenpos(winid, line, col)
          do end (t)["screenpos"] = {screenpos.row, screenpos.col}
        else
        end
        local pos = (t.screenpos or t.pos)
        do end (t)["rank"] = distance(pos, cursor_pos, to_eol_3f)
      end
      local function _305_(_241, _242)
        return ((_241).rank < (_242).rank)
      end
      table.sort(targets, _305_)
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
    local function _308_(self, k)
      return rawget(self, k:lower())
    end
    local function _309_(self, k, v)
      return rawset(self, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _308_, __newindex = _309_})
  else
  end
  for _, _311_ in ipairs(targets) do
    local _each_312_ = _311_
    local _each_313_ = _each_312_["pair"]
    local _0 = _each_313_[1]
    local ch2 = _each_313_[2]
    local target = _each_312_
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    else
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function set_autojump(sublist, to_eol_3f)
  sublist["autojump?"] = (not (user_forced_no_autojump_3f() or to_eol_3f or operator_pending_mode_3f()) and (user_forced_autojump_3f() or (#opts.safe_labels >= dec(#sublist))))
  return nil
end
local function attach_label_set(sublist)
  local _315_
  if user_forced_autojump_3f() then
    _315_ = opts.safe_labels
  elseif user_forced_no_autojump_3f() then
    _315_ = opts.labels
  elseif sublist["autojump?"] then
    _315_ = opts.safe_labels
  else
    _315_ = opts.labels
  end
  sublist["label-set"] = _315_
  return nil
end
local function set_sublist_attributes(targets, to_eol_3f)
  for _, sublist in pairs(targets.sublists) do
    set_autojump(sublist, to_eol_3f)
    attach_label_set(sublist)
  end
  return nil
end
local function set_labels(targets, to_eol_3f)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      local autojump_3f = sublist["autojump?"]
      local labels = sublist["label-set"]
      for i, target in ipairs(sublist) do
        local _317_
        if not (autojump_3f and (i == 1)) then
          local _318_
          local function _320_()
            if autojump_3f then
              return dec(i)
            else
              return i
            end
          end
          _318_ = (_320_() % #labels)
          if (_318_ == 0) then
            _317_ = last(labels)
          elseif (nil ~= _318_) then
            local n = _318_
            _317_ = labels[n]
          else
            _317_ = nil
          end
        else
          _317_ = nil
        end
        target["label"] = _317_
      end
    else
    end
  end
  return nil
end
local function set_label_states(sublist, _326_)
  local _arg_327_ = _326_
  local group_offset = _arg_327_["group-offset"]
  local labels = sublist["label-set"]
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local function _328_()
    if sublist["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _328_())
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    if target.label then
      local _329_
      if ((i < primary_start) or (i > secondary_end)) then
        _329_ = "inactive"
      elseif (i <= primary_end) then
        _329_ = "active-primary"
      else
        _329_ = "active-secondary"
      end
      target["label-state"] = _329_
    else
    end
  end
  return nil
end
local function set_initial_label_states(targets)
  for _, sublist in pairs(targets.sublists) do
    set_label_states(sublist, {["group-offset"] = 0})
  end
  return nil
end
local function set_shortcuts_and_populate_shortcuts_map(targets)
  targets["shortcuts"] = {}
  local potential_2nd_inputs
  do
    local tbl_12_auto = {}
    for ch2, _ in pairs(targets.sublists) do
      local _332_, _333_ = ch2, true
      if ((nil ~= _332_) and (nil ~= _333_)) then
        local k_13_auto = _332_
        local v_14_auto = _333_
        tbl_12_auto[k_13_auto] = v_14_auto
      else
      end
    end
    potential_2nd_inputs = tbl_12_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _335_ in ipairs(targets) do
    local _each_336_ = _335_
    local label = _each_336_["label"]
    local label_state = _each_336_["label-state"]
    local target = _each_336_
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
local function set_beacon(_339_, _repeat)
  local _arg_340_ = _339_
  local _arg_341_ = _arg_340_["pos"]
  local _ = _arg_341_[1]
  local col = _arg_341_[2]
  local left_bound = _arg_341_[3]
  local right_bound = _arg_341_[4]
  local _arg_342_ = _arg_340_["pair"]
  local ch1 = _arg_342_[1]
  local ch2 = _arg_342_[2]
  local label = _arg_340_["label"]
  local label_state = _arg_340_["label-state"]
  local squeezed_3f = _arg_340_["squeezed?"]
  local overlapped_3f = _arg_340_["overlapped?"]
  local shortcut_3f = _arg_340_["shortcut?"]
  local target = _arg_340_
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local ch10
  if to_eol_3f then
    ch10 = "\13"
  else
    ch10 = ch1
  end
  local function _345_(_241)
    local function _346_()
      local t_347_ = opts.substitute_chars
      if (nil ~= t_347_) then
        t_347_ = (t_347_)[_241]
      else
      end
      return t_347_
    end
    return (_346_() or _241)
  end
  local _let_344_ = map(_345_, {ch10, ch2})
  local ch11 = _let_344_[1]
  local ch20 = _let_344_[2]
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
    local _349_ = label_state
    if (_349_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hg["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch11 .. ch20), hg["unlabeled-match"]}}}
        end
      else
        target.beacon = nil
      end
    elseif (_349_ == "active-primary") then
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
        local _353_
        if squeezed_3f0 then
          _353_ = 1
        else
          _353_ = 2
        end
        target.beacon = {_353_, {shortcut_24}}
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
    elseif (_349_ == "active-secondary") then
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
        local _359_
        if squeezed_3f0 then
          _359_ = 1
        else
          _359_ = 2
        end
        target.beacon = {_359_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_349_ == "inactive") then
      target.beacon = nil
    else
      target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _364_)
  local _arg_365_ = _364_
  local _repeat = _arg_365_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_366_ = target_list[i]
    local _let_367_ = _let_366_["pos"]
    local line = _let_367_[1]
    local col = _let_367_[2]
    local target = _let_366_
    local _368_ = target.beacon
    if ((_G.type(_368_) == "table") and (nil ~= (_368_)[1]) and (nil ~= (_368_)[2]) and true) then
      local offset = (_368_)[1]
      local chunks = (_368_)[2]
      local _3fleft_off_3f = (_368_)[3]
      local function _369_()
        local t_370_ = target.wininfo
        if (nil ~= t_370_) then
          t_370_ = (t_370_).bufnr
        else
        end
        return t_370_
      end
      local _372_
      if _3fleft_off_3f then
        _372_ = 0
      else
        _372_ = nil
      end
      api.nvim_buf_set_extmark((_369_() or 0), hl.ns, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _372_, priority = hl.priority.label})
    else
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _375_ in ipairs(target_list) do
    local _each_376_ = _375_
    local label = _each_376_["label"]
    local label_state = _each_376_["label-state"]
    local target = _each_376_
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    else
    end
  end
  return res
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
    local function _379_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _379_(self.state.cold["reverse?"])
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
  local function _383_()
    if cross_window_3f then
      return get_targetable_windows(reverse_3f0, omni_3f)
    else
      return nil
    end
  end
  local function _385_()
    if instant_repeat_3f then
      return instant_state["target-windows"]
    else
      return nil
    end
  end
  _3ftarget_windows = (_383_() or _385_())
  local spec_keys
  local function _387_(_, k)
    return replace_keycodes(opts.special_keys[k])
  end
  spec_keys = setmetatable({}, {__index = _387_})
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
      local _388_
      local function _389_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _390_()
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
      _388_ = (_389_() or _390_())
      local function _392_()
        return not omni_3f
      end
      if ((_388_ == "\9") and _392_()) then
        sx:go(not reverse_3f0, x_mode_3f0, false, cross_window_3f)
        return nil
      elseif (_388_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _393_()
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
        return (self.state.cold.in1 or _393_())
      elseif (nil ~= _388_) then
        local _in = _388_
        return _in
      else
        return nil
      end
    end
  end
  local function update_state_2a(in1)
    local function _399_(_397_)
      local _arg_398_ = _397_
      local cold = _arg_398_["cold"]
      local dot = _arg_398_["dot"]
      if new_search_3f then
        if cold then
          local _400_ = cold
          _400_["in1"] = in1
          _400_["x-mode?"] = x_mode_3f0
          _400_["reverse?"] = reverse_3f0
          self.state.cold = _400_
        else
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _402_ = dot
              _402_["in1"] = in1
              _402_["x-mode?"] = x_mode_3f0
              self.state.dot = _402_
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
    return _399_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _406_(target, _3fto_pre_eol_3f, _3fsave_winview_3f)
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
      local function _409_()
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
      adjusted_pos = jump_to_21_2a(target.pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), adjust = _409_})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _406_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _415_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_414_ = _415_()
    local startline = _let_414_[1]
    local startcol = _let_414_[2]
    local start = _let_414_
    local function _417_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_416_ = _417_()
    local _ = _let_416_[1]
    local endcol = _let_416_[2]
    local _end = _let_416_
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
    local _422_ = targets.sublists[ch]
    if (nil ~= _422_) then
      local sublist = _422_
      local _let_423_ = sublist
      local _let_424_ = _let_423_[1]
      local _let_425_ = _let_424_["pos"]
      local line = _let_425_[1]
      local col = _let_425_[2]
      local rest = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_423_, 2)
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
    local function recur(group_offset, initial_invoc_3f)
      local _429_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _429_ = "cold"
      elseif instant_repeat_3f then
        if sublist["autojump?"] then
          _429_ = "instant"
        else
          _429_ = "instant-unsafe"
        end
      else
        _429_ = nil
      end
      set_beacons(sublist, {["repeat"] = _429_})
      do
        if not (cold_repeat_3f or instant_repeat_3f) then
          grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
        else
        end
        do
          light_up_beacons(sublist, start_idx)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _433_
      do
        local res_2_auto
        do
          local function _434_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            else
              return nil
            end
          end
          res_2_auto = get_input(_434_())
        end
        hl:cleanup(_3ftarget_windows)
        _433_ = res_2_auto
      end
      if (nil ~= _433_) then
        local input = _433_
        if (sublist["autojump?"] and not user_forced_autojump_3f()) then
          return {input, 0}
        else
          local function _435_()
            return ((input == spec_keys.next_match_group) or (input == spec_keys.prev_match_group))
          end
          if (_435_() and not instant_repeat_3f) then
            local labels = sublist["label-set"]
            local num_of_groups = ceil((#sublist / #labels))
            local max_offset = dec(num_of_groups)
            local group_offset_2a
            local _437_
            do
              local _436_ = input
              if (_436_ == spec_keys.next_match_group) then
                _437_ = inc
              elseif true then
                local _ = _436_
                _437_ = dec
              else
                _437_ = nil
              end
            end
            group_offset_2a = clamp(_437_(group_offset), 0, max_offset)
            set_label_states(sublist, {["group-offset"] = group_offset_2a})
            return recur(group_offset_2a)
          else
            return {input, group_offset}
          end
        end
      else
        return nil
      end
    end
    return recur(0, true)
  end
  local function restore_view_on_winleave(curr_target, next_target)
    local _444_
    do
      local t_443_ = curr_target
      if (nil ~= t_443_) then
        t_443_ = (t_443_).wininfo
      else
      end
      if (nil ~= t_443_) then
        t_443_ = (t_443_).winid
      else
      end
      _444_ = t_443_
    end
    local _448_
    do
      local t_447_ = next_target
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
    if (not instant_repeat_3f and (_444_ ~= _448_)) then
      if curr_target.winview then
        return vim.fn.winrestview(curr_target.winview)
      else
        return nil
      end
    else
      return nil
    end
  end
  if not instant_repeat_3f then
    enter("sx")
  else
  end
  if not repeat_invoc then
    echo("")
    if not (cold_repeat_3f or instant_repeat_3f) then
      grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
    else
    end
    do
      if opts.jump_to_unique_chars then
        light_up_beacons(get_unique_chars(reverse_3f0, _3ftarget_windows, omni_3f))
      else
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  else
  end
  local _457_ = get_first_input()
  if (nil ~= _457_) then
    local in1 = _457_
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
    local _459_
    local function _460_()
      local t_461_ = instant_state
      if (nil ~= t_461_) then
        t_461_ = (t_461_).sublist
      else
      end
      return t_461_
    end
    local function _463_()
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
    _459_ = (_460_() or get_targets(in1, reverse_3f0, _3ftarget_windows, omni_3f) or _463_())
    local function _465_()
      local _0 = (((_459_)[1]).pair)[1]
      local ch2 = (((_459_)[1]).pair)[2]
      local only = (_459_)[1]
      return opts.jump_to_unique_chars
    end
    if (((_G.type(_459_) == "table") and ((_G.type((_459_)[1]) == "table") and ((_G.type(((_459_)[1]).pair) == "table") and true and (nil ~= (((_459_)[1]).pair)[2]))) and ((_459_)[2] == nil)) and _465_()) then
      local _0 = (((_459_)[1]).pair)[1]
      local ch2 = (((_459_)[1]).pair)[2]
      local only = (_459_)[1]
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
              local _467_ = opts.jump_to_unique_chars
              if ((_G.type(_467_) == "table") and (nil ~= (_467_).safety_timeout)) then
                local timeout = (_467_).safety_timeout
                res_2_auto = ignore_input_until_timeout(ch2, timeout)
              else
                res_2_auto = nil
              end
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
    elseif (nil ~= _459_) then
      local targets = _459_
      if not instant_repeat_3f then
        local _472_ = targets
        populate_sublists(_472_)
        set_sublist_attributes(_472_, to_eol_3f)
        set_labels(_472_, to_eol_3f)
        set_initial_label_states(_472_)
      else
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _474_ = targets
          set_shortcuts_and_populate_shortcuts_map(_474_)
          set_beacons(_474_, {["repeat"] = nil})
        end
        if not (cold_repeat_3f or instant_repeat_3f) then
          grey_out_search_area(reverse_3f0, _3ftarget_windows, omni_3f)
        else
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      else
      end
      local _477_
      local function _478_()
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
      _477_ = (prev_in2 or _478_() or _480_() or _481_())
      if (nil ~= _477_) then
        local in2 = _477_
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
          local _0 = ((_483_).pair)[1]
          local ch2 = ((_483_).pair)[2]
          local shortcut = _483_
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
          local function _488_()
            local t_489_ = instant_state
            if (nil ~= t_489_) then
              t_489_ = (t_489_).sublist
            else
            end
            return t_489_
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
          _487_ = (_488_() or get_sublist(targets, in2) or _491_())
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
            local function _494_()
              local t_495_ = instant_state
              if (nil ~= t_495_) then
                t_495_ = (t_495_).idx
              else
              end
              return t_495_
            end
            local function _497_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_494_() or _497_())
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
            local function _503_()
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
            _500_ = (_501_() or get_last_input(sublist, inc(curr_idx)) or _503_())
            if ((_G.type(_500_) == "table") and (nil ~= (_500_)[1]) and (nil ~= (_500_)[2])) then
              local in3 = (_500_)[1]
              local group_offset = (_500_)[2]
              local _505_
              if not (op_mode_3f or (group_offset > 0)) then
                _505_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
                _505_ = nil
              end
              if (nil ~= _505_) then
                local action = _505_
                local idx
                do
                  local _507_ = action
                  if (_507_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_507_ == "revert") then
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
                local _1 = _505_
                local _509_
                if not (instant_repeat_3f and not autojump_3f) then
                  _509_ = get_target_with_active_primary_label(sublist, in3)
                else
                  _509_ = nil
                end
                if (nil ~= _509_) then
                  local target = _509_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    else
                    end
                    local _512_
                    if (group_offset > 0) then
                      _512_ = nil
                    else
                      _512_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _512_}})
                    restore_view_on_winleave(first, target)
                    jump_to_21(target)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                elseif true then
                  local _2 = _509_
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
local temporary_editor_opts = {["vim.wo.conceallevel"] = 0, ["vim.wo.scrolloff"] = 0, ["vim.wo.sidescrolloff"] = 0, ["vim.o.scrolloff"] = 0, ["vim.o.sidescrolloff"] = 0, ["vim.bo.modeline"] = false}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_525_ = vim.split(opt, ".", true)
    local _0 = _let_525_[1]
    local scope = _let_525_[2]
    local name = _let_525_[3]
    local _526_
    if (opt == "vim.wo.scrolloff") then
      _526_ = api.nvim_eval("&l:scrolloff")
    elseif (opt == "vim.wo.sidescrolloff") then
      _526_ = api.nvim_eval("&l:sidescrolloff")
    elseif (opt == "vim.o.scrolloff") then
      _526_ = api.nvim_eval("&scrolloff")
    elseif (opt == "vim.o.sidescrolloff") then
      _526_ = api.nvim_eval("&sidescrolloff")
    else
      _526_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _526_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_528_ = vim.split(opt, ".", true)
    local _ = _let_528_[1]
    local scope = _let_528_[2]
    local name = _let_528_[3]
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
  local plug_keys = {{"<Plug>Lightspeed_s", "sx:go(false)"}, {"<Plug>Lightspeed_S", "sx:go(true)"}, {"<Plug>Lightspeed_x", "sx:go(false, true)"}, {"<Plug>Lightspeed_X", "sx:go(true, true)"}, {"<Plug>Lightspeed_gs", "sx:go(false, nil, nil, true)"}, {"<Plug>Lightspeed_gS", "sx:go(true, nil, nil, true)"}, {"<Plug>Lightspeed_omni_s", "sx:go(nil, false, nil, nil, true)"}, {"<Plug>Lightspeed_omni_gs", "sx:go(nil, false, nil, true, true)"}, {"<Plug>Lightspeed_f", "ft:go(false)"}, {"<Plug>Lightspeed_F", "ft:go(true)"}, {"<Plug>Lightspeed_t", "ft:go(false, true)"}, {"<Plug>Lightspeed_T", "ft:go(true, true)"}, {"<Plug>Lightspeed_;_sx", "sx:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_sx", "sx:go(true, nil, 'cold')"}, {"<Plug>Lightspeed_;_ft", "ft:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_ft", "ft:go(true, nil, 'cold')"}}
  for _, _529_ in ipairs(plug_keys) do
    local _each_530_ = _529_
    local lhs = _each_530_[1]
    local rhs_call = _each_530_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _531_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_532_ = _531_
    local lhs = _each_532_[1]
    local rhs_call = _each_532_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"n", "gs", "<Plug>Lightspeed_gs"}, {"n", "gS", "<Plug>Lightspeed_gS"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _533_ in ipairs(default_keymaps) do
    local _each_534_ = _533_
    local mode = _each_534_[1]
    local lhs = _each_534_[2]
    local rhs = _each_534_[3]
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
