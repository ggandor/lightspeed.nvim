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
  local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  local labels = {"s", "f", "n", "j", "k", "l", "o", "i", "w", "e", "h", "g", "u", "t", "m", "v", "c", "a", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
  opts = {cycle_group_bwd_key = "<tab>", cycle_group_fwd_key = "<space>", exit_after_idle_msecs = {labeled = nil, unlabeled = 1000}, grey_out_search_area = true, highlight_unique_chars = true, jump_on_partial_input_safety_timeout = 400, labels = labels, limit_ft_matches = 4, match_only_the_start_of_same_char_seqs = true, repeat_ft_with_target_char = false, safe_labels = safe_labels, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
end
local deprecated_opts = {"instant_repeat_fwd_key", "instant_repeat_bwd_key"}
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
  local spec_messages = {instant_repeat_bwd_key = msg_for_instant_repeat_keys, instant_repeat_fwd_key = msg_for_instant_repeat_keys}
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
  local function _16_(t, k)
    if contains_3f(deprecated_opts, k) then
      return api.nvim_echo(get_deprec_msg({k}), true, {})
    end
  end
  guard = _16_
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
local function _20_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _21_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _22_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _20_, ["set-extmark"] = _21_, cleanup = _22_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _24_
  do
    local _23_ = bg
    if (_23_ == "light") then
      _24_ = "#f02077"
    else
      local _ = _23_
      _24_ = "#ff2f87"
    end
  end
  local _29_
  do
    local _28_ = bg
    if (_28_ == "light") then
      _29_ = "#ff4090"
    else
      local _ = _28_
      _29_ = "#e01067"
    end
  end
  local _34_
  do
    local _33_ = bg
    if (_33_ == "light") then
      _34_ = "Blue"
    else
      local _ = _33_
      _34_ = "Cyan"
    end
  end
  local _39_
  do
    local _38_ = bg
    if (_38_ == "light") then
      _39_ = "#399d9f"
    else
      local _ = _38_
      _39_ = "#99ddff"
    end
  end
  local _44_
  do
    local _43_ = bg
    if (_43_ == "light") then
      _44_ = "Cyan"
    else
      local _ = _43_
      _44_ = "Blue"
    end
  end
  local _49_
  do
    local _48_ = bg
    if (_48_ == "light") then
      _49_ = "#59bdbf"
    else
      local _ = _48_
      _49_ = "#79bddf"
    end
  end
  local _54_
  do
    local _53_ = bg
    if (_53_ == "light") then
      _54_ = "#cc9999"
    else
      local _ = _53_
      _54_ = "#b38080"
    end
  end
  local _59_
  do
    local _58_ = bg
    if (_58_ == "light") then
      _59_ = "Black"
    else
      local _ = _58_
      _59_ = "White"
    end
  end
  local _64_
  do
    local _63_ = bg
    if (_63_ == "light") then
      _64_ = "#272020"
    else
      local _ = _63_
      _64_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _24_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _29_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _34_, gui = "bold,underline", guibg = "NONE", guifg = _39_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _44_, gui = "underline", guifg = _49_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _54_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _59_, gui = "bold", guibg = "NONE", guifg = _64_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _68_ in ipairs(groupdefs) do
    local _each_69_ = _68_
    local group = _each_69_[1]
    local attrs = _each_69_[2]
    local attrs_str
    local _70_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _70_ = tbl_12_auto
    end
    attrs_str = table.concat(_70_, " ")
    local _71_
    if force_3f then
      _71_ = ""
    else
      _71_ = "default "
    end
    vim.cmd(("highlight " .. _71_ .. group .. " " .. attrs_str))
  end
  for _, _73_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_74_ = _73_
    local from_group = _each_74_[1]
    local to_group = _each_74_[2]
    local _75_
    if force_3f then
      _75_ = ""
    else
      _75_ = "default "
    end
    vim.cmd(("highlight " .. _75_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_77_ = map(dec, get_cursor_pos())
  local curline = _let_77_[1]
  local curcol = _let_77_[2]
  local _let_78_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_78_[1]
  local win_bot = _let_78_[2]
  local function _80_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_79_ = _80_()
  local start = _let_79_[1]
  local finish = _let_79_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _81_, _83_, _85_)
  local _arg_82_ = _81_
  local startline = _arg_82_[1]
  local startcol = _arg_82_[2]
  local start = _arg_82_
  local _arg_84_ = _83_
  local endline = _arg_84_[1]
  local endcol = _arg_84_[2]
  local _end = _arg_84_
  local _arg_86_ = _85_
  local forced_motion = _arg_86_["forced-motion"]
  local inclusive_motion_3f = _arg_86_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _87_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _87_
  local _88_ = forced_motion
  if (_88_ == ctrl_v) then
    local _let_89_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_89_[1]
    local endcol0 = _let_89_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_88_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_88_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _88_
    return hl_range(start, _end, inclusive_motion_3f)
  end
end
local _3cbackspace_3e = replace_keycodes("<bs>")
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local function _92_()
    local _91_ = direction
    if (_91_ == "fwd") then
      return "W"
    elseif (_91_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _92_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_onscreen_lines(_94_)
  local _arg_95_ = _94_
  local reverse_3f = _arg_95_["reverse?"]
  local skip_folds_3f = _arg_95_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _96_
    if reverse_3f then
      _96_ = (lnum >= wintop)
    else
      _96_ = (lnum <= winbot)
    end
    if not _96_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _98_
      if reverse_3f then
        _98_ = dec
      else
        _98_ = inc
      end
      lnum = _98_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _100_
      if reverse_3f then
        _100_ = dec
      else
        _100_ = inc
      end
      lnum = _100_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_103_)
  local _arg_104_ = _103_
  local match_width = _arg_104_["match-width"]
  local gutter_width = dec(leftmost_editable_wincol())
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - gutter_width)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - gutter_width)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _105_)
  local _arg_106_ = _105_
  local ft_search_3f = _arg_106_["ft-search?"]
  local limit = _arg_106_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _108_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_108_())
  local cleanup
  local function _109_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _109_
  local _111_
  if ft_search_3f then
    _111_ = 1
  else
    _111_ = 2
  end
  local _let_110_ = get_horizontal_bounds({["match-width"] = _111_})
  local left_bound = _let_110_[1]
  local right_bound = _let_110_[2]
  local function skip_to_fold_edge_21()
    local _113_
    local _114_
    if reverse_3f then
      _114_ = vim.fn.foldclosed
    else
      _114_ = vim.fn.foldclosedend
    end
    _113_ = _114_(vim.fn.line("."))
    if (_113_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _113_) then
      local fold_edge = _113_
      vim.fn.cursor(fold_edge, 0)
      local function _116_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _116_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_118_ = get_cursor_pos()
    local line = _local_118_[1]
    local col = _local_118_[2]
    local from_pos = _local_118_
    local _119_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _119_ = {dec(line), right_bound}
        else
        _119_ = nil
        end
      else
        _119_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _119_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _119_ = {inc(line), left_bound}
        else
        _119_ = nil
        end
      end
    else
    _119_ = nil
    end
    if (nil ~= _119_) then
      local to_pos = _119_
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
      local _127_
      local _128_
      if match_at_curpos_3f then
        _128_ = "c"
      else
        _128_ = ""
      end
      _127_ = vim.fn.searchpos(pattern, (opts0 .. _128_), stopline)
      if ((type(_127_) == "table") and ((_127_)[1] == 0) and true) then
        local _ = (_127_)[2]
        return cleanup()
      elseif ((type(_127_) == "table") and (nil ~= (_127_)[1]) and (nil ~= (_127_)[2])) then
        local line = (_127_)[1]
        local col = (_127_)[2]
        local pos = _127_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _130_ = skip_to_fold_edge_21()
          if (_130_ == "moved-the-cursor") then
            return recur(false)
          elseif (_130_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_131_,_132_,_133_) return (_131_ <= _132_) and (_132_ <= _133_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _134_ = skip_to_next_in_window_pos_21()
              if (_134_ == "moved-the-cursor") then
                return recur(true)
              else
                local _ = _134_
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
  local _let_141_ = (_3fpos or get_cursor_pos())
  local line = _let_141_[1]
  local col = _let_141_[2]
  local pos = _let_141_
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
  local _144_ = mode
  if (_144_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_144_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _146_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _146_
  local getchar_timeout
  local function _147_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    end
  end
  getchar_timeout = _147_
  local ok_3f, ch = nil, nil
  local function _149_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_149_())
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
  local _156_
  do
    local _155_ = repeat_invoc
    if (_155_ == "dot") then
      _156_ = "dotrepeat_"
    else
      local _ = _155_
      _156_ = ""
    end
  end
  local _161_
  do
    local _160_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_160_) == "table") and ((_160_)[1] == "ft") and ((_160_)[2] == false) and ((_160_)[3] == false)) then
      _161_ = "f"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "ft") and ((_160_)[2] == true) and ((_160_)[3] == false)) then
      _161_ = "F"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "ft") and ((_160_)[2] == false) and ((_160_)[3] == true)) then
      _161_ = "t"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "ft") and ((_160_)[2] == true) and ((_160_)[3] == true)) then
      _161_ = "T"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "sx") and ((_160_)[2] == false) and ((_160_)[3] == false)) then
      _161_ = "s"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "sx") and ((_160_)[2] == true) and ((_160_)[3] == false)) then
      _161_ = "S"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "sx") and ((_160_)[2] == false) and ((_160_)[3] == true)) then
      _161_ = "x"
    elseif ((type(_160_) == "table") and ((_160_)[1] == "sx") and ((_160_)[2] == true) and ((_160_)[3] == true)) then
      _161_ = "X"
    else
    _161_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _156_ .. _161_)
end
local ft = {state = {cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}, dot = {["in"] = nil}}}
ft.go = function(self, reverse_3f, t_mode_3f, repeat_invoc)
  local op_mode_3f = operator_pending_mode_3f()
  local instant_repeat_3f = (type(repeat_invoc) == "table")
  local instant_state
  if instant_repeat_3f then
    instant_state = repeat_invoc
  else
  instant_state = nil
  end
  local reverted_instant_repeat_3f
  do
    local t_172_ = instant_state
    if (nil ~= t_172_) then
      t_172_ = (t_172_)["reverted?"]
    end
    reverted_instant_repeat_3f = t_172_
  end
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local invoked_as_reverse_3f = reverse_3f
  local reverse_3f0
  if cold_repeat_3f then
    local function _174_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _174_(self.state.cold["reverse?"])
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
  local function get_num_of_matches_to_be_highlighted(_3finstant_state)
    local stack_size
    if _3finstant_state then
      stack_size = #instant_state.stack
    else
      stack_size = 0
    end
    local group_limit = (opts.limit_ft_matches or 0)
    local eaten_up
    if (group_limit == 0) then
      eaten_up = 0
    else
      eaten_up = (stack_size % group_limit)
    end
    local remaining = (group_limit - eaten_up)
    if (remaining == 0) then
      return group_limit
    else
      return remaining
    end
  end
  local function get_followup_action(_in, from_reverse_cold_repeat_3f, target_char)
    local mode
    if (vim.fn.mode() == "n") then
      mode = "n"
    else
      mode = "x"
    end
    local rhs = vim.fn.maparg(_in, mode)
    local ok_3f, eval_rhs = pcall(vim.fn.eval, rhs)
    local in_mapped_to
    if (ok_3f and (type(eval_rhs) == "string")) then
      in_mapped_to = eval_rhs
    else
      in_mapped_to = rhs
    end
    local function _185_()
      if opts.repeat_ft_with_target_char then
        return (_in == target_char)
      end
    end
    local function _186_()
      if from_reverse_cold_repeat_3f then
        return "<Plug>Lightspeed_,_ft"
      else
        return "<Plug>Lightspeed_;_ft"
      end
    end
    if (_185_() or (_in == _3cbackspace_3e) or (in_mapped_to == get_plug_key("ft", false, t_mode_3f0)) or string.find(in_mapped_to, _186_())) then
      return "repeat"
    else
      local _187_
      if instant_repeat_3f then
        local function _188_()
          if from_reverse_cold_repeat_3f then
            return "<Plug>Lightspeed_;_ft"
          else
            return "<Plug>Lightspeed_,_ft"
          end
        end
        _187_ = ((_in == "\9") or (in_mapped_to == get_plug_key("ft", true, t_mode_3f0)) or string.find(in_mapped_to, _188_()))
      else
      _187_ = nil
      end
      if _187_ then
        return "revert"
      end
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
  local _193_
  if instant_repeat_3f then
    _193_ = instant_state["in"]
  elseif dot_repeat_3f then
    _193_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _193_ = self.state.cold["in"]
  else
    local _194_
    local function _195_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup()
      return res_2_auto
    end
    local function _196_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _194_ = (_195_() or _196_())
    if (_194_ == _3cbackspace_3e) then
      local function _198_()
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
      _193_ = (self.state.cold["in"] or _198_())
    elseif (nil ~= _194_) then
      local _in = _194_
      _193_ = _in
    else
    _193_ = nil
    end
  end
  if (nil ~= _193_) then
    local in1 = _193_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f0, ["t-mode?"] = t_mode_3f0}
    end
    local jump_pos = nil
    local match_count = 0
    do
      local next_pos
      local function _203_()
        if reverse_3f0 then
          return "nWb"
        else
          return "nW"
        end
      end
      next_pos = vim.fn.searchpos("\\_.", _203_())
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit = (count0 + get_num_of_matches_to_be_highlighted(instant_state))
      for _204_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_205_ = _204_
        local line = _each_205_[1]
        local col = _each_205_[2]
        local pos = _each_205_
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
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if not instant_repeat_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(jump_pos)
        if t_mode_3f0 then
          local function _211_()
            if reverse_3f0 then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_211_())
        end
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and true) then
            local _213_ = string.sub(vim.fn.mode("t"), -1)
            if (_213_ == "v") then
              push_cursor_21("bwd")
            elseif (_213_ == "o") then
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
          if dot_repeatable_operation_3f() then
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
        local _220_
        local function _221_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _222_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _220_ = (_221_() or _222_())
        if (nil ~= _220_) then
          local in2 = _220_
          local stack
          local function _224_()
            local t_223_ = instant_state
            if (nil ~= t_223_) then
              t_223_ = (t_223_).stack
            end
            return t_223_
          end
          stack = (_224_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _227_ = get_followup_action(in2, from_reverse_cold_repeat_3f, in1)
          if (_227_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = false, stack = stack})
          elseif (_227_ == "revert") then
            do
              local _228_ = table.remove(stack)
              if _228_ then
                vim.fn.cursor(_228_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = true, stack = stack})
          else
            local _ = _227_
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
  local function _235_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _235_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_237_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_237_[1]
  local right_bound = _let_237_[2]
  local _let_238_ = get_cursor_pos()
  local curline = _let_238_[1]
  local curcol = _let_238_[2]
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
        local _242_
        do
          local _241_ = unique_chars[ch]
          if (nil ~= _241_) then
            local pos_already_there = _241_
            _242_ = false
          else
            local _ = _241_
            _242_ = {lnum, col}
          end
        end
        unique_chars[ch] = _242_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _247_ = pos
    if ((type(_247_) == "table") and (nil ~= (_247_)[1]) and (nil ~= (_247_)[2])) then
      local lnum = (_247_)[1]
      local col = (_247_)[2]
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
  for _249_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_250_ = _249_
    local line = _each_250_[1]
    local col = _each_250_[2]
    local pos = _each_250_
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local before_eol_3f = (ch2 == "\13")
    local overlaps_prev_match_3f
    local _251_
    if reverse_3f then
      _251_ = dec
    else
      _251_ = inc
    end
    overlaps_prev_match_3f = ((line == prev_match.line) and (col == _251_(prev_match.col)))
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
        local _253_ = prev_target
        if ((type(_253_) == "table") and ((type((_253_).pos) == "table") and (nil ~= ((_253_).pos)[1]) and (nil ~= ((_253_).pos)[2]))) then
          local prev_line = ((_253_).pos)[1]
          local prev_col = ((_253_).pos)[2]
          local function _255_()
            local col_delta
            if reverse_3f then
              col_delta = (prev_col - col)
            else
              col_delta = (col - prev_col)
            end
            return (col_delta <= match_width)
          end
          touches_prev_target_3f = ((line == prev_line) and _255_())
        else
        touches_prev_target_3f = nil
        end
      end
      if before_eol_3f then
        target["squeezed?"] = true
      end
      if touches_prev_target_3f then
        local _258_
        if reverse_3f then
          _258_ = target
        else
          _258_ = prev_target
        end
        _258_["squeezed?"] = true
      end
      if overlaps_prev_target_3f then
        local _261_
        if reverse_3f then
          _261_ = prev_target
        else
          _261_ = target
        end
        _261_["overlapped?"] = true
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
  for _, _266_ in ipairs(targets) do
    local _each_267_ = _266_
    local target = _each_267_
    local _each_268_ = _each_267_["pair"]
    local _0 = _each_268_[1]
    local ch2 = _each_268_[2]
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
    local _272_ = sublist["autojump?"]
    if (_272_ == true) then
      return opts.safe_labels
    elseif (_272_ == false) then
      return opts.labels
    elseif (_272_ == nil) then
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
        local _275_
        if not (sublist["autojump?"] and (i == 1)) then
          local _276_
          local _278_
          if sublist["autojump?"] then
            _278_ = dec(i)
          else
            _278_ = i
          end
          _276_ = (_278_ % #labels)
          if (_276_ == 0) then
            _275_ = last(labels)
          elseif (nil ~= _276_) then
            local n = _276_
            _275_ = labels[n]
          else
          _275_ = nil
          end
        else
        _275_ = nil
        end
        target["label"] = _275_
      end
    end
  end
  return nil
end
local function set_label_states_for_sublist(sublist, _285_)
  local _arg_286_ = _285_
  local group_offset = _arg_286_["group-offset"]
  local labels = get_labels(sublist)
  local _7clabels_7c = #labels
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _287_
  if sublist["autojump?"] then
    _287_ = 2
  else
    _287_ = 1
  end
  primary_start = (offset + _287_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _289_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _289_ = "inactive"
      elseif (i <= primary_end) then
        _289_ = "active-primary"
      else
        _289_ = "active-secondary"
      end
    else
    _289_ = nil
    end
    target["label-state"] = _289_
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
      local _292_, _293_ = ch2, true
      if ((nil ~= _292_) and (nil ~= _293_)) then
        local k_10_auto = _292_
        local v_11_auto = _293_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _295_ in ipairs(targets) do
    local _each_296_ = _295_
    local target = _each_296_
    local label = _each_296_["label"]
    local label_state = _each_296_["label-state"]
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
local function set_beacon(_299_, _repeat)
  local _arg_300_ = _299_
  local target = _arg_300_
  local label = _arg_300_["label"]
  local label_state = _arg_300_["label-state"]
  local overlapped_3f = _arg_300_["overlapped?"]
  local _arg_301_ = _arg_300_["pair"]
  local ch1 = _arg_301_[1]
  local ch2 = _arg_301_[2]
  local _arg_302_ = _arg_300_["pos"]
  local _ = _arg_302_[1]
  local col = _arg_302_[2]
  local shortcut_3f = _arg_300_["shortcut?"]
  local squeezed_3f = _arg_300_["squeezed?"]
  local function _304_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_303_ = map(_304_, {ch1, ch2})
  local ch10 = _let_303_[1]
  local ch20 = _let_303_[2]
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _305_ = label_state
    if (_305_ == nil) then
      if not _repeat then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
        end
      else
      target.beacon = nil
      end
    elseif (_305_ == "active-primary") then
      if _repeat then
        local _308_
        if squeezed_3f then
          _308_ = 1
        else
          _308_ = 2
        end
        target.beacon = {_308_, {shortcut_24}}
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
    elseif (_305_ == "active-secondary") then
      if _repeat then
        local _313_
        if squeezed_3f then
          _313_ = 1
        else
          _313_ = 2
        end
        target.beacon = {_313_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_305_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _317_)
  local _arg_318_ = _317_
  local _repeat = _arg_318_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_319_ = target_list[i]
    local beacon = _let_319_["beacon"]
    local _let_320_ = _let_319_["pos"]
    local line = _let_320_[1]
    local col = _let_320_[2]
    local _321_ = beacon
    if ((type(_321_) == "table") and (nil ~= (_321_)[1]) and (nil ~= (_321_)[2])) then
      local offset = (_321_)[1]
      local chunks = (_321_)[2]
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _323_ in ipairs(target_list) do
    local _each_324_ = _323_
    local target = _each_324_
    local label = _each_324_["label"]
    local label_state = _each_324_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _326_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _326_) then
    local input = _326_
    if (input ~= char_to_ignore) then
      return vim.fn.feedkeys(input, "i")
    end
  end
end
local sx = {state = {cold = {["reverse?"] = nil, ["x-mode?"] = nil, in1 = nil, in2 = nil}, dot = {["x-mode?"] = nil, in1 = nil, in2 = nil, in3 = nil}}}
sx.go = function(self, reverse_3f, invoked_in_x_mode_3f, repeat_invoc)
  local op_mode_3f = operator_pending_mode_3f()
  local change_op_3f = change_operation_3f()
  local delete_op_3f = delete_operation_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
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
    local function _330_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _330_(self.state.cold["reverse?"])
  else
    reverse_3f0 = reverse_3f
  end
  local x_mode_3f
  if cold_repeat_3f then
    x_mode_3f = self.state.cold["x-mode?"]
  else
    x_mode_3f = invoked_in_x_mode_3f
  end
  local x_mode_3f0 = x_mode_3f
  local backspace_repeat_3f = nil
  local new_search_3f = nil
  local function get_first_input()
    if instant_repeat_3f then
      return instant_state.in1
    elseif dot_repeat_3f then
      x_mode_3f0 = self.state.dot["x-mode?"]
      return self.state.dot.in1
    elseif cold_repeat_3f then
      return self.state.cold.in1
    else
      local _334_
      local function _335_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _336_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _334_ = (_335_() or _336_())
      if (nil ~= _334_) then
        local in0 = _334_
        local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
        do
          local _338_ = in0
          if (_338_ == _3cbackspace_3e) then
            backspace_repeat_3f = true
          elseif (_338_ == x_mode_prefix_key) then
            x_mode_3f0 = true
          end
        end
        local res = in0
        if (x_mode_3f0 and not invoked_in_x_mode_3f) then
          local _340_
          local function _341_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
            end
            doau_when_exists("LightspeedSxLeave")
            doau_when_exists("LightspeedLeave")
            return nil
          end
          _340_ = (get_input() or _341_())
          if (_340_ == _3cbackspace_3e) then
            backspace_repeat_3f = true
          elseif (nil ~= _340_) then
            local in0_2a = _340_
            res = in0_2a
          end
        end
        new_search_3f = not (repeat_invoc or backspace_repeat_3f)
        if backspace_repeat_3f then
          local function _345_()
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
          return (self.state.cold.in1 or _345_())
        else
          return res
        end
      end
    end
  end
  local function update_state_2a(in1)
    local function _352_(_350_)
      local _arg_351_ = _350_
      local cold = _arg_351_["cold"]
      local dot = _arg_351_["dot"]
      if new_search_3f then
        if cold then
          local _353_ = cold
          _353_["in1"] = in1
          _353_["x-mode?"] = x_mode_3f0
          _353_["reverse?"] = reverse_3f0
          self.state.cold = _353_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _355_ = dot
              _355_["in1"] = in1
              _355_["x-mode?"] = x_mode_3f0
              self.state.dot = _355_
            end
            return nil
          end
        end
      end
    end
    return _352_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _359_(target)
      local adjusted_pos
      do
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if (first_jump_3f and not instant_repeat_3f) then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target)
        if x_mode_3f0 then
          push_cursor_21("fwd")
          if reverse_3f0 then
            push_cursor_21("fwd")
          end
        end
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and (x_mode_3f0 and not reverse_3f0)) then
            local _363_ = string.sub(vim.fn.mode("t"), -1)
            if (_363_ == "v") then
              push_cursor_21("bwd")
            elseif (_363_ == "o") then
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
    jump_to_21 = _359_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local forced_motion = string.sub(vim.fn.mode("t"), -1)
    local blockwise_3f = (forced_motion == replace_keycodes("<c-v>"))
    local function _369_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_368_ = _369_()
    local startline = _let_368_[1]
    local startcol = _let_368_[2]
    local start = _let_368_
    local function _371_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_370_ = _371_()
    local _ = _let_370_[1]
    local endcol = _let_370_[2]
    local _end = _let_370_
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
      highlight_range(hl.group["pending-op-area"], map(dec, start), map(dec, _end), {["forced-motion"] = forced_motion, ["inclusive-motion?"] = (x_mode_3f0 and not reverse_3f0)})
    end
    return vim.cmd("redraw")
  end
  local function get_sublist(targets, ch)
    local _376_ = targets.sublists[ch]
    if (nil ~= _376_) then
      local sublist = _376_
      local _let_377_ = sublist
      local _let_378_ = _let_377_[1]
      local _let_379_ = _let_378_["pos"]
      local line = _let_379_[1]
      local col = _let_379_[2]
      local rest = {(table.unpack or unpack)(_let_377_, 2)}
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
  local function get_followup_action(_in, from_reverse_cold_repeat_3f)
    local mode
    if (vim.fn.mode() == "n") then
      mode = "n"
    else
      mode = "x"
    end
    local rhs = vim.fn.maparg(_in, mode)
    local ok_3f, eval_rhs = pcall(vim.fn.eval, rhs)
    local in_mapped_to
    if (ok_3f and (type(eval_rhs) == "string")) then
      in_mapped_to = eval_rhs
    else
      in_mapped_to = rhs
    end
    local function _385_()
      if from_reverse_cold_repeat_3f then
        return "<Plug>Lightspeed_,_sx"
      else
        return "<Plug>Lightspeed_;_sx"
      end
    end
    if ((_in == _3cbackspace_3e) or (in_mapped_to == get_plug_key("sx", false, x_mode_3f0)) or string.find(in_mapped_to, _385_())) then
      return "repeat"
    else
      local _386_
      if instant_repeat_3f then
        local function _387_()
          if from_reverse_cold_repeat_3f then
            return "<Plug>Lightspeed_;_sx"
          else
            return "<Plug>Lightspeed_,_sx"
          end
        end
        _386_ = ((_in == "\9") or (in_mapped_to == get_plug_key("sx", true, x_mode_3f0)) or string.find(in_mapped_to, _387_()))
      else
      _386_ = nil
      end
      if _386_ then
        return "revert"
      end
    end
  end
  local function get_last_input(sublist, start_idx)
    local next_group_key = replace_keycodes(opts.cycle_group_fwd_key)
    local prev_group_key = replace_keycodes(opts.cycle_group_bwd_key)
    local function recur(group_offset, initial_invoc_3f)
      local _390_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _390_ = "cold"
      elseif instant_repeat_3f then
        _390_ = "instant"
      else
      _390_ = nil
      end
      set_beacons(sublist, {["repeat"] = _390_})
      do
        if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f)) then
          grey_out_search_area(reverse_3f0)
        end
        do
          light_up_beacons(sublist, start_idx)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _393_
      do
        local res_2_auto
        do
          local function _394_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_394_())
        end
        hl:cleanup()
        _393_ = res_2_auto
      end
      if (nil ~= _393_) then
        local input = _393_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _396_
          do
            local _395_ = input
            if (_395_ == next_group_key) then
              _396_ = inc
            else
              local _ = _395_
              _396_ = dec
            end
          end
          group_offset_2a = clamp(_396_(group_offset), 0, max_offset)
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
    if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f)) then
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
  local _405_ = get_first_input()
  if (nil ~= _405_) then
    local in1 = _405_
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
    local _407_
    local function _409_()
      local t_408_ = instant_state
      if (nil ~= t_408_) then
        t_408_ = (t_408_).sublist
      end
      return t_408_
    end
    local function _411_()
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
    _407_ = (_409_() or get_targets(in1, reverse_3f0) or _411_())
    if ((type(_407_) == "table") and ((type((_407_)[1]) == "table") and ((type(((_407_)[1]).pair) == "table") and true and (nil ~= (((_407_)[1]).pair)[2]))) and ((_407_)[2] == nil)) then
      local _ = (((_407_)[1]).pair)[1]
      local ch2 = (((_407_)[1]).pair)[2]
      local only = (_407_)[1]
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
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
    elseif (nil ~= _407_) then
      local targets = _407_
      if not instant_repeat_3f then
        local _417_ = targets
        populate_sublists(_417_)
        set_labels(_417_)
        set_label_states(_417_)
      end
      if new_search_3f then
        do
          local _419_ = targets
          set_shortcuts_and_populate_shortcuts_map(_419_)
          set_beacons(_419_, {["repeat"] = nil})
        end
        if (opts.grey_out_search_area and not (cold_repeat_3f or instant_repeat_3f)) then
          grey_out_search_area(reverse_3f0)
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _422_
      local function _423_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _424_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _422_ = (prev_in2 or _423_() or _424_())
      if (nil ~= _422_) then
        local in2 = _422_
        local _426_
        do
          local t_427_ = targets.shortcuts
          if (nil ~= t_427_) then
            t_427_ = (t_427_)[in2]
          end
          _426_ = t_427_
        end
        if ((type(_426_) == "table") and ((type((_426_).pair) == "table") and true and (nil ~= ((_426_).pair)[2]))) then
          local _ = ((_426_).pair)[1]
          local ch2 = ((_426_).pair)[2]
          local shortcut = _426_
          do
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
            end
            update_state({cold = {in2 = ch2}, dot = {in2 = ch2, in3 = in2}})
            jump_to_21(shortcut.pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _426_
          update_state({cold = {in2 = in2}})
          local _430_
          local function _432_()
            local t_431_ = instant_state
            if (nil ~= t_431_) then
              t_431_ = (t_431_).sublist
            end
            return t_431_
          end
          local function _434_()
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
          _430_ = (_432_() or get_sublist(targets, in2) or _434_())
          if ((type(_430_) == "table") and (nil ~= (_430_)[1]) and ((_430_)[2] == nil)) then
            local only = (_430_)[1]
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
          elseif ((type(_430_) == "table") and (nil ~= (_430_)[1])) then
            local first = (_430_)[1]
            local sublist = _430_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _438_()
              local t_437_ = instant_state
              if (nil ~= t_437_) then
                t_437_ = (t_437_).idx
              end
              return t_437_
            end
            local function _440_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_438_() or _440_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first.pos)
            end
            local _443_
            local function _444_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              end
            end
            local function _445_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _443_ = (_444_() or get_last_input(sublist, inc(curr_idx)) or _445_())
            if ((type(_443_) == "table") and (nil ~= (_443_)[1]) and (nil ~= (_443_)[2])) then
              local in3 = (_443_)[1]
              local group_offset = (_443_)[2]
              local _447_
              if not op_mode_3f then
                _447_ = get_followup_action(in3, from_reverse_cold_repeat_3f)
              else
              _447_ = nil
              end
              if (nil ~= _447_) then
                local action = _447_
                local idx
                do
                  local _449_ = action
                  if (_449_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_449_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                  idx = nil
                  end
                end
                jump_to_21(sublist[idx].pos)
                return sx:go(reverse_3f0, x_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, idx = idx, in1 = in1, in2 = in2, sublist = sublist})
              else
                local _0 = _447_
                local _451_ = get_target_with_active_primary_label(sublist, in3)
                if (nil ~= _451_) then
                  local target = _451_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _453_
                    if (group_offset > 0) then
                      _453_ = nil
                    else
                      _453_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _453_}})
                    jump_to_21(target.pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _1 = _451_
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
    local _let_466_ = vim.split(opt, ".", true)
    local _0 = _let_466_[1]
    local scope = _let_466_[2]
    local name = _let_466_[3]
    local _467_
    if (opt == "vim.wo.scrolloff") then
      _467_ = api.nvim_eval("&l:scrolloff")
    else
      _467_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _467_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_469_ = vim.split(opt, ".", true)
    local _ = _let_469_[1]
    local scope = _let_469_[2]
    local name = _let_469_[3]
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
  for _, _470_ in ipairs(plug_keys) do
    local _each_471_ = _470_
    local lhs = _each_471_[1]
    local rhs_call = _each_471_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _472_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_473_ = _472_
    local lhs = _each_473_[1]
    local rhs_call = _each_473_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _474_ in ipairs(default_keymaps) do
    local _each_475_ = _474_
    local mode = _each_475_[1]
    local lhs = _each_475_[2]
    local rhs = _each_475_[3]
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
