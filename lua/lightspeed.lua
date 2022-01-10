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
  local labels = {"s", "f", "n", "j", "k", "l", "o", "i", "w", "e", "h", "g", "u", "t", "m", "v", "c", "a", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  opts = {cycle_group_bwd_key = "<tab>", cycle_group_fwd_key = "<space>", exit_after_idle_msecs = {labeled = nil, unlabeled = 1000}, force_beacons_into_match_width = false, grey_out_search_area = true, highlight_unique_chars = true, ignore_case = false, jump_on_partial_input_safety_timeout = 400, labels = labels, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, repeat_ft_with_target_char = false, safe_labels = safe_labels, substitute_chars = {["\13"] = "\194\172"}}
end
local deprecated_opts = {"jump_to_first_match", "instant_repeat_fwd_key", "instant_repeat_bwd_key", "x_mode_prefix_key", "full_inclusive_prefix_key"}
local function get_deprec_msg(arg_fields)
  local msg = {{"ligthspeed.nvim\n", "Question"}, {"You are trying to set or access deprecated fields in the "}, {"opts", "Visual"}, {" table:\n\n"}}
  local field_names
  do
    local tbl_12_auto = {}
    for _, field in ipairs(arg_fields) do
      tbl_12_auto[(#tbl_12_auto + 1)] = {("\9" .. field .. "\n")}
    end
    field_names = tbl_12_auto
  end
  local msg_for_instant_repeat_keys = {{"There are dedicated "}, {"<Plug>", "Visual"}, {" keys available for native-like "}, {";", "Visual"}, {" and "}, {",", "Visual"}, {" functionality now, "}, {"that can also be used for instant repeat only, if you prefer. See "}, {":h lightspeed-custom-mappings", "Visual"}, {"."}}
  local msg_for_x_prefix = {{"Use "}, {"<Plug>Lightspeed_x", "Visual"}, {" and "}, {"<Plug>Lightspeed_X", "Visual"}, {" instead."}}
  local spec_messages = {full_inclusive_prefix_key = msg_for_x_prefix, instant_repeat_bwd_key = msg_for_instant_repeat_keys, instant_repeat_fwd_key = msg_for_instant_repeat_keys, jump_to_first_match = {{"The plugin implements \"smart\" auto-jump now, that you can fine-tune via "}, {"opts.labels", "Visual"}, {" and "}, {"opts.safe_labels", "Visual"}, {". See "}, {":h lightspeed-config", "Visual"}, {" for details."}}, x_mode_prefix_key = msg_for_x_prefix}
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
    if contains_3f(deprecated_opts, k) then
      return api.nvim_echo(get_deprec_msg({k}), true, {})
    end
  end
  guard = _22_
  setmetatable(opts, {__index = guard, __newindex = guard})
end
local function normalize_opts(opts0)
  local deprecated_arg_opts = {}
  for k, v in pairs(opts0) do
    if contains_3f(deprecated_opts, k) then
      table.insert(deprecated_arg_opts, k)
      do end (opts0)[k] = nil
    end
  end
  if not empty_3f(deprecated_arg_opts) then
    api.nvim_echo(get_deprec_msg(deprecated_arg_opts), true, {})
  end
  return opts0
end
local function setup(user_opts)
  opts = setmetatable(normalize_opts(user_opts), {__index = opts})
  return nil
end
local hl
local function _26_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _27_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _28_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _26_, ["set-extmark"] = _27_, cleanup = _28_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
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
local function grey_out_search_area(reverse_3f)
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
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
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
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
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
  local reverse_3f = _arg_109_["reverse?"]
  local skip_folds_3f = _arg_109_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _110_
    if reverse_3f then
      _110_ = (lnum >= wintop)
    else
      _110_ = (lnum <= winbot)
    end
    if not _110_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _112_
      if reverse_3f then
        _112_ = dec
      else
        _112_ = inc
      end
      lnum = _112_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _114_
      if reverse_3f then
        _114_ = dec
      else
        _114_ = inc
      end
      lnum = _114_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_117_)
  local _arg_118_ = _117_
  local match_width = _arg_118_["match-width"]
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _119_)
  local _arg_120_ = _119_
  local ft_search_3f = _arg_120_["ft-search?"]
  local limit = _arg_120_["limit"]
  local to_eol_3f = _arg_120_["to-eol?"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _122_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_122_())
  local cleanup
  local function _123_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _123_
  local _125_
  if ft_search_3f then
    _125_ = 1
  else
    _125_ = 2
  end
  local _let_124_ = get_horizontal_bounds({["match-width"] = _125_})
  local left_bound = _let_124_[1]
  local right_bound = _let_124_[2]
  local function skip_to_fold_edge_21()
    local _127_
    local _128_
    if reverse_3f then
      _128_ = vim.fn.foldclosed
    else
      _128_ = vim.fn.foldclosedend
    end
    _127_ = _128_(vim.fn.line("."))
    if (_127_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _127_) then
      local fold_edge = _127_
      vim.fn.cursor(fold_edge, 0)
      local function _130_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _130_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_132_ = get_cursor_pos()
    local line = _local_132_[1]
    local col = _local_132_[2]
    local from_pos = _local_132_
    local _133_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _133_ = {dec(line), right_bound}
        else
        _133_ = nil
        end
      else
        _133_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _133_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _133_ = {inc(line), left_bound}
        else
        _133_ = nil
        end
      end
    else
    _133_ = nil
    end
    if (nil ~= _133_) then
      local to_pos = _133_
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
      local _141_
      local _142_
      if match_at_curpos_3f then
        _142_ = "c"
      else
        _142_ = ""
      end
      _141_ = vim.fn.searchpos(pattern, (opts0 .. _142_), stopline)
      if ((type(_141_) == "table") and ((_141_)[1] == 0) and true) then
        local _ = (_141_)[2]
        return cleanup()
      elseif ((type(_141_) == "table") and (nil ~= (_141_)[1]) and (nil ~= (_141_)[2])) then
        local line = (_141_)[1]
        local col = (_141_)[2]
        local pos = _141_
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
              else
                local _ = _148_
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
  local _let_155_ = (_3fpos or get_cursor_pos())
  local line = _let_155_[1]
  local col = _let_155_[2]
  local pos = _let_155_
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
  local _158_ = mode
  if (_158_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_158_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
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
  local _168_
  do
    local _167_ = repeat_invoc
    if (_167_ == "dot") then
      _168_ = "dotrepeat_"
    else
      local _ = _167_
      _168_ = ""
    end
  end
  local _173_
  do
    local _172_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((type(_172_) == "table") and ((_172_)[1] == "ft") and ((_172_)[2] == false) and ((_172_)[3] == false)) then
      _173_ = "f"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "ft") and ((_172_)[2] == true) and ((_172_)[3] == false)) then
      _173_ = "F"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "ft") and ((_172_)[2] == false) and ((_172_)[3] == true)) then
      _173_ = "t"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "ft") and ((_172_)[2] == true) and ((_172_)[3] == true)) then
      _173_ = "T"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "sx") and ((_172_)[2] == false) and ((_172_)[3] == false)) then
      _173_ = "s"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "sx") and ((_172_)[2] == true) and ((_172_)[3] == false)) then
      _173_ = "S"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "sx") and ((_172_)[2] == false) and ((_172_)[3] == true)) then
      _173_ = "x"
    elseif ((type(_172_) == "table") and ((_172_)[1] == "sx") and ((_172_)[2] == true) and ((_172_)[3] == true)) then
      _173_ = "X"
    else
    _173_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _168_ .. _173_)
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
  local _184_
  if from_reverse_cold_repeat_3f then
    _184_ = revert_plug_key
  else
    _184_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _184_))) then
    return "repeat"
  else
    local _186_
    if from_reverse_cold_repeat_3f then
      _186_ = repeat_plug_key
    else
      _186_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _186_)))) then
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
    local t_190_ = instant_state
    if (nil ~= t_190_) then
      t_190_ = (t_190_)["reverted?"]
    end
    reverted_instant_repeat_3f = t_190_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _192_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _192_(self.state.cold["reverse?"])
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
    local _198_ = opts.limit_ft_matches
    local function _199_()
      local group_limit = _198_
      return (group_limit > 0)
    end
    if ((nil ~= _198_) and _199_()) then
      local group_limit = _198_
      local matches_left_behind
      local function _201_()
        local _200_ = instant_state
        if _200_ then
          local _202_ = (_200_).stack
          if _202_ then
            return #_202_
          else
            return _202_
          end
        else
          return _200_
        end
      end
      matches_left_behind = (_201_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    else
      local _ = _198_
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
  local _209_
  if instant_repeat_3f then
    _209_ = instant_state["in"]
  elseif dot_repeat_3f then
    _209_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _209_ = self.state.cold["in"]
  else
    local _210_
    local function _211_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _212_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _210_ = (_211_() or _212_())
    if (_210_ == _3cbackspace_3e) then
      local function _214_()
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
      _209_ = (self.state.cold["in"] or _214_())
    elseif (nil ~= _210_) then
      local _in = _210_
      _209_ = _in
    else
    _209_ = nil
    end
  end
  if (nil ~= _209_) then
    local in1 = _209_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _219_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _219_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        local _220_
        if opts.ignore_case then
          _220_ = "\\c"
        else
          _220_ = "\\C"
        end
        pattern = ("\\V" .. _220_ .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _223_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_224_ = _223_
        local line = _each_224_[1]
        local col = _each_224_[2]
        local pos = _each_224_
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
        local function _229_()
          if t_mode_3f0 then
            local function _230_()
              if reverse_3f0 then
                return "fwd"
              else
                return "bwd"
              end
            end
            push_cursor_21(_230_())
            if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
              return push_cursor_21("fwd")
            end
          end
        end
        jump_to_21_2a(jump_pos, {["add-to-jumplist?"] = not instant_repeat_3f, ["inclusive-motion?"] = true, ["reverse?"] = reverse_3f0, adjust = _229_, mode = mode})
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
        local _235_
        local function _236_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _237_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _235_ = (_236_() or _237_())
        if (nil ~= _235_) then
          local in2 = _235_
          local stack
          local function _239_()
            local t_238_ = instant_state
            if (nil ~= t_238_) then
              t_238_ = (t_238_).stack
            end
            return t_238_
          end
          stack = (_239_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _242_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_242_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = false, stack = stack})
          elseif (_242_ == "revert") then
            do
              local _243_ = table.remove(stack)
              if _243_ then
                vim.fn.cursor(_243_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = true, stack = stack})
          else
            local _ = _242_
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
  local function _250_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _250_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_252_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_252_[1]
  local right_bound = _let_252_[2]
  local _let_253_ = get_cursor_pos()
  local curline = _let_253_[1]
  local curcol = _let_253_[2]
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
        local _258_
        do
          local _257_ = unique_chars[ch0]
          if (nil ~= _257_) then
            local pos_already_there = _257_
            _258_ = false
          else
            local _ = _257_
            _258_ = {lnum, col}
          end
        end
        unique_chars[ch0] = _258_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _263_ = pos
    if ((type(_263_) == "table") and (nil ~= (_263_)[1]) and (nil ~= (_263_)[2])) then
      local lnum = (_263_)[1]
      local col = (_263_)[2]
      hl["add-hl"](hl, hl.group["unique-ch"], dec(lnum), dec(col), col)
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
    local _265_
    if opts.ignore_case then
      _265_ = "\\c"
    else
      _265_ = "\\C"
    end
    pattern = ("\\V" .. _265_ .. input:gsub("\\", "\\\\") .. "\\_.")
  end
  for _268_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f}) do
    local _each_269_ = _268_
    local line = _each_269_[1]
    local col = _each_269_[2]
    local pos = _each_269_
    if to_eol_3f then
      table.insert(targets, {pair = {"\n", ""}, pos = pos})
    else
      local ch1 = char_at_pos(pos, {})
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _270_
      if reverse_3f then
        _270_ = dec
      else
        _270_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _270_(prev_match.col)))
      local same_char_triplet_3f = (overlaps_prev_match_3f and (ch2 == prev_match.ch2))
      local overlaps_prev_target_3f = (overlaps_prev_match_3f and added_prev_match_3f)
      prev_match = {ch2 = ch2, col = col, line = line}
      if (same_char_triplet_3f and (added_prev_match_3f or opts.match_only_the_start_of_same_char_seqs)) then
        added_prev_match_3f = false
      else
        local target = {pair = {ch1, ch2}, pos = pos}
        local prev_target = last(targets)
        local min_delta_to_prevent_squeezing = 4
        local close_to_prev_target_3f
        do
          local _272_ = prev_target
          if ((type(_272_) == "table") and ((type((_272_).pos) == "table") and (nil ~= ((_272_).pos)[1]) and (nil ~= ((_272_).pos)[2]))) then
            local prev_line = ((_272_).pos)[1]
            local prev_col = ((_272_).pos)[2]
            local function _274_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta < min_delta_to_prevent_squeezing)
            end
            close_to_prev_target_3f = ((line == prev_line) and _274_())
          else
          close_to_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        end
        if close_to_prev_target_3f then
          local _277_
          if reverse_3f then
            _277_ = target
          else
            _277_ = prev_target
          end
          _277_["squeezed?"] = true
        end
        if overlaps_prev_target_3f then
          local _280_
          if reverse_3f then
            _280_ = prev_target
          else
            _280_ = target
          end
          _280_["overlapped?"] = true
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
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.ignore_case then
    local function _286_(self, k)
      return rawget(self, k:lower())
    end
    setmetatable(targets.sublists, {__index = _286_})
  end
  for _, _288_ in ipairs(targets) do
    local _each_289_ = _288_
    local target = _each_289_
    local _each_290_ = _each_289_["pair"]
    local _0 = _each_290_[1]
    local ch2 = _each_290_[2]
    local k
    if opts.ignore_case then
      k = ch2:lower()
    else
      k = ch2
    end
    if not targets.sublists[k] then
      targets["sublists"][k] = {}
    end
    table.insert(targets.sublists[k], target)
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
    local _296_ = sublist["autojump?"]
    if (_296_ == true) then
      return opts.safe_labels
    elseif (_296_ == false) then
      return opts.labels
    elseif (_296_ == nil) then
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
        local _299_
        if not (sublist["autojump?"] and (i == 1)) then
          local _300_
          local _302_
          if sublist["autojump?"] then
            _302_ = dec(i)
          else
            _302_ = i
          end
          _300_ = (_302_ % #labels)
          if (_300_ == 0) then
            _299_ = last(labels)
          elseif (nil ~= _300_) then
            local n = _300_
            _299_ = labels[n]
          else
          _299_ = nil
          end
        else
        _299_ = nil
        end
        target["label"] = _299_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _309_)
  local _arg_310_ = _309_
  local group_offset = _arg_310_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _311_
  if sublist["autojump?"] then
    _311_ = 2
  else
    _311_ = 1
  end
  primary_start = (offset + _311_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _313_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _313_ = "inactive"
      elseif (i <= primary_end) then
        _313_ = "active-primary"
      else
        _313_ = "active-secondary"
      end
    else
    _313_ = nil
    end
    target["label-state"] = _313_
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
      local _316_, _317_ = ch2, true
      if ((nil ~= _316_) and (nil ~= _317_)) then
        local k_10_auto = _316_
        local v_11_auto = _317_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _319_ in ipairs(targets) do
    local _each_320_ = _319_
    local target = _each_320_
    local label = _each_320_["label"]
    local label_state = _each_320_["label-state"]
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
local function set_beacon(_323_, _repeat)
  local _arg_324_ = _323_
  local target = _arg_324_
  local label = _arg_324_["label"]
  local label_state = _arg_324_["label-state"]
  local overlapped_3f = _arg_324_["overlapped?"]
  local _arg_325_ = _arg_324_["pair"]
  local ch1 = _arg_325_[1]
  local ch2 = _arg_325_[2]
  local _arg_326_ = _arg_324_["pos"]
  local _ = _arg_326_[1]
  local col = _arg_326_[2]
  local shortcut_3f = _arg_324_["shortcut?"]
  local squeezed_3f = _arg_324_["squeezed?"]
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local _let_327_ = get_horizontal_bounds({["match-width"] = 1})
  local left_bound = _let_327_[1]
  local right_bound = _let_327_[2]
  local function _329_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_328_ = map(_329_, {ch1, ch2})
  local ch10 = _let_328_[1]
  local ch20 = _let_328_[2]
  local squeezed_3f0 = (opts.force_beacons_into_match_width or squeezed_3f)
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _330_ = label_state
    if (_330_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
        end
      else
      target.beacon = nil
      end
    elseif (_330_ == "active-primary") then
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
        local _334_
        if squeezed_3f0 then
          _334_ = 1
        else
          _334_ = 2
        end
        target.beacon = {_334_, {shortcut_24}}
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
    elseif (_330_ == "active-secondary") then
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
        local _340_
        if squeezed_3f0 then
          _340_ = 1
        else
          _340_ = 2
        end
        target.beacon = {_340_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f0 then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_330_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _344_)
  local _arg_345_ = _344_
  local _repeat = _arg_345_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_346_ = target_list[i]
    local beacon = _let_346_["beacon"]
    local _let_347_ = _let_346_["pos"]
    local line = _let_347_[1]
    local col = _let_347_[2]
    local _348_ = beacon
    if ((type(_348_) == "table") and (nil ~= (_348_)[1]) and (nil ~= (_348_)[2]) and true) then
      local offset = (_348_)[1]
      local chunks = (_348_)[2]
      local _3fleft_off_3f = (_348_)[3]
      local _349_
      if _3fleft_off_3f then
        _349_ = 0
      else
      _349_ = nil
      end
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _349_})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _352_ in ipairs(target_list) do
    local _each_353_ = _352_
    local target = _each_353_
    local label = _each_353_["label"]
    local label_state = _each_353_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _355_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _355_) then
    local input = _355_
    if (input ~= char_to_ignore) then
      return vim.fn.feedkeys(input, "i")
    end
  end
end
local sx = {state = {cold = {["reverse?"] = nil, ["x-mode?"] = nil, in1 = nil, in2 = nil}, dot = {in1 = nil, in2 = nil, in3 = nil}}}
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
    local function _359_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _359_(self.state.cold["reverse?"])
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
      local _363_
      local function _364_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _365_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _363_ = (_364_() or _365_())
      if (_363_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _367_()
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
        return (self.state.cold.in1 or _367_())
      elseif (nil ~= _363_) then
        local _in = _363_
        return _in
      end
    end
  end
  local function update_state_2a(in1)
    local function _373_(_371_)
      local _arg_372_ = _371_
      local cold = _arg_372_["cold"]
      local dot = _arg_372_["dot"]
      if new_search_3f then
        if cold then
          local _374_ = cold
          _374_["in1"] = in1
          _374_["x-mode?"] = x_mode_3f0
          _374_["reverse?"] = reverse_3f0
          self.state.cold = _374_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _376_ = dot
              _376_["in1"] = in1
              _376_["x-mode?"] = x_mode_3f0
              self.state.dot = _376_
            end
            return nil
          end
        end
      end
    end
    return _373_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _380_(target, _3fto_pre_eol_3f)
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      local function _381_()
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
      adjusted_pos = jump_to_21_2a(target, {["add-to-jumplist?"] = (first_jump_3f and not instant_repeat_3f), ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0), ["reverse?"] = reverse_3f0, adjust = _381_, mode = mode})
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _380_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _387_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_386_ = _387_()
    local startline = _let_386_[1]
    local startcol = _let_386_[2]
    local start = _let_386_
    local function _389_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_388_ = _389_()
    local _ = _let_388_[1]
    local endcol = _let_388_[2]
    local _end = _let_388_
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
    local _394_ = targets.sublists[ch]
    if (nil ~= _394_) then
      local sublist = _394_
      local _let_395_ = sublist
      local _let_396_ = _let_395_[1]
      local _let_397_ = _let_396_["pos"]
      local line = _let_397_[1]
      local col = _let_397_[2]
      local rest = {(table.unpack or unpack)(_let_395_, 2)}
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
    local next_group_key = replace_keycodes(opts.cycle_group_fwd_key)
    local prev_group_key = replace_keycodes(opts.cycle_group_bwd_key)
    local function recur(group_offset, initial_invoc_3f)
      local _401_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _401_ = "cold"
      elseif instant_repeat_3f then
        _401_ = "instant"
      else
      _401_ = nil
      end
      set_beacons(sublist, {["repeat"] = _401_})
      do
        if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f or to_eol_3f)) then
          grey_out_search_area(reverse_3f0)
        end
        do
          light_up_beacons(sublist, start_idx)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _404_
      do
        local res_2_auto
        do
          local function _405_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_405_())
        end
        hl:cleanup()
        _404_ = res_2_auto
      end
      if (nil ~= _404_) then
        local input = _404_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _407_
          do
            local _406_ = input
            if (_406_ == next_group_key) then
              _407_ = inc
            else
              local _ = _406_
              _407_ = dec
            end
          end
          group_offset_2a = clamp(_407_(group_offset), 0, max_offset)
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
    if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f or to_eol_3f)) then
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
  local _416_ = get_first_input()
  if (nil ~= _416_) then
    local in1 = _416_
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
    local _418_
    local function _420_()
      local t_419_ = instant_state
      if (nil ~= t_419_) then
        t_419_ = (t_419_).sublist
      end
      return t_419_
    end
    local function _422_()
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
    _418_ = (_420_() or get_targets(in1, reverse_3f0) or _422_())
    if ((type(_418_) == "table") and ((type((_418_)[1]) == "table") and ((type(((_418_)[1]).pair) == "table") and true and (nil ~= (((_418_)[1]).pair)[2]))) and ((_418_)[2] == nil)) then
      local only = (_418_)[1]
      local _0 = (((_418_)[1]).pair)[1]
      local ch2 = (((_418_)[1]).pair)[2]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
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
    elseif (nil ~= _418_) then
      local targets = _418_
      if not instant_repeat_3f then
        local _428_ = targets
        populate_sublists(_428_)
        set_labels(_428_, to_eol_3f)
        set_label_states(_428_)
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _430_ = targets
          set_shortcuts_and_populate_shortcuts_map(_430_)
          set_beacons(_430_, {["repeat"] = nil})
        end
        if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f or to_eol_3f)) then
          grey_out_search_area(reverse_3f0)
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _433_
      local function _434_()
        if to_eol_3f then
          return ""
        end
      end
      local function _435_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _436_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _433_ = (prev_in2 or _434_() or _435_() or _436_())
      if (nil ~= _433_) then
        local in2 = _433_
        local _438_
        do
          local t_439_ = targets.shortcuts
          if (nil ~= t_439_) then
            t_439_ = (t_439_)[in2]
          end
          _438_ = t_439_
        end
        if ((type(_438_) == "table") and ((type((_438_).pair) == "table") and true and (nil ~= ((_438_).pair)[2]))) then
          local shortcut = _438_
          local _0 = ((_438_).pair)[1]
          local ch2 = ((_438_).pair)[2]
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut.pos, (ch2 == "\13"))
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _0 = _438_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _442_
          local function _444_()
            local t_443_ = instant_state
            if (nil ~= t_443_) then
              t_443_ = (t_443_).sublist
            end
            return t_443_
          end
          local function _446_()
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
          _442_ = (_444_() or get_sublist(targets, in2) or _446_())
          if ((type(_442_) == "table") and (nil ~= (_442_)[1]) and ((_442_)[2] == nil)) then
            local only = (_442_)[1]
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
          elseif ((type(_442_) == "table") and (nil ~= (_442_)[1])) then
            local first = (_442_)[1]
            local sublist = _442_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _450_()
              local t_449_ = instant_state
              if (nil ~= t_449_) then
                t_449_ = (t_449_).idx
              end
              return t_449_
            end
            local function _452_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_450_() or _452_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first.pos)
            end
            local _455_
            local function _456_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              end
            end
            local function _457_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _455_ = (_456_() or get_last_input(sublist, inc(curr_idx)) or _457_())
            if ((type(_455_) == "table") and (nil ~= (_455_)[1]) and (nil ~= (_455_)[2])) then
              local in3 = (_455_)[1]
              local group_offset = (_455_)[2]
              local _459_
              if not (op_mode_3f or (group_offset > 0)) then
                _459_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
              _459_ = nil
              end
              if (nil ~= _459_) then
                local action = _459_
                local idx
                do
                  local _461_ = action
                  if (_461_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_461_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                  idx = nil
                  end
                end
                jump_to_21(sublist[idx].pos)
                return sx:go(reverse_3f0, x_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, idx = idx, in1 = in1, in2 = in2, sublist = sublist})
              else
                local _1 = _459_
                local _463_ = get_target_with_active_primary_label(sublist, in3)
                if (nil ~= _463_) then
                  local target = _463_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _465_
                    if (group_offset > 0) then
                      _465_ = nil
                    else
                      _465_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _465_}})
                    jump_to_21(target.pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _2 = _463_
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
    local _let_478_ = vim.split(opt, ".", true)
    local _0 = _let_478_[1]
    local scope = _let_478_[2]
    local name = _let_478_[3]
    local _479_
    if (opt == "vim.wo.scrolloff") then
      _479_ = api.nvim_eval("&l:scrolloff")
    else
      _479_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _479_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_481_ = vim.split(opt, ".", true)
    local _ = _let_481_[1]
    local scope = _let_481_[2]
    local name = _let_481_[3]
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
  for _, _482_ in ipairs(plug_keys) do
    local _each_483_ = _482_
    local lhs = _each_483_[1]
    local rhs_call = _each_483_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _484_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_485_ = _484_
    local lhs = _each_485_[1]
    local rhs_call = _each_485_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _486_ in ipairs(default_keymaps) do
    local _each_487_ = _486_
    local mode = _each_487_[1]
    local lhs = _each_487_[2]
    local rhs = _each_487_[3]
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
