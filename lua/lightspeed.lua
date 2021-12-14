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
  opts = {cycle_group_bwd_key = "<tab>", cycle_group_fwd_key = "<space>", exit_after_idle_msecs = {labeled = nil, unlabeled = 1000}, grey_out_search_area = true, highlight_unique_chars = true, jump_on_partial_input_safety_timeout = 400, labels = labels, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, repeat_ft_with_target_char = false, safe_labels = safe_labels, substitute_chars = {["\13"] = "\194\172"}}
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
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_onscreen_lines(_100_)
  local _arg_101_ = _100_
  local reverse_3f = _arg_101_["reverse?"]
  local skip_folds_3f = _arg_101_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _102_
    if reverse_3f then
      _102_ = (lnum >= wintop)
    else
      _102_ = (lnum <= winbot)
    end
    if not _102_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _104_
      if reverse_3f then
        _104_ = dec
      else
        _104_ = inc
      end
      lnum = _104_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _106_
      if reverse_3f then
        _106_ = dec
      else
        _106_ = inc
      end
      lnum = _106_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_109_)
  local _arg_110_ = _109_
  local match_width = _arg_110_["match-width"]
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _111_)
  local _arg_112_ = _111_
  local ft_search_3f = _arg_112_["ft-search?"]
  local limit = _arg_112_["limit"]
  local to_eol_3f = _arg_112_["to-eol?"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _114_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_114_())
  local cleanup
  local function _115_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _115_
  local _117_
  if ft_search_3f then
    _117_ = 1
  else
    _117_ = 2
  end
  local _let_116_ = get_horizontal_bounds({["match-width"] = _117_})
  local left_bound = _let_116_[1]
  local right_bound = _let_116_[2]
  local function skip_to_fold_edge_21()
    local _119_
    local _120_
    if reverse_3f then
      _120_ = vim.fn.foldclosed
    else
      _120_ = vim.fn.foldclosedend
    end
    _119_ = _120_(vim.fn.line("."))
    if (_119_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _119_) then
      local fold_edge = _119_
      vim.fn.cursor(fold_edge, 0)
      local function _122_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _122_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_124_ = get_cursor_pos()
    local line = _local_124_[1]
    local col = _local_124_[2]
    local from_pos = _local_124_
    local _125_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _125_ = {dec(line), right_bound}
        else
        _125_ = nil
        end
      else
        _125_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _125_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _125_ = {inc(line), left_bound}
        else
        _125_ = nil
        end
      end
    else
    _125_ = nil
    end
    if (nil ~= _125_) then
      local to_pos = _125_
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
      local _133_
      local _134_
      if match_at_curpos_3f then
        _134_ = "c"
      else
        _134_ = ""
      end
      _133_ = vim.fn.searchpos(pattern, (opts0 .. _134_), stopline)
      if ((type(_133_) == "table") and ((_133_)[1] == 0) and true) then
        local _ = (_133_)[2]
        return cleanup()
      elseif ((type(_133_) == "table") and (nil ~= (_133_)[1]) and (nil ~= (_133_)[2])) then
        local line = (_133_)[1]
        local col = (_133_)[2]
        local pos = _133_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _136_ = skip_to_fold_edge_21()
          if (_136_ == "moved-the-cursor") then
            return recur(false)
          elseif (_136_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_137_,_138_,_139_) return (_137_ <= _138_) and (_138_ <= _139_) end)(left_bound,col,right_bound) or to_eol_3f) then
              match_count = (match_count + 1)
              return pos
            else
              local _140_ = skip_to_next_in_window_pos_21()
              if (_140_ == "moved-the-cursor") then
                return recur(true)
              else
                local _ = _140_
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
  local _let_147_ = (_3fpos or get_cursor_pos())
  local line = _let_147_[1]
  local col = _let_147_[2]
  local pos = _let_147_
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
  local _150_ = mode
  if (_150_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_150_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _152_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _152_
  local getchar_timeout
  local function _153_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    end
  end
  getchar_timeout = _153_
  local ok_3f, ch = nil, nil
  local function _155_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_155_())
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
  local _160_
  do
    local _159_ = repeat_invoc
    if (_159_ == "dot") then
      _160_ = "dotrepeat_"
    else
      local _ = _159_
      _160_ = ""
    end
  end
  local _165_
  do
    local _164_ = {search_mode, not not reverse_3f, not not x_2ft_3f}
    if ((type(_164_) == "table") and ((_164_)[1] == "ft") and ((_164_)[2] == false) and ((_164_)[3] == false)) then
      _165_ = "f"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "ft") and ((_164_)[2] == true) and ((_164_)[3] == false)) then
      _165_ = "F"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "ft") and ((_164_)[2] == false) and ((_164_)[3] == true)) then
      _165_ = "t"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "ft") and ((_164_)[2] == true) and ((_164_)[3] == true)) then
      _165_ = "T"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "sx") and ((_164_)[2] == false) and ((_164_)[3] == false)) then
      _165_ = "s"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "sx") and ((_164_)[2] == true) and ((_164_)[3] == false)) then
      _165_ = "S"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "sx") and ((_164_)[2] == false) and ((_164_)[3] == true)) then
      _165_ = "x"
    elseif ((type(_164_) == "table") and ((_164_)[1] == "sx") and ((_164_)[2] == true) and ((_164_)[3] == true)) then
      _165_ = "X"
    else
    _165_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _160_ .. _165_)
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
  local _176_
  if from_reverse_cold_repeat_3f then
    _176_ = revert_plug_key
  else
    _176_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((search_mode == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(search_mode, false, x_2ft_3f)) or (in_mapped_to == _176_))) then
    return "repeat"
  else
    local _178_
    if from_reverse_cold_repeat_3f then
      _178_ = repeat_plug_key
    else
      _178_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(search_mode, true, x_2ft_3f)) or (in_mapped_to == _178_)))) then
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
    local t_182_ = instant_state
    if (nil ~= t_182_) then
      t_182_ = (t_182_)["reverted?"]
    end
    reverted_instant_repeat_3f = t_182_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _184_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _184_(self.state.cold["reverse?"])
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
    local _190_ = opts.limit_ft_matches
    local function _191_()
      local group_limit = _190_
      return (group_limit > 0)
    end
    if ((nil ~= _190_) and _191_()) then
      local group_limit = _190_
      local matches_left_behind
      local function _193_()
        local _192_ = instant_state
        if _192_ then
          local _194_ = (_192_).stack
          if _194_ then
            return #_194_
          else
            return _194_
          end
        else
          return _192_
        end
      end
      matches_left_behind = (_193_() or 0)
      local eaten_up = (matches_left_behind % group_limit)
      local remaining = (group_limit - eaten_up)
      if (remaining == 0) then
        return group_limit
      else
        return remaining
      end
    else
      local _ = _190_
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
  local _201_
  if instant_repeat_3f then
    _201_ = instant_state["in"]
  elseif dot_repeat_3f then
    _201_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _201_ = self.state.cold["in"]
  else
    local _202_
    local function _203_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _204_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _202_ = (_203_() or _204_())
    if (_202_ == _3cbackspace_3e) then
      local function _206_()
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
      _201_ = (self.state.cold["in"] or _206_())
    elseif (nil ~= _202_) then
      local _in = _202_
      _201_ = _in
    else
    _201_ = nil
    end
  end
  if (nil ~= _201_) then
    local in1 = _201_
    local to_eol_3f = (in1 == "\13")
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _211_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _211_())
      local pattern
      if to_eol_3f then
        pattern = "\\n"
      else
        pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _213_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_214_ = _213_
        local line = _each_214_[1]
        local col = _each_214_[2]
        local pos = _each_214_
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
        local op_mode_3f_4_auto = string.match(mode, "o")
        local motion_force_5_auto = get_motion_force(mode)
        local restore_virtualedit_autocmd_6_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if not instant_repeat_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(jump_pos)
        if t_mode_3f0 then
          local function _220_()
            if reverse_3f0 then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_220_())
          if (to_eol_3f and not reverse_3f0 and mode:match("n")) then
            push_cursor_21("fwd")
          end
        end
        local adjusted_pos_7_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and true) then
            local _223_ = motion_force_5_auto
            if (_223_ == "v") then
              push_cursor_21("bwd")
            elseif (_223_ == nil) then
              if not cursor_before_eof_3f() then
                push_cursor_21("fwd")
              else
                vim.cmd("set virtualedit=onemore")
                vim.cmd("norm! l")
                vim.cmd(restore_virtualedit_autocmd_6_auto)
              end
            end
          end
        end
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
        local _230_
        local function _231_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _232_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _230_ = (_231_() or _232_())
        if (nil ~= _230_) then
          local in2 = _230_
          local stack
          local function _234_()
            local t_233_ = instant_state
            if (nil ~= t_233_) then
              t_233_ = (t_233_).stack
            end
            return t_233_
          end
          stack = (_234_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _237_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_237_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = false, stack = stack})
          elseif (_237_ == "revert") then
            do
              local _238_ = table.remove(stack)
              if _238_ then
                vim.fn.cursor(_238_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = true, stack = stack})
          else
            local _ = _237_
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
  local function _245_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _245_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_247_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_247_[1]
  local right_bound = _let_247_[2]
  local _let_248_ = get_cursor_pos()
  local curline = _let_248_[1]
  local curcol = _let_248_[2]
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
        local _252_
        do
          local _251_ = unique_chars[ch]
          if (nil ~= _251_) then
            local pos_already_there = _251_
            _252_ = false
          else
            local _ = _251_
            _252_ = {lnum, col}
          end
        end
        unique_chars[ch] = _252_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _257_ = pos
    if ((type(_257_) == "table") and (nil ~= (_257_)[1]) and (nil ~= (_257_)[2])) then
      local lnum = (_257_)[1]
      local col = (_257_)[2]
      hl["add-hl"](hl, hl.group["unique-ch"], dec(lnum), dec(col), col)
    end
  end
  return nil
end
local function get_targets(ch1, reverse_3f)
  local targets = {}
  local to_eol_3f = (ch1 == "\13")
  local prev_match = {}
  local added_prev_match_3f = nil
  local pattern
  if to_eol_3f then
    pattern = "\\n"
  else
    pattern = ("\\V\\C" .. ch1:gsub("\\", "\\\\") .. "\\_.")
  end
  for _260_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f}) do
    local _each_261_ = _260_
    local line = _each_261_[1]
    local col = _each_261_[2]
    local pos = _each_261_
    if to_eol_3f then
      table.insert(targets, {pair = {"\n", ""}, pos = pos})
    else
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _262_
      if reverse_3f then
        _262_ = dec
      else
        _262_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _262_(prev_match.col)))
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
          local _264_ = prev_target
          if ((type(_264_) == "table") and ((type((_264_).pos) == "table") and (nil ~= ((_264_).pos)[1]) and (nil ~= ((_264_).pos)[2]))) then
            local prev_line = ((_264_).pos)[1]
            local prev_col = ((_264_).pos)[2]
            local function _266_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta <= match_width)
            end
            touches_prev_target_3f = ((line == prev_line) and _266_())
          else
          touches_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        end
        if touches_prev_target_3f then
          local _269_
          if reverse_3f then
            _269_ = target
          else
            _269_ = prev_target
          end
          _269_["squeezed?"] = true
        end
        if overlaps_prev_target_3f then
          local _272_
          if reverse_3f then
            _272_ = prev_target
          else
            _272_ = target
          end
          _272_["overlapped?"] = true
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
  for _, _278_ in ipairs(targets) do
    local _each_279_ = _278_
    local target = _each_279_
    local _each_280_ = _each_279_["pair"]
    local _0 = _each_280_[1]
    local ch2 = _each_280_[2]
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
    local _285_ = sublist["autojump?"]
    if (_285_ == true) then
      return opts.safe_labels
    elseif (_285_ == false) then
      return opts.labels
    elseif (_285_ == nil) then
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
        local _288_
        if not (sublist["autojump?"] and (i == 1)) then
          local _289_
          local _291_
          if sublist["autojump?"] then
            _291_ = dec(i)
          else
            _291_ = i
          end
          _289_ = (_291_ % #labels)
          if (_289_ == 0) then
            _288_ = last(labels)
          elseif (nil ~= _289_) then
            local n = _289_
            _288_ = labels[n]
          else
          _288_ = nil
          end
        else
        _288_ = nil
        end
        target["label"] = _288_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _298_)
  local _arg_299_ = _298_
  local group_offset = _arg_299_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _300_
  if sublist["autojump?"] then
    _300_ = 2
  else
    _300_ = 1
  end
  primary_start = (offset + _300_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _302_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _302_ = "inactive"
      elseif (i <= primary_end) then
        _302_ = "active-primary"
      else
        _302_ = "active-secondary"
      end
    else
    _302_ = nil
    end
    target["label-state"] = _302_
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
      local _305_, _306_ = ch2, true
      if ((nil ~= _305_) and (nil ~= _306_)) then
        local k_10_auto = _305_
        local v_11_auto = _306_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _308_ in ipairs(targets) do
    local _each_309_ = _308_
    local target = _each_309_
    local label = _each_309_["label"]
    local label_state = _each_309_["label-state"]
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
local function set_beacon(_312_, _repeat)
  local _arg_313_ = _312_
  local target = _arg_313_
  local label = _arg_313_["label"]
  local label_state = _arg_313_["label-state"]
  local overlapped_3f = _arg_313_["overlapped?"]
  local _arg_314_ = _arg_313_["pair"]
  local ch1 = _arg_314_[1]
  local ch2 = _arg_314_[2]
  local _arg_315_ = _arg_313_["pos"]
  local _ = _arg_315_[1]
  local col = _arg_315_[2]
  local shortcut_3f = _arg_313_["shortcut?"]
  local squeezed_3f = _arg_313_["squeezed?"]
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local _let_316_ = get_horizontal_bounds({["match-width"] = 1})
  local left_bound = _let_316_[1]
  local right_bound = _let_316_[2]
  local function _318_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_317_ = map(_318_, {ch1, ch2})
  local ch10 = _let_317_[1]
  local ch20 = _let_317_[2]
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _319_ = label_state
    if (_319_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
        end
      else
      target.beacon = nil
      end
    elseif (_319_ == "active-primary") then
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
        local _323_
        if squeezed_3f then
          _323_ = 1
        else
          _323_ = 2
        end
        target.beacon = {_323_, {shortcut_24}}
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
    elseif (_319_ == "active-secondary") then
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
        local _329_
        if squeezed_3f then
          _329_ = 1
        else
          _329_ = 2
        end
        target.beacon = {_329_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_319_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _333_)
  local _arg_334_ = _333_
  local _repeat = _arg_334_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_335_ = target_list[i]
    local beacon = _let_335_["beacon"]
    local _let_336_ = _let_335_["pos"]
    local line = _let_336_[1]
    local col = _let_336_[2]
    local _337_ = beacon
    if ((type(_337_) == "table") and (nil ~= (_337_)[1]) and (nil ~= (_337_)[2]) and true) then
      local offset = (_337_)[1]
      local chunks = (_337_)[2]
      local _3fleft_off_3f = (_337_)[3]
      local _338_
      if _3fleft_off_3f then
        _338_ = 0
      else
      _338_ = nil
      end
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _338_})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _341_ in ipairs(target_list) do
    local _each_342_ = _341_
    local target = _each_342_
    local label = _each_342_["label"]
    local label_state = _each_342_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _344_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _344_) then
    local input = _344_
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
    local function _348_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _348_(self.state.cold["reverse?"])
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
      local _352_
      local function _353_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _354_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _352_ = (_353_() or _354_())
      if (_352_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _356_()
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
        return (self.state.cold.in1 or _356_())
      elseif (nil ~= _352_) then
        local _in = _352_
        return _in
      end
    end
  end
  local function update_state_2a(in1)
    local function _362_(_360_)
      local _arg_361_ = _360_
      local cold = _arg_361_["cold"]
      local dot = _arg_361_["dot"]
      if new_search_3f then
        if cold then
          local _363_ = cold
          _363_["in1"] = in1
          _363_["x-mode?"] = x_mode_3f0
          _363_["reverse?"] = reverse_3f0
          self.state.cold = _363_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _365_ = dot
              _365_["in1"] = in1
              _365_["x-mode?"] = x_mode_3f0
              self.state.dot = _365_
            end
            return nil
          end
        end
      end
    end
    return _362_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _369_(target, _3fto_pre_eol_3f)
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      do
        local op_mode_3f_4_auto = string.match(mode, "o")
        local motion_force_5_auto = get_motion_force(mode)
        local restore_virtualedit_autocmd_6_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if (first_jump_3f and not instant_repeat_3f) then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target)
        if to_eol_3f then
          if op_mode_3f then
            push_cursor_21("fwd")
          end
        elseif to_pre_eol_3f0 then
          if (op_mode_3f and x_mode_3f0) then
            push_cursor_21("fwd")
          end
        elseif x_mode_3f0 then
          push_cursor_21("fwd")
          if reverse_3f0 then
            push_cursor_21("fwd")
          end
        end
        local adjusted_pos_7_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and (x_mode_3f0 and not reverse_3f0)) then
            local _375_ = motion_force_5_auto
            if (_375_ == "v") then
              push_cursor_21("bwd")
            elseif (_375_ == nil) then
              if not cursor_before_eof_3f() then
                push_cursor_21("fwd")
              else
                vim.cmd("set virtualedit=onemore")
                vim.cmd("norm! l")
                vim.cmd(restore_virtualedit_autocmd_6_auto)
              end
            end
          end
        end
        adjusted_pos = adjusted_pos_7_auto
      end
      first_jump_3f = false
      return adjusted_pos
    end
    jump_to_21 = _369_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local motion_force = get_motion_force(mode)
    local blockwise_3f = (motion_force == _3cctrl_v_3e)
    local function _381_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_380_ = _381_()
    local startline = _let_380_[1]
    local startcol = _let_380_[2]
    local start = _let_380_
    local function _383_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_382_ = _383_()
    local _ = _let_382_[1]
    local endcol = _let_382_[2]
    local _end = _let_382_
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
    local _388_ = targets.sublists[ch]
    if (nil ~= _388_) then
      local sublist = _388_
      local _let_389_ = sublist
      local _let_390_ = _let_389_[1]
      local _let_391_ = _let_390_["pos"]
      local line = _let_391_[1]
      local col = _let_391_[2]
      local rest = {(table.unpack or unpack)(_let_389_, 2)}
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
      local _395_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _395_ = "cold"
      elseif instant_repeat_3f then
        _395_ = "instant"
      else
      _395_ = nil
      end
      set_beacons(sublist, {["repeat"] = _395_})
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
      local _398_
      do
        local res_2_auto
        do
          local function _399_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_399_())
        end
        hl:cleanup()
        _398_ = res_2_auto
      end
      if (nil ~= _398_) then
        local input = _398_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _401_
          do
            local _400_ = input
            if (_400_ == next_group_key) then
              _401_ = inc
            else
              local _ = _400_
              _401_ = dec
            end
          end
          group_offset_2a = clamp(_401_(group_offset), 0, max_offset)
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
  local _410_ = get_first_input()
  if (nil ~= _410_) then
    local in1 = _410_
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
    local _412_
    local function _414_()
      local t_413_ = instant_state
      if (nil ~= t_413_) then
        t_413_ = (t_413_).sublist
      end
      return t_413_
    end
    local function _416_()
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
    _412_ = (_414_() or get_targets(in1, reverse_3f0) or _416_())
    if ((type(_412_) == "table") and ((type((_412_)[1]) == "table") and ((type(((_412_)[1]).pair) == "table") and true and (nil ~= (((_412_)[1]).pair)[2]))) and ((_412_)[2] == nil)) then
      local only = (_412_)[1]
      local _0 = (((_412_)[1]).pair)[1]
      local ch2 = (((_412_)[1]).pair)[2]
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
    elseif (nil ~= _412_) then
      local targets = _412_
      if not instant_repeat_3f then
        local _422_ = targets
        populate_sublists(_422_)
        set_labels(_422_, to_eol_3f)
        set_label_states(_422_)
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _424_ = targets
          set_shortcuts_and_populate_shortcuts_map(_424_)
          set_beacons(_424_, {["repeat"] = nil})
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
      local _427_
      local function _428_()
        if to_eol_3f then
          return ""
        end
      end
      local function _429_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _430_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _427_ = (prev_in2 or _428_() or _429_() or _430_())
      if (nil ~= _427_) then
        local in2 = _427_
        local _432_
        do
          local t_433_ = targets.shortcuts
          if (nil ~= t_433_) then
            t_433_ = (t_433_)[in2]
          end
          _432_ = t_433_
        end
        if ((type(_432_) == "table") and ((type((_432_).pair) == "table") and true and (nil ~= ((_432_).pair)[2]))) then
          local shortcut = _432_
          local _0 = ((_432_).pair)[1]
          local ch2 = ((_432_).pair)[2]
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
          local _0 = _432_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _436_
          local function _438_()
            local t_437_ = instant_state
            if (nil ~= t_437_) then
              t_437_ = (t_437_).sublist
            end
            return t_437_
          end
          local function _440_()
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
          _436_ = (_438_() or get_sublist(targets, in2) or _440_())
          if ((type(_436_) == "table") and (nil ~= (_436_)[1]) and ((_436_)[2] == nil)) then
            local only = (_436_)[1]
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
          elseif ((type(_436_) == "table") and (nil ~= (_436_)[1])) then
            local first = (_436_)[1]
            local sublist = _436_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _444_()
              local t_443_ = instant_state
              if (nil ~= t_443_) then
                t_443_ = (t_443_).idx
              end
              return t_443_
            end
            local function _446_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_444_() or _446_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first.pos)
            end
            local _449_
            local function _450_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              end
            end
            local function _451_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _449_ = (_450_() or get_last_input(sublist, inc(curr_idx)) or _451_())
            if ((type(_449_) == "table") and (nil ~= (_449_)[1]) and (nil ~= (_449_)[2])) then
              local in3 = (_449_)[1]
              local group_offset = (_449_)[2]
              local _453_
              if not op_mode_3f then
                _453_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
              _453_ = nil
              end
              if (nil ~= _453_) then
                local action = _453_
                local idx
                do
                  local _455_ = action
                  if (_455_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_455_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                  idx = nil
                  end
                end
                jump_to_21(sublist[idx].pos)
                return sx:go(reverse_3f0, x_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, idx = idx, in1 = in1, in2 = in2, sublist = sublist})
              else
                local _1 = _453_
                local _457_ = get_target_with_active_primary_label(sublist, in3)
                if (nil ~= _457_) then
                  local target = _457_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _459_
                    if (group_offset > 0) then
                      _459_ = nil
                    else
                      _459_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _459_}})
                    jump_to_21(target.pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _2 = _457_
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
    local _let_472_ = vim.split(opt, ".", true)
    local _0 = _let_472_[1]
    local scope = _let_472_[2]
    local name = _let_472_[3]
    local _473_
    if (opt == "vim.wo.scrolloff") then
      _473_ = api.nvim_eval("&l:scrolloff")
    else
      _473_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _473_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_475_ = vim.split(opt, ".", true)
    local _ = _let_475_[1]
    local scope = _let_475_[2]
    local name = _let_475_[3]
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
  for _, _476_ in ipairs(plug_keys) do
    local _each_477_ = _476_
    local lhs = _each_477_[1]
    local rhs_call = _each_477_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _478_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_479_ = _478_
    local lhs = _each_479_[1]
    local rhs_call = _each_479_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _480_ in ipairs(default_keymaps) do
    local _each_481_ = _480_
    local mode = _each_481_[1]
    local lhs = _each_481_[2]
    local rhs = _each_481_[3]
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
