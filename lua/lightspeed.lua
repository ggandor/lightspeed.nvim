local api = vim.api
local empty_3f = vim.tbl_isempty
local contains_3f = vim.tbl_contains
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
local opts
do
  local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  local labels = {"s", "f", "n", "j", "k", "l", "o", "i", "w", "e", "h", "g", "u", "t", "m", "v", "c", "a", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  opts = {ignore_case = false, exit_after_idle_msecs = {labeled = nil, unlabeled = 1000}, ["disable-default-mappings"] = true, grey_out_search_area = true, highlight_unique_chars = true, match_only_the_start_of_same_char_seqs = true, jump_on_partial_input_safety_timeout = 400, substitute_chars = {["\13"] = "\194\172"}, safe_labels = safe_labels, labels = labels, cycle_group_fwd_key = "<space>", cycle_group_bwd_key = "<tab>", limit_ft_matches = 4, repeat_ft_with_target_char = false}
end
local deprecated_opts = {"jump_to_first_match", "instant_repeat_fwd_key", "instant_repeat_bwd_key", "x_mode_prefix_key", "full_inclusive_prefix_key"}
local function get_deprec_msg(arg_fields)
  local msg = {{"ligthspeed.nvim\n", "Question"}, {"You are trying to set or access deprecated fields in the "}, {"opts", "Visual"}, {" table:\n\n"}}
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
  local msg_for_instant_repeat_keys = {{"There are dedicated "}, {"<Plug>", "Visual"}, {" keys available for native-like "}, {";", "Visual"}, {" and "}, {",", "Visual"}, {" functionality now, "}, {"that can also be used for instant repeat only, if you prefer. See "}, {":h lightspeed-custom-mappings", "Visual"}, {"."}}
  local msg_for_x_prefix = {{"Use "}, {"<Plug>Lightspeed_x", "Visual"}, {" and "}, {"<Plug>Lightspeed_X", "Visual"}, {" instead."}}
  local spec_messages = {jump_to_first_match = {{"The plugin implements \"smart\" auto-jump now, that you can fine-tune via "}, {"opts.labels", "Visual"}, {" and "}, {"opts.safe_labels", "Visual"}, {". See "}, {":h lightspeed-config", "Visual"}, {" for details."}}, instant_repeat_fwd_key = msg_for_instant_repeat_keys, instant_repeat_bwd_key = msg_for_instant_repeat_keys, x_mode_prefix_key = msg_for_x_prefix, full_inclusive_prefix_key = msg_for_x_prefix}
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
    if contains_3f(deprecated_opts, k) then
      return api.nvim_echo(get_deprec_msg({k}), true, {})
    else
      return nil
    end
  end
  guard = _23_
  setmetatable(opts, {__index = guard, __newindex = guard})
end
local function normalize_opts(opts0)
  local deprecated_arg_opts = {}
  for k, v in pairs(opts0) do
    if contains_3f(deprecated_opts, k) then
      table.insert(deprecated_arg_opts, k)
      do end (opts0)[k] = nil
    else
    end
  end
  if not empty_3f(deprecated_arg_opts) then
    api.nvim_echo(get_deprec_msg(deprecated_arg_opts), true, {})
  else
  end
  return opts0
end
local function setup(user_opts)
  if not ("disable-default-mappings")(user_opts) then
    __fnl_global__set_2ddefault_2dkeymaps()
  else
  end
  opts = setmetatable(normalize_opts(user_opts), {__index = opts})
  return nil
end
local hl
local function _28_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _29_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _30_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {group = {label = "LightspeedLabel", ["label-distant"] = "LightspeedLabelDistant", ["label-overlapped"] = "LightspeedLabelOverlapped", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", shortcut = "LightspeedShortcut", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", ["one-char-match"] = "LightspeedOneCharMatch", ["unique-ch"] = "LightspeedUniqueChar", ["pending-op-area"] = "LightspeedPendingOpArea", greywash = "LightspeedGreyWash", cursor = "LightspeedCursor"}, ns = api.nvim_create_namespace(""), ["add-hl"] = _28_, ["set-extmark"] = _29_, cleanup = _30_}
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
      _37_ = "#ff4090"
    elseif true then
      local _ = _36_
      _37_ = "#e01067"
    else
      _37_ = nil
    end
  end
  local _42_
  do
    local _41_ = bg
    if (_41_ == "light") then
      _42_ = "#399d9f"
    elseif true then
      local _ = _41_
      _42_ = "#99ddff"
    else
      _42_ = nil
    end
  end
  local _47_
  do
    local _46_ = bg
    if (_46_ == "light") then
      _47_ = "Blue"
    elseif true then
      local _ = _46_
      _47_ = "Cyan"
    else
      _47_ = nil
    end
  end
  local _52_
  do
    local _51_ = bg
    if (_51_ == "light") then
      _52_ = "#59bdbf"
    elseif true then
      local _ = _51_
      _52_ = "#79bddf"
    else
      _52_ = nil
    end
  end
  local _57_
  do
    local _56_ = bg
    if (_56_ == "light") then
      _57_ = "Cyan"
    elseif true then
      local _ = _56_
      _57_ = "Blue"
    else
      _57_ = nil
    end
  end
  local _62_
  do
    local _61_ = bg
    if (_61_ == "light") then
      _62_ = "#cc9999"
    elseif true then
      local _ = _61_
      _62_ = "#b38080"
    else
      _62_ = nil
    end
  end
  local _67_
  do
    local _66_ = bg
    if (_66_ == "light") then
      _67_ = "#272020"
    elseif true then
      local _ = _66_
      _67_ = "#f3ecec"
    else
      _67_ = nil
    end
  end
  local _72_
  do
    local _71_ = bg
    if (_71_ == "light") then
      _72_ = "Black"
    elseif true then
      local _ = _71_
      _72_ = "White"
    else
      _72_ = nil
    end
  end
  groupdefs = {{hl.group.label, {guifg = _32_, ctermfg = "Red", guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["label-overlapped"], {guifg = _37_, ctermfg = "Magenta", guibg = "NONE", ctermbg = "NONE", gui = "underline", cterm = "underline"}}, {hl.group["label-distant"], {guifg = _42_, ctermfg = _47_, guibg = "NONE", ctermbg = "NONE", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["label-distant-overlapped"], {guifg = _52_, ctermfg = _57_, gui = "underline", cterm = "underline"}}, {hl.group.shortcut, {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["one-char-match"], {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold", cterm = "bold"}}, {hl.group["masked-ch"], {guifg = _62_, ctermfg = "DarkGrey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}}, {hl.group["unlabeled-match"], {guifg = _67_, ctermfg = _72_, guibg = "NONE", ctermbg = "NONE", gui = "bold", cterm = "bold"}}, {hl.group["pending-op-area"], {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White"}}, {hl.group.greywash, {guifg = "#777777", ctermfg = "Grey", guibg = "NONE", ctermbg = "NONE", gui = "NONE", cterm = "NONE"}}}
  for _, _76_ in ipairs(groupdefs) do
    local _each_77_ = _76_
    local group = _each_77_[1]
    local attrs = _each_77_[2]
    local attrs_str
    local _78_
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
      _78_ = tbl_15_auto
    end
    attrs_str = table.concat(_78_, " ")
    local function _80_()
      if force_3f then
        return ""
      else
        return "default "
      end
    end
    vim.cmd(("highlight " .. _80_() .. group .. " " .. attrs_str))
  end
  for _, _81_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_82_ = _81_
    local from_group = _each_82_[1]
    local to_group = _each_82_[2]
    local function _83_()
      if force_3f then
        return ""
      else
        return "default "
      end
    end
    vim.cmd(("highlight " .. _83_() .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_84_ = map(dec, get_cursor_pos())
  local curline = _let_84_[1]
  local curcol = _let_84_[2]
  local _let_85_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_85_[1]
  local win_bot = _let_85_[2]
  local function _87_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_86_ = _87_()
  local start = _let_86_[1]
  local finish = _let_86_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
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
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
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
  local reverse_3f = _arg_110_["reverse?"]
  local skip_folds_3f = _arg_110_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _111_
    if reverse_3f then
      _111_ = (lnum >= wintop)
    else
      _111_ = (lnum <= winbot)
    end
    if not _111_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _113_
      if reverse_3f then
        _113_ = dec
      else
        _113_ = inc
      end
      lnum = _113_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _115_
      if reverse_3f then
        _115_ = dec
      else
        _115_ = inc
      end
      lnum = _115_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_118_)
  local _arg_119_ = _118_
  local match_width = _arg_119_["match-width"]
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _120_)
  local _arg_121_ = _120_
  local to_eol_3f = _arg_121_["to-eol?"]
  local ft_search_3f = _arg_121_["ft-search?"]
  local limit = _arg_121_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _123_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_123_())
  local cleanup
  local function _124_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _124_
  local _126_
  if ft_search_3f then
    _126_ = 1
  else
    _126_ = 2
  end
  local _let_125_ = get_horizontal_bounds({["match-width"] = _126_})
  local left_bound = _let_125_[1]
  local right_bound = _let_125_[2]
  local function skip_to_fold_edge_21()
    local _128_
    local _129_
    if reverse_3f then
      _129_ = vim.fn.foldclosed
    else
      _129_ = vim.fn.foldclosedend
    end
    _128_ = _129_(vim.fn.line("."))
    if (_128_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _128_) then
      local fold_edge = _128_
      vim.fn.cursor(fold_edge, 0)
      local function _131_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _131_())
      return "moved-the-cursor"
    else
      return nil
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_133_ = get_cursor_pos()
    local line = _local_133_[1]
    local col = _local_133_[2]
    local from_pos = _local_133_
    local _134_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _134_ = {dec(line), right_bound}
        else
          _134_ = nil
        end
      else
        _134_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _134_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _134_ = {inc(line), left_bound}
        else
          _134_ = nil
        end
      end
    else
      _134_ = nil
    end
    if (nil ~= _134_) then
      local to_pos = _134_
      if (from_pos ~= to_pos) then
        vim.fn.cursor(to_pos)
        return "moved-the-cursor"
      else
        return nil
      end
    else
      return nil
    end
  end
  vim.o.cpo = cpo:gsub("c", "")
  local match_count = 0
  local function recur(match_at_curpos_3f)
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _142_
      local function _143_()
        if match_at_curpos_3f then
          return "c"
        else
          return ""
        end
      end
      _142_ = vim.fn.searchpos(pattern, (opts0 .. _143_()), stopline)
      if ((_G.type(_142_) == "table") and ((_142_)[1] == 0) and true) then
        local _ = (_142_)[2]
        return cleanup()
      elseif ((_G.type(_142_) == "table") and (nil ~= (_142_)[1]) and (nil ~= (_142_)[2])) then
        local line = (_142_)[1]
        local col = (_142_)[2]
        local pos = _142_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _144_ = skip_to_fold_edge_21()
          if (_144_ == "moved-the-cursor") then
            return recur(false)
          elseif (_144_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_145_,_146_,_147_) return (_145_ <= _146_) and (_146_ <= _147_) end)(left_bound,col,right_bound) or to_eol_3f) then
              match_count = (match_count + 1)
              return pos
            else
              local _148_ = skip_to_next_in_window_pos_21()
              if (_148_ == "moved-the-cursor") then
                return recur(true)
              elseif true then
                local _ = _148_
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
  local _let_155_ = (_3fpos or get_cursor_pos())
  local line = _let_155_[1]
  local col = _let_155_[2]
  local pos = _let_155_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return hl["set-extmark"](hl, dec(line), dec(col), {virt_text = {{ch_at_curpos, hl.group.cursor}}, virt_text_pos = "overlay", hl_mode = "combine"})
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
  local _158_ = mode
  if (_158_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_158_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  else
    return nil
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _160_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _160_
  local getchar_timeout
  local function _161_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    else
      return nil
    end
  end
  getchar_timeout = _161_
  local ok_3f, ch = nil, nil
  local function _163_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_163_())
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
  local function _168_()
    local _167_ = repeat_invoc
    if (_167_ == "dot") then
      return "dotrepeat_"
    elseif true then
      local _ = _167_
      return ""
    else
      return nil
    end
  end
  local function _171_()
    local _170_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((_G.type(_170_) == "table") and ((_170_)[1] == "ft") and ((_170_)[2] == false) and ((_170_)[3] == false)) then
      return "f"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "ft") and ((_170_)[2] == true) and ((_170_)[3] == false)) then
      return "F"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "ft") and ((_170_)[2] == false) and ((_170_)[3] == true)) then
      return "t"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "ft") and ((_170_)[2] == true) and ((_170_)[3] == true)) then
      return "T"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "sx") and ((_170_)[2] == false) and ((_170_)[3] == false)) then
      return "s"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "sx") and ((_170_)[2] == true) and ((_170_)[3] == false)) then
      return "S"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "sx") and ((_170_)[2] == false) and ((_170_)[3] == true)) then
      return "x"
    elseif ((_G.type(_170_) == "table") and ((_170_)[1] == "sx") and ((_170_)[2] == true) and ((_170_)[3] == true)) then
      return "X"
    else
      return nil
    end
  end
  return ("<Plug>Lightspeed_" .. _168_() .. _171_())
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
  local _174_
  if from_reverse_cold_repeat_3f then
    _174_ = revert_plug_key
  else
    _174_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _174_))) then
    return "repeat"
  else
    local _176_
    if from_reverse_cold_repeat_3f then
      _176_ = repeat_plug_key
    else
      _176_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _176_)))) then
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
    local t_180_ = instant_state
    if (nil ~= t_180_) then
      t_180_ = (t_180_)["reverted?"]
    else
    end
    reverted_instant_repeat_3f = t_180_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _182_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _182_(self.state.cold["reverse?"])
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
    local _188_ = opts.limit_ft_matches
    local function _189_()
      local group_limit = _188_
      return (group_limit > 0)
    end
    if ((nil ~= _188_) and _189_()) then
      local group_limit = _188_
      local matches_left_behind
      local function _191_()
        local _190_ = instant_state
        if (nil ~= _190_) then
          local _192_ = (_190_).stack
          if (nil ~= _192_) then
            return #_192_
          else
            return _192_
          end
        else
          return _190_
        end
      end
      matches_left_behind = (_191_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    elseif true then
      local _ = _188_
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
  local _199_
  if instant_repeat_3f then
    _199_ = instant_state["in"]
  elseif dot_repeat_3f then
    _199_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _199_ = self.state.cold["in"]
  else
    local _200_
    local function _201_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _202_()
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
    _200_ = (_201_() or _202_())
    if (_200_ == _3cbackspace_3e) then
      local function _204_()
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
      _199_ = (self.state.cold["in"] or _204_())
    elseif (nil ~= _200_) then
      local _in = _200_
      _199_ = _in
    else
      _199_ = nil
    end
  end
  if (nil ~= _199_) then
    local in1 = _199_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    else
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _209_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _209_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local function _210_()
          if opts.ignore_case then
            return "\\c"
          else
            return "\\C"
          end
        end
        pattern = ("\\V" .. _210_() .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _212_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_213_ = _212_
        local line = _each_213_[1]
        local col = _each_213_[2]
        local pos = _each_213_
        if not ((match_count == 0) and cold_repeat_3f and t_mode_3f0 and same_pos_3f(pos, next_pos)) then
          if (match_count <= dec(count0)) then
            jump_pos = pos
          else
            if not op_mode_3f then
              hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
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
        local function _218_()
          if t_mode_3f0 then
            local function _219_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_219_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            else
              return nil
            end
          else
            return nil
          end
        end
        jump_to_21_2a(jump_pos, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = true, ["add-to-jumplist?"] = not instant_repeat_3f, adjust = _218_})
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
        local _224_
        local function _225_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _226_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _224_ = (_225_() or _226_())
        if (nil ~= _224_) then
          local in2 = _224_
          local stack
          local function _228_()
            local t_227_ = instant_state
            if (nil ~= t_227_) then
              t_227_ = (t_227_).stack
            else
            end
            return t_227_
          end
          stack = (_228_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _231_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_231_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, stack = stack, ["reverted?"] = false, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
          elseif (_231_ == "revert") then
            do
              local _232_ = table.remove(stack)
              if (nil ~= _232_) then
                vim.fn.cursor(_232_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["in"] = in1, stack = stack, ["reverted?"] = true, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
          elseif true then
            local _ = _231_
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
do
  local deprec_msg = {{"ligthspeed.nvim", "Question"}, {": You're trying to access deprecated fields in the lightspeed.ft table.\n"}, {"There are dedicated <Plug> keys available for native-like "}, {";", "Visual"}, {" and "}, {",", "Visual"}, {" functionality now.\n"}, {"See "}, {":h lightspeed-custom-mappings", "Visual"}, {"."}}
  local function _239_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    else
      return nil
    end
  end
  setmetatable(ft, {__index = _239_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_241_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_241_[1]
  local right_bound = _let_241_[2]
  local _let_242_ = get_cursor_pos()
  local curline = _let_242_[1]
  local curcol = _let_242_[2]
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
        local ch0
        if opts.ignore_case then
          ch0 = ch:lower()
        else
          ch0 = ch
        end
        local _247_
        do
          local _246_ = unique_chars[ch0]
          if (nil ~= _246_) then
            local pos_already_there = _246_
            _247_ = false
          elseif true then
            local _ = _246_
            _247_ = {lnum, col}
          else
            _247_ = nil
          end
        end
        unique_chars[ch0] = _247_
      else
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _252_ = pos
    if ((_G.type(_252_) == "table") and (nil ~= (_252_)[1]) and (nil ~= (_252_)[2])) then
      local lnum = (_252_)[1]
      local col = (_252_)[2]
      hl["add-hl"](hl, hl.group["unique-ch"], dec(lnum), dec(col), col)
    else
    end
  end
  return nil
end
local function get_targets(input, reverse_3f)
  local targets = {}
  local to_eol_3f = (input == "\13")
  local prev_match = {}
  local added_prev_match_3f = nil
  local pattern
  if to_eol_3f then
    pattern = "\\n"
  else
    local function _254_()
      if opts.ignore_case then
        return "\\c"
      else
        return "\\C"
      end
    end
    pattern = ("\\V" .. _254_() .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _256_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f}) do
    local _each_257_ = _256_
    local line = _each_257_[1]
    local col = _each_257_[2]
    local pos = _each_257_
    if to_eol_3f then
      table.insert(targets, {pos = pos, pair = {"\n", ""}})
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _258_
      if reverse_3f then
        _258_ = dec
      else
        _258_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _258_(prev_match.col)))
      local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
      local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
      prev_match = {line = line, col = col, ch2 = ch2}
      if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
        added_prev_match_3f = false
      else
        local target = {pos = pos, pair = {ch1, ch2}}
        local prev_target = last(targets)
        local match_width = 2
        local touches_prev_target_3f
        do
          local _260_ = prev_target
          if ((_G.type(_260_) == "table") and ((_G.type((_260_).pos) == "table") and (nil ~= ((_260_).pos)[1]) and (nil ~= ((_260_).pos)[2]))) then
            local prev_line = ((_260_).pos)[1]
            local prev_col = ((_260_).pos)[2]
            local function _262_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta <= match_width)
            end
            touches_prev_target_3f = ((line == prev_line) and _262_())
          else
            touches_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        else
        end
        if touches_prev_target_3f then
          local _265_
          if reverse_3f then
            _265_ = target
          else
            _265_ = prev_target
          end
          _265_["squeezed?"] = true
        else
        end
        if overlaps_prev_target_3f then
          local _268_
          if reverse_3f then
            _268_ = prev_target
          else
            _268_ = target
          end
          _268_["overlapped?"] = true
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
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.ignore_case then
    local function _274_(self, k)
      return rawget(self, k:lower())
    end
    setmetatable(targets.sublists, {__index = _274_})
  else
  end
  for _, _276_ in ipairs(targets) do
    local _each_277_ = _276_
    local _each_278_ = _each_277_["pair"]
    local _0 = _each_278_[1]
    local ch2 = _each_278_[2]
    local target = _each_277_
    local k
    if opts.ignore_case then
      k = ch2:lower()
    else
      k = ch2
    end
    if not targets.sublists[k] then
      targets["sublists"][k] = {}
    else
    end
    table.insert(targets.sublists[k], target)
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
    local _284_ = sublist["autojump?"]
    if (_284_ == true) then
      return opts.safe_labels
    elseif (_284_ == false) then
      return opts.labels
    elseif (_284_ == nil) then
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
        local _287_
        if not (sublist["autojump?"] and (i == 1)) then
          local _288_
          local function _290_()
            if sublist["autojump?"] then
              return dec(i)
            else
              return i
            end
          end
          _288_ = (_290_() % #labels)
          if (_288_ == 0) then
            _287_ = last(labels)
          elseif (nil ~= _288_) then
            local n = _288_
            _287_ = labels[n]
          else
            _287_ = nil
          end
        else
          _287_ = nil
        end
        target["label"] = _287_
      end
    else
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _296_)
  local _arg_297_ = _296_
  local group_offset = _arg_297_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local function _298_()
    if sublist["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _298_())
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _299_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _299_ = "inactive"
      elseif (i <= primary_end) then
        _299_ = "active-primary"
      else
        _299_ = "active-secondary"
      end
    else
      _299_ = nil
    end
    target["label-state"] = _299_
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
      local _302_, _303_ = ch2, true
      if ((nil ~= _302_) and (nil ~= _303_)) then
        local k_13_auto = _302_
        local v_14_auto = _303_
        tbl_12_auto[k_13_auto] = v_14_auto
      else
      end
    end
    potential_2nd_inputs = tbl_12_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _305_ in ipairs(targets) do
    local _each_306_ = _305_
    local label = _each_306_["label"]
    local label_state = _each_306_["label-state"]
    local target = _each_306_
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
local function set_beacon(_309_, _repeat)
  local _arg_310_ = _309_
  local _arg_311_ = _arg_310_["pos"]
  local _ = _arg_311_[1]
  local col = _arg_311_[2]
  local _arg_312_ = _arg_310_["pair"]
  local ch1 = _arg_312_[1]
  local ch2 = _arg_312_[2]
  local label = _arg_310_["label"]
  local label_state = _arg_310_["label-state"]
  local squeezed_3f = _arg_310_["squeezed?"]
  local overlapped_3f = _arg_310_["overlapped?"]
  local shortcut_3f = _arg_310_["shortcut?"]
  local target = _arg_310_
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local _let_313_ = get_horizontal_bounds({["match-width"] = 1})
  local left_bound = _let_313_[1]
  local right_bound = _let_313_[2]
  local function _315_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_314_ = map(_315_, {ch1, ch2})
  local ch10 = _let_314_[1]
  local ch20 = _let_314_[2]
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _316_ = label_state
    if (_316_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
        end
      else
        target.beacon = nil
      end
    elseif (_316_ == "active-primary") then
      if to_eol_3f then
        if (vim.wo.wrap or ((col <= right_bound) and (col >= left_bound))) then
          target.beacon = {0, {shortcut_24}}
        elseif (col > right_bound) then
          target.beacon = {dec((right_bound - col)), {shortcut_24, {">", hl.group["one-char-match"]}}}
        elseif (col < left_bound) then
          target.beacon = {0, {{"<", hl.group["one-char-match"]}, shortcut_24}, "left-off"}
        else
          target.beacon = nil
        end
      elseif _repeat then
        local _320_
        if squeezed_3f then
          _320_ = 1
        else
          _320_ = 2
        end
        target.beacon = {_320_, {shortcut_24}}
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
    elseif (_316_ == "active-secondary") then
      if to_eol_3f then
        if (vim.wo.wrap or ((col <= right_bound) and (col >= left_bound))) then
          target.beacon = {0, {distant_label_24}}
        elseif (col > right_bound) then
          target.beacon = {dec((right_bound - col)), {distant_label_24, {">", hl.group["unlabeled-match"]}}}
        elseif (col < left_bound) then
          target.beacon = {0, {{"<", hl.group["unlabeled-match"]}, distant_label_24}, "left-off"}
        else
          target.beacon = nil
        end
      elseif _repeat then
        local _326_
        if squeezed_3f then
          _326_ = 1
        else
          _326_ = 2
        end
        target.beacon = {_326_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_316_ == "inactive") then
      target.beacon = nil
    else
      target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _330_)
  local _arg_331_ = _330_
  local _repeat = _arg_331_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_332_ = target_list[i]
    local _let_333_ = _let_332_["pos"]
    local line = _let_333_[1]
    local col = _let_333_[2]
    local beacon = _let_332_["beacon"]
    local _334_ = beacon
    if ((_G.type(_334_) == "table") and (nil ~= (_334_)[1]) and (nil ~= (_334_)[2]) and true) then
      local offset = (_334_)[1]
      local chunks = (_334_)[2]
      local _3fleft_off_3f = (_334_)[3]
      local _335_
      if _3fleft_off_3f then
        _335_ = 0
      else
        _335_ = nil
      end
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _335_})
    else
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _338_ in ipairs(target_list) do
    local _each_339_ = _338_
    local label = _each_339_["label"]
    local label_state = _each_339_["label-state"]
    local target = _each_339_
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    else
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _341_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _341_) then
    local input = _341_
    if (input ~= char_to_ignore) then
      return vim.fn.feedkeys(input, "i")
    else
      return nil
    end
  else
    return nil
  end
end
local sx = {state = {dot = {in1 = nil, in2 = nil, in3 = nil}, cold = {in1 = nil, in2 = nil, ["reverse?"] = nil, ["x-mode?"] = nil}}}
sx.go = function(self, reverse_3f, x_mode_3f, repeat_invoc)
  local mode = api.nvim_get_mode().mode
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
    local function _345_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _345_(self.state.cold["reverse?"])
  else
    reverse_3f0 = reverse_3f
  end
  local x_mode_3f0
  if cold_repeat_3f then
    x_mode_3f0 = self.state.cold["x-mode?"]
  else
    x_mode_3f0 = x_mode_3f
  end
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
      local _349_
      local function _350_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _351_()
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
      _349_ = (_350_() or _351_())
      if (_349_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _353_()
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
        return (self.state.cold.in1 or _353_())
      elseif (nil ~= _349_) then
        local _in = _349_
        return _in
      else
        return nil
      end
    end
  end
  local function update_state_2a(in1)
    local function _359_(_357_)
      local _arg_358_ = _357_
      local cold = _arg_358_["cold"]
      local dot = _arg_358_["dot"]
      if new_search_3f then
        if cold then
          local _360_ = cold
          _360_["in1"] = in1
          _360_["x-mode?"] = x_mode_3f0
          _360_["reverse?"] = reverse_3f0
          self.state.cold = _360_
        else
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _362_ = dot
              _362_["in1"] = in1
              _362_["x-mode?"] = x_mode_3f0
              self.state.dot = _362_
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
    return _359_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _366_(target, _3fto_pre_eol_3f)
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      local function _367_()
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
      adjusted_pos = jump_to_21_2a(target, {mode = mode, ["reverse?"] = reverse_3f0, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), adjust = _367_})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _366_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _373_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_372_ = _373_()
    local startline = _let_372_[1]
    local startcol = _let_372_[2]
    local start = _let_372_
    local function _375_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_374_ = _375_()
    local _ = _let_374_[1]
    local endcol = _let_374_[2]
    local _end = _let_374_
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
    local _380_ = targets.sublists[ch]
    if (nil ~= _380_) then
      local sublist = _380_
      local _let_381_ = sublist
      local _let_382_ = _let_381_[1]
      local _let_383_ = _let_382_["pos"]
      local line = _let_383_[1]
      local col = _let_383_[2]
      local rest = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_381_, 2)
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
    local next_group_key = replace_keycodes(opts.cycle_group_fwd_key)
    local prev_group_key = replace_keycodes(opts.cycle_group_bwd_key)
    local function recur(group_offset, initial_invoc_3f)
      local _387_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _387_ = "cold"
      elseif instant_repeat_3f then
        _387_ = "instant"
      else
        _387_ = nil
      end
      set_beacons(sublist, {["repeat"] = _387_})
      do
        if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f or to_eol_3f)) then
          grey_out_search_area(reverse_3f0)
        else
        end
        do
          light_up_beacons(sublist, start_idx)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _390_
      do
        local res_2_auto
        do
          local function _391_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            else
              return nil
            end
          end
          res_2_auto = get_input(_391_())
        end
        hl:cleanup()
        _390_ = res_2_auto
      end
      if (nil ~= _390_) then
        local input = _390_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _393_
          do
            local _392_ = input
            if (_392_ == next_group_key) then
              _393_ = inc
            elseif true then
              local _ = _392_
              _393_ = dec
            else
              _393_ = nil
            end
          end
          group_offset_2a = clamp(_393_(group_offset), 0, max_offset)
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
  enter("sx")
  if not repeat_invoc then
    echo("")
    if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f or to_eol_3f)) then
      grey_out_search_area(reverse_3f0)
    else
    end
    do
      if opts.highlight_unique_chars then
        highlight_unique_chars(reverse_3f0)
      else
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  else
  end
  local _402_ = get_first_input()
  if (nil ~= _402_) then
    local in1 = _402_
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
    local _404_
    local function _406_()
      local t_405_ = instant_state
      if (nil ~= t_405_) then
        t_405_ = (t_405_).sublist
      else
      end
      return t_405_
    end
    local function _408_()
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
    _404_ = (_406_() or get_targets(in1, reverse_3f0) or _408_())
    if ((_G.type(_404_) == "table") and ((_G.type((_404_)[1]) == "table") and ((_G.type(((_404_)[1]).pair) == "table") and true and (nil ~= (((_404_)[1]).pair)[2]))) and ((_404_)[2] == nil)) then
      local _0 = (((_404_)[1]).pair)[1]
      local ch2 = (((_404_)[1]).pair)[2]
      local only = (_404_)[1]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
          else
          end
          update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = opts.labels[1]}})
          local to_pos = jump_to_21(only.pos, (ch2 == "\13"))
          if new_search_3f then
            local res_2_auto
            do
              highlight_new_curpos_and_op_area(from_pos, to_pos)
              res_2_auto = ignore_input_until_timeout(ch2)
            end
            hl:cleanup()
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
    elseif (nil ~= _404_) then
      local targets = _404_
      if not instant_repeat_3f then
        local _414_ = targets
        populate_sublists(_414_)
        set_labels(_414_, to_eol_3f)
        set_label_states(_414_)
      else
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _416_ = targets
          set_shortcuts_and_populate_shortcuts_map(_416_)
          set_beacons(_416_, {["repeat"] = nil})
        end
        if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f or to_eol_3f)) then
          grey_out_search_area(reverse_3f0)
        else
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      else
      end
      local _419_
      local function _420_()
        if to_eol_3f then
          return ""
        else
          return nil
        end
      end
      local function _421_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _422_()
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
      _419_ = (prev_in2 or _420_() or _421_() or _422_())
      if (nil ~= _419_) then
        local in2 = _419_
        local _424_
        do
          local t_425_ = targets.shortcuts
          if (nil ~= t_425_) then
            t_425_ = (t_425_)[in2]
          else
          end
          _424_ = t_425_
        end
        if ((_G.type(_424_) == "table") and ((_G.type((_424_).pair) == "table") and true and (nil ~= ((_424_).pair)[2]))) then
          local _0 = ((_424_).pair)[1]
          local ch2 = ((_424_).pair)[2]
          local shortcut = _424_
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            else
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut.pos, (ch2 == "\13"))
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        elseif true then
          local _0 = _424_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _428_
          local function _430_()
            local t_429_ = instant_state
            if (nil ~= t_429_) then
              t_429_ = (t_429_).sublist
            else
            end
            return t_429_
          end
          local function _432_()
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
          _428_ = (_430_() or get_sublist(targets, in2) or _432_())
          if ((_G.type(_428_) == "table") and (nil ~= (_428_)[1]) and ((_428_)[2] == nil)) then
            local only = (_428_)[1]
            do
              if dot_repeatable_op_3f then
                set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
              else
              end
              update_state({dot = {in2 = in2, in3 = opts.labels[1]}})
              jump_to_21(only.pos)
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          elseif ((_G.type(_428_) == "table") and (nil ~= (_428_)[1])) then
            local first = (_428_)[1]
            local sublist = _428_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _436_()
              local t_435_ = instant_state
              if (nil ~= t_435_) then
                t_435_ = (t_435_).idx
              else
              end
              return t_435_
            end
            local function _438_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_436_() or _438_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first.pos)
            else
            end
            local _441_
            local function _442_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              else
                return nil
              end
            end
            local function _443_()
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
            _441_ = (_442_() or get_last_input(sublist, inc(curr_idx)) or _443_())
            if ((_G.type(_441_) == "table") and (nil ~= (_441_)[1]) and (nil ~= (_441_)[2])) then
              local in3 = (_441_)[1]
              local group_offset = (_441_)[2]
              local _445_
              if not (op_mode_3f or (group_offset > 0)) then
                _445_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
                _445_ = nil
              end
              if (nil ~= _445_) then
                local action = _445_
                local idx
                do
                  local _447_ = action
                  if (_447_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_447_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                    idx = nil
                  end
                end
                jump_to_21(sublist[idx].pos)
                return sx:go(reverse_3f0, x_mode_3f0, {in1 = in1, in2 = in2, sublist = sublist, idx = idx, ["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f})
              elseif true then
                local _1 = _445_
                local _449_ = get_target_with_active_primary_label(sublist, in3)
                if (nil ~= _449_) then
                  local target = _449_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    else
                    end
                    local _451_
                    if (group_offset > 0) then
                      _451_ = nil
                    else
                      _451_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _451_}})
                    jump_to_21(target.pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                elseif true then
                  local _2 = _449_
                  if autojump_3f then
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
    local _let_464_ = vim.split(opt, ".", true)
    local _0 = _let_464_[1]
    local scope = _let_464_[2]
    local name = _let_464_[3]
    local _465_
    if (opt == "vim.wo.scrolloff") then
      _465_ = api.nvim_eval("&l:scrolloff")
    else
      _465_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _465_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_467_ = vim.split(opt, ".", true)
    local _ = _let_467_[1]
    local scope = _let_467_[2]
    local name = _let_467_[3]
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
  local plug_keys = {{"<Plug>Lightspeed_s", "sx:go(false)"}, {"<Plug>Lightspeed_S", "sx:go(true)"}, {"<Plug>Lightspeed_x", "sx:go(false, true)"}, {"<Plug>Lightspeed_X", "sx:go(true, true)"}, {"<Plug>Lightspeed_f", "ft:go(false)"}, {"<Plug>Lightspeed_F", "ft:go(true)"}, {"<Plug>Lightspeed_t", "ft:go(false, true)"}, {"<Plug>Lightspeed_T", "ft:go(true, true)"}, {"<Plug>Lightspeed_;_sx", "sx:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_sx", "sx:go(true, nil, 'cold')"}, {"<Plug>Lightspeed_;_ft", "ft:go(false, nil, 'cold')"}, {"<Plug>Lightspeed_,_ft", "ft:go(true, nil, 'cold')"}}
  for _, _468_ in ipairs(plug_keys) do
    local _each_469_ = _468_
    local lhs = _each_469_[1]
    local rhs_call = _each_469_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _470_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_471_ = _470_
    local lhs = _each_471_[1]
    local rhs_call = _each_471_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _472_ in ipairs(default_keymaps) do
    local _each_473_ = _472_
    local mode = _each_473_[1]
    local lhs = _each_473_[2]
    local rhs = _each_473_[3]
    if ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0)) then
      api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
    else
    end
  end
  return nil
end
init_highlight()
set_plug_keys()
vim.cmd("augroup lightspeed_reinit_highlight\n   autocmd!\n   autocmd ColorScheme * lua require'lightspeed'.init_highlight()\n   augroup end")
vim.cmd("augroup lightspeed_editor_opts\n   autocmd!\n   autocmd User LightspeedEnter lua require'lightspeed'.save_editor_opts(); require'lightspeed'.set_temporary_editor_opts()\n   autocmd User LightspeedLeave lua require'lightspeed'.restore_editor_opts()\n   augroup end")
return {opts = opts, setup = setup, ft = ft, sx = sx, save_editor_opts = save_editor_opts, set_temporary_editor_opts = set_temporary_editor_opts, restore_editor_opts = restore_editor_opts, init_highlight = init_highlight, set_default_keymaps = set_default_keymaps}
