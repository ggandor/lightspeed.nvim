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
  local function _23_(t, k)
    if contains_3f(removed_opts, k) then
      return api.nvim_echo(get_warning_msg({k}), true, {})
    else
      return nil
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
local function _27_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  else
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {group = {label = "LightspeedLabel", ["label-distant"] = "LightspeedLabelDistant", shortcut = "LightspeedShortcut", ["masked-ch"] = "LightspeedMaskedChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", ["one-char-match"] = "LightspeedOneCharMatch", ["unique-ch"] = "LightspeedUniqueChar", ["pending-op-area"] = "LightspeedPendingOpArea", greywash = "LightspeedGreyWash", cursor = "LightspeedCursor"}, priority = {cursor = 65535, label = 65534, greywash = 65533}, ns = api.nvim_create_namespace(""), cleanup = _27_}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _30_
  do
    local _29_ = bg
    if (_29_ == "light") then
      _30_ = "#f02077"
    elseif true then
      local _ = _29_
      _30_ = "#ff2f87"
    else
      _30_ = nil
    end
  end
  local _35_
  do
    local _34_ = bg
    if (_34_ == "light") then
      _35_ = "#399d9f"
    elseif true then
      local _ = _34_
      _35_ = "#99ddff"
    else
      _35_ = nil
    end
  end
  local _40_
  do
    local _39_ = bg
    if (_39_ == "light") then
      _40_ = "Blue"
    elseif true then
      local _ = _39_
      _40_ = "Cyan"
    else
      _40_ = nil
    end
  end
  local _45_
  do
    local _44_ = bg
    if (_44_ == "light") then
      _45_ = "#cc9999"
    elseif true then
      local _ = _44_
      _45_ = "#b38080"
    else
      _45_ = nil
    end
  end
  local _50_
  do
    local _49_ = bg
    if (_49_ == "light") then
      _50_ = "#272020"
    elseif true then
      local _ = _49_
      _50_ = "#f3ecec"
    else
      _50_ = nil
    end
  end
  local _55_
  do
    local _54_ = bg
    if (_54_ == "light") then
      _55_ = "Black"
    elseif true then
      local _ = _54_
      _55_ = "White"
    else
      _55_ = nil
    end
  end
  groupdefs = {[hl.group.label] = {guifg = _30_, ctermfg = "Red", guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}, [hl.group["label-distant"]] = {guifg = _35_, ctermfg = _40_, guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}, [hl.group.shortcut] = {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold", cterm = "bold"}, [hl.group["masked-ch"]] = {guifg = _45_, ctermfg = "DarkGrey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}, [hl.group["unlabeled-match"]] = {guifg = _50_, ctermfg = _55_, guibg = "NONE", ctermbg = "NONE", gui = "bold", cterm = "bold"}, [hl.group.greywash] = {guifg = "#777777", ctermfg = "Grey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}}
  for name, hl_def_map in pairs(groupdefs) do
    local attrs_str
    local _59_
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
      _59_ = tbl_15_auto
    end
    attrs_str = table.concat(_59_, " ")
    local function _61_()
      if force_3f then
        return ""
      else
        return "default "
      end
    end
    vim.cmd(("highlight " .. _61_() .. name .. " " .. attrs_str))
  end
  for from_group, to_group in pairs({[hl.group["unique-ch"]] = hl.group["unlabeled-match"], [hl.group["one-char-match"]] = hl.group.shortcut, [hl.group["pending-op-area"]] = "IncSearch", [hl.group.cursor] = "Cursor"}) do
    local function _62_()
      if force_3f then
        return "! "
      else
        return " default "
      end
    end
    vim.cmd(("highlight" .. _62_() .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f, _3ftarget_windows, omni_3f)
  if (_3ftarget_windows or omni_3f) then
    for _, win in ipairs((_3ftarget_windows or {vim.fn.getwininfo(vim.fn.win_getid())[1]})) do
      vim.highlight.range(win.bufnr, hl.ns, hl.group.greywash, {dec(win.topline), 0}, {dec(win.botline), -1}, {priority = hl.priority.greywash})
    end
    return nil
  else
    local _let_63_ = map(dec, get_cursor_pos())
    local curline = _let_63_[1]
    local curcol = _let_63_[2]
    local _let_64_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
    local win_top = _let_64_[1]
    local win_bot = _let_64_[2]
    local function _66_()
      if reverse_3f then
        return {{win_top, 0}, {curline, curcol}}
      else
        return {{curline, inc(curcol)}, {win_bot, -1}}
      end
    end
    local _let_65_ = _66_()
    local start = _let_65_[1]
    local finish = _let_65_[2]
    return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish, {priority = hl.priority.greywash})
  end
end
local function highlight_range(hl_group, _68_, _70_, _72_)
  local _arg_69_ = _68_
  local startline = _arg_69_[1]
  local startcol = _arg_69_[2]
  local start = _arg_69_
  local _arg_71_ = _70_
  local endline = _arg_71_[1]
  local endcol = _arg_71_[2]
  local _end = _arg_71_
  local _arg_73_ = _72_
  local motion_force = _arg_73_["motion-force"]
  local inclusive_motion_3f = _arg_73_["inclusive-motion?"]
  local hl_range
  local function _74_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, {inclusive = end_inclusive_3f, priority = hl.priority.label})
  end
  hl_range = _74_
  local _75_ = motion_force
  if (_75_ == _3cctrl_v_3e) then
    local _let_76_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_76_[1]
    local endcol0 = _let_76_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_75_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_75_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  elseif (_75_ == nil) then
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
  local function _79_()
    local _78_ = direction
    if (_78_ == "fwd") then
      return "W"
    elseif (_78_ == "bwd") then
      return "bW"
    else
      return nil
    end
  end
  return vim.fn.search("\\_.", _79_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function push_beyond_eof_21()
  local saved = vim.o.virtualedit
  vim.o.virtualedit = "onemore"
  vim.cmd("norm! l")
  local function _81_()
    vim.o.virtualedit = saved
    return nil
  end
  return api.nvim_create_autocmd({"CursorMoved", "WinLeave", "BufLeave", "InsertEnter", "CmdlineEnter", "CmdwinEnter"}, {callback = _81_, once = true})
end
local function simulate_inclusive_op_21(mode)
  local _82_ = vim.fn.matchstr(mode, "^no\\zs.")
  if (_82_ == "") then
    if cursor_before_eof_3f() then
      return push_beyond_eof_21()
    else
      return push_cursor_21("fwd")
    end
  elseif (_82_ == "v") then
    return push_cursor_21("bwd")
  else
    return nil
  end
end
local function force_matchparen_refresh()
  pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchparen"})
  return pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchup_matchparen"})
end
local function jump_to_21_2a(target, _85_)
  local _arg_86_ = _85_
  local mode = _arg_86_["mode"]
  local reverse_3f = _arg_86_["reverse?"]
  local inclusive_motion_3f = _arg_86_["inclusive-motion?"]
  local add_to_jumplist_3f = _arg_86_["add-to-jumplist?"]
  local adjust = _arg_86_["adjust"]
  local op_mode_3f = string.match(mode, "o")
  if add_to_jumplist_3f then
    vim.cmd("norm! m`")
  else
  end
  vim.fn.cursor(target)
  adjust()
  local adjusted_pos = get_cursor_pos()
  if (op_mode_3f and inclusive_motion_3f and not reverse_3f) then
    simulate_inclusive_op_21(mode)
  else
  end
  if not op_mode_3f then
    force_matchparen_refresh()
  else
  end
  return adjusted_pos
end
local function highlight_cursor(_3fpos)
  local _let_90_ = (_3fpos or get_cursor_pos())
  local line = _let_90_[1]
  local col = _let_90_[2]
  local pos = _let_90_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {virt_text = {{ch_at_curpos, hl.group.cursor}}, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.cursor})
end
local function handle_interrupted_change_op_21()
  local seq
  local function _91_()
    if (vim.fn.col(".") > 1) then
      return "<RIGHT>"
    else
      return ""
    end
  end
  seq = ("<C-\\><C-G>" .. _91_())
  return api.nvim_feedkeys(replace_keycodes(seq), "n", true)
end
local function exec_user_autocmds(pattern)
  return api.nvim_exec_autocmds("User", {pattern = pattern, modeline = false})
end
local function enter(mode)
  exec_user_autocmds("LightspeedEnter")
  local _92_ = mode
  if (_92_ == "ft") then
    return exec_user_autocmds("LightspeedFtEnter")
  elseif (_92_ == "sx") then
    return exec_user_autocmds("LightspeedSxEnter")
  else
    return nil
  end
end
local function get_input(_3ftimeout)
  local char_available_3f
  local function _94_()
    return ("" ~= vim.fn.getcharstr(true))
  end
  char_available_3f = _94_
  local getchar_timeout
  local function _95_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getcharstr(false)
    else
      return nil
    end
  end
  getchar_timeout = _95_
  local ok_3f, ch = nil, nil
  local function _97_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getcharstr
    end
  end
  ok_3f, ch = pcall(_97_())
  if (ok_3f and (ch ~= replace_keycodes("<esc>"))) then
    return ch
  else
    return nil
  end
end
local function ignore_input_until_timeout(input_to_ignore, timeout)
  local _99_ = get_input(timeout)
  if (nil ~= _99_) then
    local input = _99_
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
  local function _104_()
    local _103_ = repeat_invoc
    if (_103_ == "dot") then
      return "dotrepeat_"
    elseif true then
      local _ = _103_
      return ""
    else
      return nil
    end
  end
  local function _107_()
    local _106_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((_G.type(_106_) == "table") and ((_106_)[1] == "ft") and ((_106_)[2] == false) and ((_106_)[3] == false)) then
      return "f"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "ft") and ((_106_)[2] == true) and ((_106_)[3] == false)) then
      return "F"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "ft") and ((_106_)[2] == false) and ((_106_)[3] == true)) then
      return "t"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "ft") and ((_106_)[2] == true) and ((_106_)[3] == true)) then
      return "T"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "sx") and ((_106_)[2] == false) and ((_106_)[3] == false)) then
      return "s"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "sx") and ((_106_)[2] == true) and ((_106_)[3] == false)) then
      return "S"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "sx") and ((_106_)[2] == false) and ((_106_)[3] == true)) then
      return "x"
    elseif ((_G.type(_106_) == "table") and ((_106_)[1] == "sx") and ((_106_)[2] == true) and ((_106_)[3] == true)) then
      return "X"
    else
      return nil
    end
  end
  return ("<Plug>Lightspeed_" .. _104_() .. _107_())
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
  local function _110_()
    local _111_
    if from_reverse_cold_repeat_3f then
      _111_ = revert_plug_key
    else
      _111_ = repeat_plug_key
    end
    return ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _111_))
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or _110_()) then
    return "repeat"
  else
    local function _113_()
      local _114_
      if from_reverse_cold_repeat_3f then
        _114_ = repeat_plug_key
      else
        _114_ = revert_plug_key
      end
      return ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _114_))
    end
    if (instant_repeat_3f and ((_in == "\9") or _113_())) then
      return "revert"
    else
      return nil
    end
  end
end
local ft = {state = {dot = {["in"] = nil}, cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}}}
ft.go = function(self, _117_)
  local _arg_118_ = _117_
  local reverse_3f = _arg_118_["reverse?"]
  local t_mode_3f = _arg_118_["t-mode?"]
  local repeat_invoc = _arg_118_["repeat-invoc"]
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
    local t_120_ = instant_state
    if (nil ~= t_120_) then
      t_120_ = (t_120_)["reverted?"]
    else
    end
    reverted_instant_repeat_3f = t_120_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _122_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _122_(self.state.cold["reverse?"])
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
    local function _128_()
      vim.fn.winrestview(view)
      return nil
    end
    cleanup = _128_
    local match_count = 0
    local function _129_()
      if (limit and (match_count >= limit)) then
        return cleanup()
      else
        local _130_
        local function _131_()
          if reverse_3f1 then
            return "bW"
          else
            return "W"
          end
        end
        _130_ = vim.fn.searchpos(pattern, _131_())
        if ((_G.type(_130_) == "table") and ((_130_)[1] == 0) and true) then
          local _ = (_130_)[2]
          return cleanup()
        elseif ((_G.type(_130_) == "table") and (nil ~= (_130_)[1]) and (nil ~= (_130_)[2])) then
          local line = (_130_)[1]
          local col = (_130_)[2]
          local pos = _130_
          match_count = (match_count + 1)
          return pos
        else
          return nil
        end
      end
    end
    return _129_
  end
  local function get_num_of_matches_to_be_highlighted()
    local _134_ = opts.limit_ft_matches
    local function _135_()
      local group_limit = _134_
      return (group_limit > 0)
    end
    if ((nil ~= _134_) and _135_()) then
      local group_limit = _134_
      local matches_left_behind
      local function _136_()
        local _137_ = instant_state
        if (nil ~= _137_) then
          local _138_ = (_137_).stack
          if (nil ~= _138_) then
            return #_138_
          else
            return _138_
          end
        else
          return _137_
        end
      end
      matches_left_behind = (_136_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    elseif true then
      local _ = _134_
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
  local _145_
  if instant_repeat_3f then
    _145_ = instant_state["in"]
  elseif dot_repeat_3f then
    _145_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _145_ = self.state.cold["in"]
  else
    local _146_
    local function _147_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      api.nvim_buf_clear_namespace(0, hl.ns, 0, -1)
      return res_2_auto
    end
    local function _148_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      exec_user_autocmds("LightspeedFtLeave")
      exec_user_autocmds("LightspeedLeave")
      return nil
    end
    _146_ = (_147_() or _148_())
    if (_146_ == _3cbackspace_3e) then
      local function _150_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_no_prev_search()
        end
        exec_user_autocmds("LightspeedFtLeave")
        exec_user_autocmds("LightspeedLeave")
        return nil
      end
      _145_ = (self.state.cold["in"] or _150_())
    elseif (nil ~= _146_) then
      local _in = _146_
      _145_ = _in
    else
      _145_ = nil
    end
  end
  if (nil ~= _145_) then
    local in1 = _145_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    else
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _155_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _155_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local function _156_()
          if opts.ignore_case then
            return "\\c"
          else
            return "\\C"
          end
        end
        pattern = ("\\V" .. _156_() .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _158_ in match_positions(pattern, reverse_3f0, limit) do
        local _each_159_ = _158_
        local line = _each_159_[1]
        local col = _each_159_[2]
        local pos = _each_159_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              local ch = (char_at_pos(pos, {}) or "\13")
              local ch0
              local function _160_()
                local t_161_ = opts.substitute_chars
                if (nil ~= t_161_) then
                  t_161_ = (t_161_)[ch]
                else
                end
                return t_161_
              end
              ch0 = (_160_() or ch)
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
      exec_user_autocmds("LightspeedFtLeave")
      exec_user_autocmds("LightspeedLeave")
      return nil
    else
      if not reverted_instant_repeat_3f then
        local function _167_()
          if t_mode_3f0 then
            local function _168_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_168_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            else
              return nil
            end
          else
            return nil
          end
        end
        jump_to_21_2a(jump_pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = true, ["add-to-jumplist?"] = not instant_repeat_3f, adjust = _167_})
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
        exec_user_autocmds("LightspeedFtLeave")
        exec_user_autocmds("LightspeedLeave")
        return nil
      else
        highlight_cursor()
        vim.cmd("redraw")
        local _173_
        local function _174_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          api.nvim_buf_clear_namespace(0, hl.ns, 0, -1)
          return res_2_auto
        end
        local function _175_()
          do
          end
          exec_user_autocmds("LightspeedFtLeave")
          exec_user_autocmds("LightspeedLeave")
          return nil
        end
        _173_ = (_174_() or _175_())
        if (nil ~= _173_) then
          local in2 = _173_
          local stack
          local function _176_()
            local t_177_ = instant_state
            if (nil ~= t_177_) then
              t_177_ = (t_177_).stack
            else
            end
            return t_177_
          end
          stack = (_176_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _180_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_180_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go({["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0, ["repeat-invoc"] = {["in"] = in1, stack = stack, ["reverted?"] = false, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f}})
          elseif (_180_ == "revert") then
            do
              local _181_ = table.remove(stack)
              if (nil ~= _181_) then
                vim.fn.cursor(_181_)
              else
              end
            end
            return ft:go({["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0, ["repeat-invoc"] = {["in"] = in1, stack = stack, ["reverted?"] = true, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f}})
          elseif true then
            local _ = _180_
            do
              vim.fn.feedkeys(in2, "i")
            end
            exec_user_autocmds("LightspeedFtLeave")
            exec_user_autocmds("LightspeedLeave")
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
  local textoff = vim.fn.getwininfo(vim.fn.win_getid())[1].textoff
  local offset_in_win = dec(vim.fn.wincol())
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - offset_in_editable_win)
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _188_)
  local _arg_189_ = _188_
  local cross_window_3f = _arg_189_["cross-window?"]
  local to_eol_3f = _arg_189_["to-eol?"]
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
  local function _192_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _192_
  local _let_193_ = get_horizontal_bounds()
  local left_bound = _let_193_[1]
  local right_bound = _let_193_[2]
  local function reach_right_bound()
    while ((vim.fn.virtcol(".") < right_bound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
      vim.cmd("norm! l")
    end
    return nil
  end
  local function skip_to_fold_edge_21()
    local _194_
    local _195_
    if reverse_3f then
      _195_ = vim.fn.foldclosed
    else
      _195_ = vim.fn.foldclosedend
    end
    _194_ = _195_(vim.fn.line("."))
    if (_194_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _194_) then
      local fold_edge = _194_
      vim.fn.cursor(fold_edge, 0)
      local function _197_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _197_())
      return "moved-the-cursor"
    else
      return nil
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_199_ = {vim.fn.line("."), vim.fn.virtcol(".")}
    local line = _local_199_[1]
    local virtcol = _local_199_[2]
    local from_pos = _local_199_
    local _200_
    if (virtcol < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _200_ = {dec(line), right_bound}
        else
          _200_ = nil
        end
      else
        _200_ = {line, left_bound}
      end
    elseif (virtcol > right_bound) then
      if reverse_3f then
        _200_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _200_ = {inc(line), left_bound}
        else
          _200_ = nil
        end
      end
    else
      _200_ = nil
    end
    if (nil ~= _200_) then
      local to_pos = _200_
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
    local function _209_()
      if reverse_3f then
        return {winbot, right_bound}
      else
        return {wintop, left_bound}
      end
    end
    vim.fn.cursor(_209_())
    if reverse_3f then
      reach_right_bound()
    else
    end
  else
  end
  local function recur(match_at_curpos_3f)
    local match_at_curpos_3f0
    local function _212_()
      if win_enter_3f then
        win_enter_3f = false
        return true
      else
        return nil
      end
    end
    match_at_curpos_3f0 = (match_at_curpos_3f or _212_())
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _214_
      local function _215_()
        if match_at_curpos_3f0 then
          return "c"
        else
          return ""
        end
      end
      _214_ = vim.fn.searchpos(pattern, (opts0 .. _215_()), stopline)
      if ((_G.type(_214_) == "table") and ((_214_)[1] == 0) and true) then
        local _ = (_214_)[2]
        return cleanup()
      elseif ((_G.type(_214_) == "table") and (nil ~= (_214_)[1]) and (nil ~= (_214_)[2])) then
        local line = (_214_)[1]
        local col = (_214_)[2]
        local pos = _214_
        local _216_ = skip_to_fold_edge_21()
        if (_216_ == "moved-the-cursor") then
          return recur(false)
        elseif (_216_ == "not-in-fold") then
          if (vim.wo.wrap or (function(_217_,_218_,_219_) return (_217_ <= _218_) and (_218_ <= _219_) end)(left_bound,col,right_bound) or to_eol_3f) then
            match_count = (match_count + 1)
            return {line, col, left_bound, right_bound}
          else
            local _220_ = skip_to_next_in_window_pos_21()
            if (_220_ == "moved-the-cursor") then
              return recur(true)
            elseif true then
              local _ = _220_
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
  local _let_226_ = vim.split(vim.fn.string(vim.fn.winlayout()), tostring(curr_win_id))
  local left = _let_226_[1]
  local right = _let_226_[2]
  local ids
  local _227_
  if omni_3f then
    _227_ = (left .. right)
  elseif reverse_3f then
    _227_ = left
  else
    _227_ = right
  end
  ids = string.gmatch(_227_, "%d+")
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
  local function _232_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  return map(_232_, ids1)
end
local function get_onscreen_lines(_233_)
  local _arg_234_ = _233_
  local get_full_window_3f = _arg_234_["get-full-window?"]
  local reverse_3f = _arg_234_["reverse?"]
  local skip_folds_3f = _arg_234_["skip-folds?"]
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
    local _237_
    if reverse_3f then
      _237_ = (lnum >= wintop)
    else
      _237_ = (lnum <= winbot)
    end
    if not _237_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _239_
      if reverse_3f then
        _239_ = dec
      else
        _239_ = inc
      end
      lnum = _239_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _241_
      if reverse_3f then
        _241_ = dec
      else
        _241_ = inc
      end
      lnum = _241_(lnum)
    end
  end
  return lines
end
local function get_unique_chars(reverse_3f, _3ftarget_windows, omni_3f)
  local unique_chars = {}
  local curr_w = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local _let_244_ = get_cursor_pos()
  local curline = _let_244_[1]
  local curcol = _let_244_[2]
  for _, w in ipairs((_3ftarget_windows or {curr_w})) do
    if _3ftarget_windows then
      api.nvim_set_current_win(w.winid)
    else
    end
    local _let_246_ = get_horizontal_bounds({["match-width"] = 2})
    local left_bound = _let_246_[1]
    local right_bound = _let_246_[2]
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
          local _251_
          do
            local _250_ = unique_chars[ch]
            if (_250_ == nil) then
              _251_ = {lnum, col, w, orig_ch}
            elseif true then
              local _0 = _250_
              _251_ = false
            else
              _251_ = nil
            end
          end
          unique_chars[ch] = _251_
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
      local _257_ = v
      if ((_G.type(_257_) == "table") and (nil ~= (_257_)[1]) and (nil ~= (_257_)[2]) and (nil ~= (_257_)[3]) and (nil ~= (_257_)[4])) then
        local lnum = (_257_)[1]
        local col = (_257_)[2]
        local w = (_257_)[3]
        local orig_ch = (_257_)[4]
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
    local function _260_()
      if opts.ignore_case then
        return "\\c"
      else
        return "\\C"
      end
    end
    pattern = ("\\V" .. _260_() .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _262_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f, ["cross-window?"] = _3fwininfo}) do
    local _each_263_ = _262_
    local line = _each_263_[1]
    local col = _each_263_[2]
    local pos = _each_263_
    local target = {pos = pos, wininfo = _3fwininfo}
    if to_eol_3f then
      target["pair"] = {"\n", ""}
      table.insert(targets, target)
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _264_
      if reverse_3f then
        _264_ = dec
      else
        _264_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _264_(prev_match.col)))
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
          local _266_ = prev_target
          if ((_G.type(_266_) == "table") and ((_G.type((_266_).pos) == "table") and (nil ~= ((_266_).pos)[1]) and (nil ~= ((_266_).pos)[2]))) then
            local prev_line = ((_266_).pos)[1]
            local prev_col = ((_266_).pos)[2]
            local function _268_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta < min_delta_to_prevent_squeezing)
            end
            close_to_prev_target_3f = ((line == prev_line) and _268_())
          else
            close_to_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        else
        end
        if close_to_prev_target_3f then
          local _271_
          if reverse_3f then
            _271_ = target
          else
            _271_ = prev_target
          end
          _271_["squeezed?"] = true
        else
        end
        if overlaps_prev_target_3f then
          local _274_
          if reverse_3f then
            _274_ = prev_target
          else
            _274_ = target
          end
          _274_["overlapped?"] = true
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
local function distance(_280_, _282_, vertical_only_3f)
  local _arg_281_ = _280_
  local line1 = _arg_281_[1]
  local col1 = _arg_281_[2]
  local _arg_283_ = _282_
  local line2 = _arg_283_[1]
  local col2 = _arg_283_[2]
  local editor_grid_aspect_ratio = 0.3
  local _let_284_ = {abs((col1 - col2)), abs((line1 - line2))}
  local dx = _let_284_[1]
  local dy = _let_284_[2]
  local dx0
  local function _285_()
    if vertical_only_3f then
      return 0
    else
      return 1
    end
  end
  dx0 = (dx * editor_grid_aspect_ratio * _285_())
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
          for winid, _286_ in pairs(cursor_positions) do
            local _each_287_ = _286_
            local line = _each_287_[1]
            local col = _each_287_[2]
            local screenpos = vim.fn.screenpos(winid, line, col)
            do end (cursor_positions)[winid] = {screenpos.row, screenpos.col}
          end
        else
        end
        for _, _289_ in ipairs(targets) do
          local _each_290_ = _289_
          local _each_291_ = _each_290_["pos"]
          local line = _each_291_[1]
          local col = _each_291_[2]
          local _each_292_ = _each_290_["wininfo"]
          local winid = _each_292_["winid"]
          local t = _each_290_
          if calculate_screen_positions_3f0 then
            local screenpos = vim.fn.screenpos(winid, line, col)
            do end (t)["screenpos"] = {screenpos.row, screenpos.col}
          else
          end
          local cursor_pos = cursor_positions[winid]
          local pos = (t.screenpos or t.pos)
          do end (t)["rank"] = distance(pos, cursor_pos, to_eol_3f)
        end
        local function _294_(_241, _242)
          return ((_241).rank < (_242).rank)
        end
        table.sort(targets, _294_)
      else
      end
      return targets
    else
      return nil
    end
  elseif omni_3f then
    local _297_ = get_targets_2a(input, true, nil, get_targets_2a(input, false))
    if (nil ~= _297_) then
      local targets = _297_
      local winid = vim.fn.win_getid()
      local calculate_screen_positions_3f0 = calculate_screen_positions_3f(targets)
      local _let_298_ = get_cursor_pos()
      local curline = _let_298_[1]
      local curcol = _let_298_[2]
      local curpos = _let_298_
      local curscreenpos = vim.fn.screenpos(winid, curline, curcol)
      local cursor_pos
      if calculate_screen_positions_3f0 then
        cursor_pos = {curscreenpos.row, curscreenpos.col}
      else
        cursor_pos = curpos
      end
      for _, _300_ in ipairs(targets) do
        local _each_301_ = _300_
        local _each_302_ = _each_301_["pos"]
        local line = _each_302_[1]
        local col = _each_302_[2]
        local t = _each_301_
        if calculate_screen_positions_3f0 then
          local screenpos = vim.fn.screenpos(winid, line, col)
          do end (t)["screenpos"] = {screenpos.row, screenpos.col}
        else
        end
        local pos = (t.screenpos or t.pos)
        do end (t)["rank"] = distance(pos, cursor_pos, to_eol_3f)
      end
      local function _304_(_241, _242)
        return ((_241).rank < (_242).rank)
      end
      table.sort(targets, _304_)
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
    local function _307_(self, k)
      return rawget(self, k:lower())
    end
    local function _308_(self, k, v)
      return rawset(self, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _307_, __newindex = _308_})
  else
  end
  for _, _310_ in ipairs(targets) do
    local _each_311_ = _310_
    local _each_312_ = _each_311_["pair"]
    local _0 = _each_312_[1]
    local ch2 = _each_312_[2]
    local target = _each_311_
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
  local _314_
  if user_forced_autojump_3f() then
    _314_ = opts.safe_labels
  elseif user_forced_no_autojump_3f() then
    _314_ = opts.labels
  elseif sublist["autojump?"] then
    _314_ = opts.safe_labels
  else
    _314_ = opts.labels
  end
  sublist["label-set"] = _314_
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
        local _316_
        if not (autojump_3f and (i == 1)) then
          local _317_
          local function _319_()
            if autojump_3f then
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
local function set_label_states(sublist, _325_)
  local _arg_326_ = _325_
  local group_offset = _arg_326_["group-offset"]
  local labels = sublist["label-set"]
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
    if target.label then
      local _328_
      if ((i < primary_start) or (i > secondary_end)) then
        _328_ = "inactive"
      elseif (i <= primary_end) then
        _328_ = "active-primary"
      else
        _328_ = "active-secondary"
      end
      target["label-state"] = _328_
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
    local function _345_()
      local t_346_ = opts.substitute_chars
      if (nil ~= t_346_) then
        t_346_ = (t_346_)[_241]
      else
      end
      return t_346_
    end
    return (_345_() or _241)
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
        if squeezed_3f0 then
          target.beacon = {0, {masked_char_24, shortcut_24}}
        else
          local _354_
          if overlapped_3f then
            _354_ = 1
          else
            _354_ = 2
          end
          target.beacon = {_354_, {shortcut_24}}
        end
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, label_24}}
      else
        local _357_
        if overlapped_3f then
          _357_ = 1
        else
          _357_ = 2
        end
        target.beacon = {_357_, {label_24}}
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
        local _361_
        if squeezed_3f0 then
          _361_ = 1
        else
          _361_ = 2
        end
        target.beacon = {_361_, {distant_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        local _363_
        if overlapped_3f then
          _363_ = 1
        else
          _363_ = 2
        end
        target.beacon = {_363_, {distant_label_24}}
      end
    elseif (_348_ == "inactive") then
      target.beacon = nil
    else
      target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _368_)
  local _arg_369_ = _368_
  local _repeat = _arg_369_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_370_ = target_list[i]
    local _let_371_ = _let_370_["pos"]
    local line = _let_371_[1]
    local col = _let_371_[2]
    local target = _let_370_
    local _372_ = target.beacon
    if ((_G.type(_372_) == "table") and (nil ~= (_372_)[1]) and (nil ~= (_372_)[2]) and true) then
      local offset = (_372_)[1]
      local chunks = (_372_)[2]
      local _3fleft_off_3f = (_372_)[3]
      local function _373_()
        local t_374_ = target.wininfo
        if (nil ~= t_374_) then
          t_374_ = (t_374_).bufnr
        else
        end
        return t_374_
      end
      local _376_
      if _3fleft_off_3f then
        _376_ = 0
      else
        _376_ = nil
      end
      api.nvim_buf_set_extmark((_373_() or 0), hl.ns, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _376_, priority = hl.priority.label})
    else
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _379_ in ipairs(target_list) do
    local _each_380_ = _379_
    local label = _each_380_["label"]
    local label_state = _each_380_["label-state"]
    local target = _each_380_
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    else
    end
  end
  return res
end
local sx = {state = {dot = {in1 = nil, in2 = nil, in3 = nil}, cold = {in1 = nil, in2 = nil, ["reverse?"] = nil, ["x-mode?"] = nil}}}
sx.go = function(self, _382_)
  local _arg_383_ = _382_
  local reverse_3f = _arg_383_["reverse?"]
  local x_mode_3f = _arg_383_["x-mode?"]
  local repeat_invoc = _arg_383_["repeat-invoc"]
  local cross_window_3f = _arg_383_["cross-window?"]
  local omni_3f = _arg_383_["omni?"]
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
    local function _385_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _385_(self.state.cold["reverse?"])
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
  local function _389_()
    if cross_window_3f then
      return get_targetable_windows(reverse_3f0, omni_3f)
    else
      return nil
    end
  end
  local function _391_()
    if instant_repeat_3f then
      return instant_state["target-windows"]
    else
      return nil
    end
  end
  _3ftarget_windows = (_389_() or _391_())
  local spec_keys
  local function _393_(_, k)
    return replace_keycodes(opts.special_keys[k])
  end
  spec_keys = setmetatable({}, {__index = _393_})
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
      local _394_
      local function _395_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _396_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        exec_user_autocmds("LightspeedSxLeave")
        exec_user_autocmds("LightspeedLeave")
        return nil
      end
      _394_ = (_395_() or _396_())
      local function _398_()
        return not omni_3f
      end
      if ((_394_ == "\9") and _398_()) then
        sx:go({["reverse?"] = not reverse_3f0, ["x-mode?"] = x_mode_3f0, ["cross-window?"] = cross_window_3f})
        return nil
      elseif (_394_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _399_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          else
          end
          do
            echo_no_prev_search()
          end
          exec_user_autocmds("LightspeedSxLeave")
          exec_user_autocmds("LightspeedLeave")
          return nil
        end
        return (self.state.cold.in1 or _399_())
      elseif (nil ~= _394_) then
        local _in = _394_
        return _in
      else
        return nil
      end
    end
  end
  local function update_state_2a(in1)
    local function _405_(_403_)
      local _arg_404_ = _403_
      local cold = _arg_404_["cold"]
      local dot = _arg_404_["dot"]
      if new_search_3f then
        if cold then
          local _406_ = cold
          _406_["in1"] = in1
          _406_["x-mode?"] = x_mode_3f0
          _406_["reverse?"] = reverse_3f0
          self.state.cold = _406_
        else
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _408_ = dot
              _408_["in1"] = in1
              _408_["x-mode?"] = x_mode_3f0
              self.state.dot = _408_
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
    return _405_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _412_(target, _3fto_pre_eol_3f, _3fsave_winview_3f)
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
      local function _415_()
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
      adjusted_pos = jump_to_21_2a(target.pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), adjust = _415_})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _412_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _421_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_420_ = _421_()
    local startline = _let_420_[1]
    local startcol = _let_420_[2]
    local start = _let_420_
    local function _423_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_422_ = _423_()
    local _ = _let_422_[1]
    local endcol = _let_422_[2]
    local _end = _let_422_
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
    local _428_ = targets.sublists[ch]
    if (nil ~= _428_) then
      local sublist = _428_
      local _let_429_ = sublist
      local _let_430_ = _let_429_[1]
      local _let_431_ = _let_430_["pos"]
      local line = _let_431_[1]
      local col = _let_431_[2]
      local rest = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_429_, 2)
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
      local _435_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _435_ = "cold"
      elseif instant_repeat_3f then
        if sublist["autojump?"] then
          _435_ = "instant"
        else
          _435_ = "instant-unsafe"
        end
      else
        _435_ = nil
      end
      set_beacons(sublist, {["repeat"] = _435_})
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
      local _439_
      do
        local res_2_auto
        do
          local function _440_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            else
              return nil
            end
          end
          res_2_auto = get_input(_440_())
        end
        hl:cleanup(_3ftarget_windows)
        _439_ = res_2_auto
      end
      if (nil ~= _439_) then
        local input = _439_
        if (sublist["autojump?"] and not user_forced_autojump_3f()) then
          return {input, 0}
        else
          local function _441_()
            return ((input == spec_keys.next_match_group) or (input == spec_keys.prev_match_group))
          end
          if (_441_() and not instant_repeat_3f) then
            local labels = sublist["label-set"]
            local num_of_groups = ceil((#sublist / #labels))
            local max_offset = dec(num_of_groups)
            local group_offset_2a
            local _443_
            do
              local _442_ = input
              if (_442_ == spec_keys.next_match_group) then
                _443_ = inc
              elseif true then
                local _ = _442_
                _443_ = dec
              else
                _443_ = nil
              end
            end
            group_offset_2a = clamp(_443_(group_offset), 0, max_offset)
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
    local _450_
    do
      local t_449_ = curr_target
      if (nil ~= t_449_) then
        t_449_ = (t_449_).wininfo
      else
      end
      if (nil ~= t_449_) then
        t_449_ = (t_449_).winid
      else
      end
      _450_ = t_449_
    end
    local _454_
    do
      local t_453_ = next_target
      if (nil ~= t_453_) then
        t_453_ = (t_453_).wininfo
      else
      end
      if (nil ~= t_453_) then
        t_453_ = (t_453_).winid
      else
      end
      _454_ = t_453_
    end
    if (not instant_repeat_3f and (_450_ ~= _454_)) then
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
  local _463_ = get_first_input()
  if (nil ~= _463_) then
    local in1 = _463_
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
    local _465_
    local function _466_()
      local t_467_ = instant_state
      if (nil ~= t_467_) then
        t_467_ = (t_467_).sublist
      else
      end
      return t_467_
    end
    local function _469_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      else
      end
      do
        echo_not_found((in1 .. (prev_in2 or "")))
      end
      exec_user_autocmds("LightspeedSxLeave")
      exec_user_autocmds("LightspeedLeave")
      return nil
    end
    _465_ = (_466_() or get_targets(in1, reverse_3f0, _3ftarget_windows, omni_3f) or _469_())
    local function _471_()
      local _0 = (((_465_)[1]).pair)[1]
      local ch2 = (((_465_)[1]).pair)[2]
      local only = (_465_)[1]
      return opts.jump_to_unique_chars
    end
    if (((_G.type(_465_) == "table") and ((_G.type((_465_)[1]) == "table") and ((_G.type(((_465_)[1]).pair) == "table") and true and (nil ~= (((_465_)[1]).pair)[2]))) and ((_465_)[2] == nil)) and _471_()) then
      local _0 = (((_465_)[1]).pair)[1]
      local ch2 = (((_465_)[1]).pair)[2]
      local only = (_465_)[1]
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
              local _473_ = opts.jump_to_unique_chars
              if ((_G.type(_473_) == "table") and (nil ~= (_473_).safety_timeout)) then
                local timeout = (_473_).safety_timeout
                res_2_auto = ignore_input_until_timeout(ch2, timeout)
              else
                res_2_auto = nil
              end
            end
            hl:cleanup(_3ftarget_windows)
          else
          end
        end
        exec_user_autocmds("LightspeedSxLeave")
        exec_user_autocmds("LightspeedLeave")
        return nil
      else
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_not_found((in1 .. prev_in2))
        end
        exec_user_autocmds("LightspeedSxLeave")
        exec_user_autocmds("LightspeedLeave")
        return nil
      end
    elseif (nil ~= _465_) then
      local targets = _465_
      if not instant_repeat_3f then
        local _478_ = targets
        populate_sublists(_478_)
        set_sublist_attributes(_478_, to_eol_3f)
        set_labels(_478_, to_eol_3f)
        set_initial_label_states(_478_)
      else
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _480_ = targets
          set_shortcuts_and_populate_shortcuts_map(_480_)
          set_beacons(_480_, {["repeat"] = nil})
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
      local _483_
      local function _484_()
        if to_eol_3f then
          return ""
        else
          return nil
        end
      end
      local function _486_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _487_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        exec_user_autocmds("LightspeedSxLeave")
        exec_user_autocmds("LightspeedLeave")
        return nil
      end
      _483_ = (prev_in2 or _484_() or _486_() or _487_())
      if (nil ~= _483_) then
        local in2 = _483_
        local _489_
        do
          local t_490_ = targets.shortcuts
          if (nil ~= t_490_) then
            t_490_ = (t_490_)[in2]
          else
          end
          _489_ = t_490_
        end
        if ((_G.type(_489_) == "table") and ((_G.type((_489_).pair) == "table") and true and (nil ~= ((_489_).pair)[2]))) then
          local _0 = ((_489_).pair)[1]
          local ch2 = ((_489_).pair)[2]
          local shortcut = _489_
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            else
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut, (ch2 == "\13"))
          end
          exec_user_autocmds("LightspeedSxLeave")
          exec_user_autocmds("LightspeedLeave")
          return nil
        elseif true then
          local _0 = _489_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _493_
          local function _494_()
            local t_495_ = instant_state
            if (nil ~= t_495_) then
              t_495_ = (t_495_).sublist
            else
            end
            return t_495_
          end
          local function _497_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            else
            end
            do
              echo_not_found((in1 .. in2))
            end
            exec_user_autocmds("LightspeedSxLeave")
            exec_user_autocmds("LightspeedLeave")
            return nil
          end
          _493_ = (_494_() or get_sublist(targets, in2) or _497_())
          if ((_G.type(_493_) == "table") and (nil ~= (_493_)[1]) and ((_493_)[2] == nil)) then
            local only = (_493_)[1]
            do
              if dot_repeatable_op_3f then
                set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
              else
              end
              update_state({dot = {in2 = in2, in3 = (opts.labels or opts.safe_labels)[1]}})
              jump_to_21(only)
            end
            exec_user_autocmds("LightspeedSxLeave")
            exec_user_autocmds("LightspeedLeave")
            return nil
          elseif ((_G.type(_493_) == "table") and (nil ~= (_493_)[1])) then
            local first = (_493_)[1]
            local sublist = _493_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _500_()
              local t_501_ = instant_state
              if (nil ~= t_501_) then
                t_501_ = (t_501_).idx
              else
              end
              return t_501_
            end
            local function _503_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_500_() or _503_())
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
            local _506_
            local function _507_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              else
                return nil
              end
            end
            local function _509_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              else
              end
              do
              end
              exec_user_autocmds("LightspeedSxLeave")
              exec_user_autocmds("LightspeedLeave")
              return nil
            end
            _506_ = (_507_() or get_last_input(sublist, inc(curr_idx)) or _509_())
            if ((_G.type(_506_) == "table") and (nil ~= (_506_)[1]) and (nil ~= (_506_)[2])) then
              local in3 = (_506_)[1]
              local group_offset = (_506_)[2]
              local _511_
              if not (op_mode_3f or (group_offset > 0)) then
                _511_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
                _511_ = nil
              end
              if (nil ~= _511_) then
                local action = _511_
                local idx
                do
                  local _513_ = action
                  if (_513_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_513_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                    idx = nil
                  end
                end
                local neighbor = sublist[idx]
                restore_view_on_winleave(first, neighbor)
                jump_to_21(neighbor)
                return sx:go({["reverse?"] = reverse_3f0, ["x-mode?"] = x_mode_3f0, ["repeat-invoc"] = {in1 = in1, in2 = in2, sublist = sublist, idx = idx, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["target-windows"] = _3ftarget_windows}})
              elseif true then
                local _1 = _511_
                local _515_
                if not (instant_repeat_3f and not autojump_3f) then
                  _515_ = get_target_with_active_primary_label(sublist, in3)
                else
                  _515_ = nil
                end
                if (nil ~= _515_) then
                  local target = _515_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    else
                    end
                    local _518_
                    if (group_offset > 0) then
                      _518_ = nil
                    else
                      _518_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _518_}})
                    restore_view_on_winleave(first, target)
                    jump_to_21(target)
                  end
                  exec_user_autocmds("LightspeedSxLeave")
                  exec_user_autocmds("LightspeedLeave")
                  return nil
                elseif true then
                  local _2 = _515_
                  if (autojump_3f or instant_repeat_3f) then
                    do
                      if dot_repeatable_op_3f then
                        set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                      else
                      end
                      vim.fn.feedkeys(in3, "i")
                    end
                    exec_user_autocmds("LightspeedSxLeave")
                    exec_user_autocmds("LightspeedLeave")
                    return nil
                  else
                    if change_operation_3f() then
                      handle_interrupted_change_op_21()
                    else
                    end
                    do
                    end
                    exec_user_autocmds("LightspeedSxLeave")
                    exec_user_autocmds("LightspeedLeave")
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
    local _let_531_ = vim.split(opt, ".", true)
    local _0 = _let_531_[1]
    local scope = _let_531_[2]
    local name = _let_531_[3]
    local _532_
    if (opt == "vim.wo.scrolloff") then
      _532_ = api.nvim_eval("&l:scrolloff")
    elseif (opt == "vim.wo.sidescrolloff") then
      _532_ = api.nvim_eval("&l:sidescrolloff")
    elseif (opt == "vim.o.scrolloff") then
      _532_ = api.nvim_eval("&scrolloff")
    elseif (opt == "vim.o.sidescrolloff") then
      _532_ = api.nvim_eval("&sidescrolloff")
    else
      _532_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _532_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_534_ = vim.split(opt, ".", true)
    local _ = _let_534_[1]
    local scope = _let_534_[2]
    local name = _let_534_[3]
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
local function _536_()
  return sx:go({["repeat-invoc"] = "dot"})
end
local function _537_()
  return sx:go({["repeat-invoc"] = "dot", ["reverse?"] = true})
end
local function _538_()
  return sx:go({["repeat-invoc"] = "dot", ["x-mode?"] = true})
end
local function _539_()
  return sx:go({["repeat-invoc"] = "dot", ["reverse?"] = true, ["x-mode?"] = true})
end
local function _540_()
  return ft:go({["repeat-invoc"] = "dot"})
end
local function _541_()
  return ft:go({["repeat-invoc"] = "dot", ["reverse?"] = true})
end
local function _542_()
  return ft:go({["repeat-invoc"] = "dot", ["t-mode?"] = true})
end
local function _543_()
  return ft:go({["repeat-invoc"] = "dot", ["reverse?"] = true, ["t-mode?"] = true})
end
for _, _535_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", _536_}, {"<Plug>Lightspeed_dotrepeat_S", _537_}, {"<Plug>Lightspeed_dotrepeat_x", _538_}, {"<Plug>Lightspeed_dotrepeat_X", _539_}, {"<Plug>Lightspeed_dotrepeat_f", _540_}, {"<Plug>Lightspeed_dotrepeat_F", _541_}, {"<Plug>Lightspeed_dotrepeat_t", _542_}, {"<Plug>Lightspeed_dotrepeat_T", _543_}}) do
  local _each_544_ = _535_
  local lhs = _each_544_[1]
  local rhs = _each_544_[2]
  vim.keymap.set("o", lhs, rhs, {silent = true})
end
init_highlight()
api.nvim_create_augroup("LightspeedDefault", {})
local function _545_()
  return init_highlight()
end
api.nvim_create_autocmd("ColorScheme", {callback = _545_, group = "LightspeedDefault"})
local function _546_()
  save_editor_opts()
  return set_temporary_editor_opts()
end
api.nvim_create_autocmd("User", {pattern = "LightspeedEnter", callback = _546_, group = "LightspeedDefault"})
api.nvim_create_autocmd("User", {pattern = "LightspeedLeave", callback = restore_editor_opts, group = "LightspeedDefault"})
return {opts = opts, setup = setup, ft = ft, sx = sx, save_editor_opts = save_editor_opts, set_temporary_editor_opts = set_temporary_editor_opts, restore_editor_opts = restore_editor_opts, init_highlight = init_highlight, set_default_keymaps = __fnl_global__set_2ddefault_2dkeymaps}
