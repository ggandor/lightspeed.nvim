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
  if ("\9" == string.sub(vim.fn.getline("."), 1, 1)) then
    return (wincol - dec(vim.o.tabstop))
  else
    return wincol
  end
end
local function get_fold_edge(lnum, reverse_3f)
  local _12_
  local _13_
  if reverse_3f then
    _13_ = vim.fn.foldclosed
  else
    _13_ = vim.fn.foldclosedend
  end
  _12_ = _13_(lnum)
  if (_12_ == -1) then
    return nil
  elseif (nil ~= _12_) then
    local fold_edge = _12_
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
  local function _18_(t, k)
    if contains_3f(deprecated_opts, k) then
      return api.nvim_echo(get_deprec_msg({k}), true, {})
    end
  end
  guard = _18_
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
local function _22_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _23_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _24_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _22_, ["set-extmark"] = _23_, cleanup = _24_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _26_
  do
    local _25_ = bg
    if (_25_ == "light") then
      _26_ = "#f02077"
    else
      local _ = _25_
      _26_ = "#ff2f87"
    end
  end
  local _31_
  do
    local _30_ = bg
    if (_30_ == "light") then
      _31_ = "#ff4090"
    else
      local _ = _30_
      _31_ = "#e01067"
    end
  end
  local _36_
  do
    local _35_ = bg
    if (_35_ == "light") then
      _36_ = "Blue"
    else
      local _ = _35_
      _36_ = "Cyan"
    end
  end
  local _41_
  do
    local _40_ = bg
    if (_40_ == "light") then
      _41_ = "#399d9f"
    else
      local _ = _40_
      _41_ = "#99ddff"
    end
  end
  local _46_
  do
    local _45_ = bg
    if (_45_ == "light") then
      _46_ = "Cyan"
    else
      local _ = _45_
      _46_ = "Blue"
    end
  end
  local _51_
  do
    local _50_ = bg
    if (_50_ == "light") then
      _51_ = "#59bdbf"
    else
      local _ = _50_
      _51_ = "#79bddf"
    end
  end
  local _56_
  do
    local _55_ = bg
    if (_55_ == "light") then
      _56_ = "#cc9999"
    else
      local _ = _55_
      _56_ = "#b38080"
    end
  end
  local _61_
  do
    local _60_ = bg
    if (_60_ == "light") then
      _61_ = "Black"
    else
      local _ = _60_
      _61_ = "White"
    end
  end
  local _66_
  do
    local _65_ = bg
    if (_65_ == "light") then
      _66_ = "#272020"
    else
      local _ = _65_
      _66_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _26_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _31_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _36_, gui = "bold,underline", guibg = "NONE", guifg = _41_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _46_, gui = "underline", guifg = _51_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _56_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _61_, gui = "bold", guibg = "NONE", guifg = _66_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _70_ in ipairs(groupdefs) do
    local _each_71_ = _70_
    local group = _each_71_[1]
    local attrs = _each_71_[2]
    local attrs_str
    local _72_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _72_ = tbl_12_auto
    end
    attrs_str = table.concat(_72_, " ")
    local _73_
    if force_3f then
      _73_ = ""
    else
      _73_ = "default "
    end
    vim.cmd(("highlight " .. _73_ .. group .. " " .. attrs_str))
  end
  for _, _75_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_76_ = _75_
    local from_group = _each_76_[1]
    local to_group = _each_76_[2]
    local _77_
    if force_3f then
      _77_ = ""
    else
      _77_ = "default "
    end
    vim.cmd(("highlight " .. _77_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_79_ = map(dec, get_cursor_pos())
  local curline = _let_79_[1]
  local curcol = _let_79_[2]
  local _let_80_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_80_[1]
  local win_bot = _let_80_[2]
  local function _82_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_81_ = _82_()
  local start = _let_81_[1]
  local finish = _let_81_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _83_, _85_, _87_)
  local _arg_84_ = _83_
  local startline = _arg_84_[1]
  local startcol = _arg_84_[2]
  local start = _arg_84_
  local _arg_86_ = _85_
  local endline = _arg_86_[1]
  local endcol = _arg_86_[2]
  local _end = _arg_86_
  local _arg_88_ = _87_
  local forced_motion = _arg_88_["forced-motion"]
  local inclusive_motion_3f = _arg_88_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _89_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _89_
  local _90_ = forced_motion
  if (_90_ == ctrl_v) then
    local _let_91_ = {min(startcol, endcol), max(startcol, endcol)}
    local startcol0 = _let_91_[1]
    local endcol0 = _let_91_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_90_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_90_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _90_
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
  local function _94_()
    local _93_ = direction
    if (_93_ == "fwd") then
      return "W"
    elseif (_93_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _94_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function get_onscreen_lines(_96_)
  local _arg_97_ = _96_
  local reverse_3f = _arg_97_["reverse?"]
  local skip_folds_3f = _arg_97_["skip-folds?"]
  local lines = {}
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local lnum = vim.fn.line(".")
  while true do
    local _98_
    if reverse_3f then
      _98_ = (lnum >= wintop)
    else
      _98_ = (lnum <= winbot)
    end
    if not _98_ then break end
    local fold_edge = get_fold_edge(lnum, reverse_3f)
    if (skip_folds_3f and fold_edge) then
      local _100_
      if reverse_3f then
        _100_ = dec
      else
        _100_ = inc
      end
      lnum = _100_(fold_edge)
    else
      lines[lnum] = vim.fn.getline(lnum)
      local _102_
      if reverse_3f then
        _102_ = dec
      else
        _102_ = inc
      end
      lnum = _102_(lnum)
    end
  end
  return lines
end
local function get_horizontal_bounds(_105_)
  local _arg_106_ = _105_
  local match_width = _arg_106_["match-width"]
  local textoff = (vim.fn.getwininfo(vim.fn.win_getid())[1].textoff or dec(leftmost_editable_wincol()))
  local offset_in_win = vim.fn.wincol()
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - dec(offset_in_editable_win))
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_width))
  return {left_bound, right_bound}
end
local function onscreen_match_positions(pattern, reverse_3f, _107_)
  local _arg_108_ = _107_
  local ft_search_3f = _arg_108_["ft-search?"]
  local limit = _arg_108_["limit"]
  local to_eol_3f = _arg_108_["to-eol?"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _110_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_110_())
  local cleanup
  local function _111_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _111_
  local _113_
  if ft_search_3f then
    _113_ = 1
  else
    _113_ = 2
  end
  local _let_112_ = get_horizontal_bounds({["match-width"] = _113_})
  local left_bound = _let_112_[1]
  local right_bound = _let_112_[2]
  local function skip_to_fold_edge_21()
    local _115_
    local _116_
    if reverse_3f then
      _116_ = vim.fn.foldclosed
    else
      _116_ = vim.fn.foldclosedend
    end
    _115_ = _116_(vim.fn.line("."))
    if (_115_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _115_) then
      local fold_edge = _115_
      vim.fn.cursor(fold_edge, 0)
      local function _118_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _118_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_120_ = get_cursor_pos()
    local line = _local_120_[1]
    local col = _local_120_[2]
    local from_pos = _local_120_
    local _121_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _121_ = {dec(line), right_bound}
        else
        _121_ = nil
        end
      else
        _121_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _121_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _121_ = {inc(line), left_bound}
        else
        _121_ = nil
        end
      end
    else
    _121_ = nil
    end
    if (nil ~= _121_) then
      local to_pos = _121_
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
      local _129_
      local _130_
      if match_at_curpos_3f then
        _130_ = "c"
      else
        _130_ = ""
      end
      _129_ = vim.fn.searchpos(pattern, (opts0 .. _130_), stopline)
      if ((type(_129_) == "table") and ((_129_)[1] == 0) and true) then
        local _ = (_129_)[2]
        return cleanup()
      elseif ((type(_129_) == "table") and (nil ~= (_129_)[1]) and (nil ~= (_129_)[2])) then
        local line = (_129_)[1]
        local col = (_129_)[2]
        local pos = _129_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _132_ = skip_to_fold_edge_21()
          if (_132_ == "moved-the-cursor") then
            return recur(false)
          elseif (_132_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_133_,_134_,_135_) return (_133_ <= _134_) and (_134_ <= _135_) end)(left_bound,col,right_bound) or to_eol_3f) then
              match_count = (match_count + 1)
              return pos
            else
              local _136_ = skip_to_next_in_window_pos_21()
              if (_136_ == "moved-the-cursor") then
                return recur(true)
              else
                local _ = _136_
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
  local _let_143_ = (_3fpos or get_cursor_pos())
  local line = _let_143_[1]
  local col = _let_143_[2]
  local pos = _let_143_
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
  local _146_ = mode
  if (_146_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  elseif (_146_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  end
end
local function get_input(_3ftimeout)
  local esc_keycode = 27
  local char_available_3f
  local function _148_()
    return (0 ~= vim.fn.getchar(1))
  end
  char_available_3f = _148_
  local getchar_timeout
  local function _149_()
    if vim.wait(_3ftimeout, char_available_3f, 100) then
      return vim.fn.getchar(0)
    end
  end
  getchar_timeout = _149_
  local ok_3f, ch = nil, nil
  local function _151_()
    if _3ftimeout then
      return getchar_timeout
    else
      return vim.fn.getchar
    end
  end
  ok_3f, ch = pcall(_151_())
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
  local _158_
  do
    local _157_ = repeat_invoc
    if (_157_ == "dot") then
      _158_ = "dotrepeat_"
    else
      local _ = _157_
      _158_ = ""
    end
  end
  local _163_
  do
    local _162_ = {kind, not not reverse_3f, not not x_or_t_3f}
    if ((type(_162_) == "table") and ((_162_)[1] == "ft") and ((_162_)[2] == false) and ((_162_)[3] == false)) then
      _163_ = "f"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "ft") and ((_162_)[2] == true) and ((_162_)[3] == false)) then
      _163_ = "F"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "ft") and ((_162_)[2] == false) and ((_162_)[3] == true)) then
      _163_ = "t"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "ft") and ((_162_)[2] == true) and ((_162_)[3] == true)) then
      _163_ = "T"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "sx") and ((_162_)[2] == false) and ((_162_)[3] == false)) then
      _163_ = "s"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "sx") and ((_162_)[2] == true) and ((_162_)[3] == false)) then
      _163_ = "S"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "sx") and ((_162_)[2] == false) and ((_162_)[3] == true)) then
      _163_ = "x"
    elseif ((type(_162_) == "table") and ((_162_)[1] == "sx") and ((_162_)[2] == true) and ((_162_)[3] == true)) then
      _163_ = "X"
    else
    _163_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _158_ .. _163_)
end
local function get_repeat_action(_in, kind, x_or_t_3f, instant_repeat_3f, from_reverse_cold_repeat_3f, _3ftarget_char)
  local mode
  if (vim.fn.mode() == "n") then
    mode = "n"
  else
    mode = "x"
  end
  local in_mapped_to = maparg_expr(_in, mode)
  local repeat_plug_key = ("<Plug>Lightspeed_;_" .. kind)
  local revert_plug_key = ("<Plug>Lightspeed_,_" .. kind)
  local _174_
  if from_reverse_cold_repeat_3f then
    _174_ = revert_plug_key
  else
    _174_ = repeat_plug_key
  end
  if ((_in == _3cbackspace_3e) or ((kind == "ft") and opts.repeat_ft_with_target_char and (_in == _3ftarget_char)) or ((in_mapped_to == get_plug_key(kind, false, x_or_t_3f)) or (in_mapped_to == _174_))) then
    return "repeat"
  else
    local _176_
    if from_reverse_cold_repeat_3f then
      _176_ = repeat_plug_key
    else
      _176_ = revert_plug_key
    end
    if (instant_repeat_3f and ((_in == "\9") or ((in_mapped_to == get_plug_key(kind, true, x_or_t_3f)) or (in_mapped_to == _176_)))) then
      return "revert"
    end
  end
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
    local t_180_ = instant_state
    if (nil ~= t_180_) then
      t_180_ = (t_180_)["reverted?"]
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
        if _190_ then
          local _192_ = (_190_).stack
          if _192_ then
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
    else
      local _ = _188_
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
        pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      end
      local limit = (count0 + get_num_of_matches_to_be_highlighted())
      for _211_ in onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit}) do
        local _each_212_ = _211_
        local line = _each_212_[1]
        local col = _each_212_[2]
        local pos = _each_212_
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
          local function _218_()
            if reverse_3f0 then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_218_())
          if (to_eol_3f and not reverse_3f0 and (vim.fn.mode() == "n")) then
            push_cursor_21("fwd")
          end
        end
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and true) then
            local _221_ = string.sub(vim.fn.mode("t"), -1)
            if (_221_ == "v") then
              push_cursor_21("bwd")
            elseif (_221_ == "o") then
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
        local _228_
        local function _229_()
          local res_2_auto
          do
            res_2_auto = get_input(opts.exit_after_idle_msecs.unlabeled)
          end
          hl:cleanup()
          return res_2_auto
        end
        local function _230_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _228_ = (_229_() or _230_())
        if (nil ~= _228_) then
          local in2 = _228_
          local stack
          local function _232_()
            local t_231_ = instant_state
            if (nil ~= t_231_) then
              t_231_ = (t_231_).stack
            end
            return t_231_
          end
          stack = (_232_() or {})
          local from_reverse_cold_repeat_3f
          if instant_repeat_3f then
            from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
          else
            from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
          end
          local _235_ = get_repeat_action(in2, "ft", t_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f, in1)
          if (_235_ == "repeat") then
            table.insert(stack, get_cursor_pos())
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = false, stack = stack})
          elseif (_235_ == "revert") then
            do
              local _236_ = table.remove(stack)
              if _236_ then
                vim.fn.cursor(_236_)
              else
              end
            end
            return ft:go(reverse_3f0, t_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, ["in"] = in1, ["reverted?"] = true, stack = stack})
          else
            local _ = _235_
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
  local function _243_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _243_})
end
local function highlight_unique_chars(reverse_3f)
  local unique_chars = {}
  local _let_245_ = get_horizontal_bounds({["match-width"] = 2})
  local left_bound = _let_245_[1]
  local right_bound = _let_245_[2]
  local _let_246_ = get_cursor_pos()
  local curline = _let_246_[1]
  local curcol = _let_246_[2]
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
        local _250_
        do
          local _249_ = unique_chars[ch]
          if (nil ~= _249_) then
            local pos_already_there = _249_
            _250_ = false
          else
            local _ = _249_
            _250_ = {lnum, col}
          end
        end
        unique_chars[ch] = _250_
      end
    end
  end
  for ch, pos in pairs(unique_chars) do
    local _255_ = pos
    if ((type(_255_) == "table") and (nil ~= (_255_)[1]) and (nil ~= (_255_)[2])) then
      local lnum = (_255_)[1]
      local col = (_255_)[2]
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
  for _258_ in onscreen_match_positions(pattern, reverse_3f, {["to-eol?"] = to_eol_3f}) do
    local _each_259_ = _258_
    local line = _each_259_[1]
    local col = _each_259_[2]
    local pos = _each_259_
    if to_eol_3f then
      table.insert(targets, {pair = {"\n", ""}, pos = pos})
    else
      local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
      local to_pre_eol_3f = (ch2 == "\13")
      local overlaps_prev_match_3f
      local _260_
      if reverse_3f then
        _260_ = dec
      else
        _260_ = inc
      end
      overlaps_prev_match_3f = ((line == prev_match.line) and (col == _260_(prev_match.col)))
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
          local _262_ = prev_target
          if ((type(_262_) == "table") and ((type((_262_).pos) == "table") and (nil ~= ((_262_).pos)[1]) and (nil ~= ((_262_).pos)[2]))) then
            local prev_line = ((_262_).pos)[1]
            local prev_col = ((_262_).pos)[2]
            local function _264_()
              local col_delta
              if reverse_3f then
                col_delta = (prev_col - col)
              else
                col_delta = (col - prev_col)
              end
              return (col_delta <= match_width)
            end
            touches_prev_target_3f = ((line == prev_line) and _264_())
          else
          touches_prev_target_3f = nil
          end
        end
        if to_pre_eol_3f then
          target["squeezed?"] = true
        end
        if touches_prev_target_3f then
          local _267_
          if reverse_3f then
            _267_ = target
          else
            _267_ = prev_target
          end
          _267_["squeezed?"] = true
        end
        if overlaps_prev_target_3f then
          local _270_
          if reverse_3f then
            _270_ = prev_target
          else
            _270_ = target
          end
          _270_["overlapped?"] = true
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
  for _, _276_ in ipairs(targets) do
    local _each_277_ = _276_
    local target = _each_277_
    local _each_278_ = _each_277_["pair"]
    local _0 = _each_278_[1]
    local ch2 = _each_278_[2]
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
    local _283_ = sublist["autojump?"]
    if (_283_ == true) then
      return opts.safe_labels
    elseif (_283_ == false) then
      return opts.labels
    elseif (_283_ == nil) then
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
        local _286_
        if not (sublist["autojump?"] and (i == 1)) then
          local _287_
          local _289_
          if sublist["autojump?"] then
            _289_ = dec(i)
          else
            _289_ = i
          end
          _287_ = (_289_ % #labels)
          if (_287_ == 0) then
            _286_ = last(labels)
          elseif (nil ~= _287_) then
            local n = _287_
            _286_ = labels[n]
          else
          _286_ = nil
          end
        else
        _286_ = nil
        end
        target["label"] = _286_
      end
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
  local _298_
  if sublist["autojump?"] then
    _298_ = 2
  else
    _298_ = 1
  end
  primary_start = (offset + _298_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    local _300_
    if target.label then
      if ((i < primary_start) or (i > secondary_end)) then
        _300_ = "inactive"
      elseif (i <= primary_end) then
        _300_ = "active-primary"
      else
        _300_ = "active-secondary"
      end
    else
    _300_ = nil
    end
    target["label-state"] = _300_
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
      local _303_, _304_ = ch2, true
      if ((nil ~= _303_) and (nil ~= _304_)) then
        local k_10_auto = _303_
        local v_11_auto = _304_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    potential_2nd_inputs = tbl_9_auto
  end
  local labels_used_up_as_shortcut = {}
  for _, _306_ in ipairs(targets) do
    local _each_307_ = _306_
    local target = _each_307_
    local label = _each_307_["label"]
    local label_state = _each_307_["label-state"]
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
local function set_beacon(_310_, _repeat)
  local _arg_311_ = _310_
  local target = _arg_311_
  local label = _arg_311_["label"]
  local label_state = _arg_311_["label-state"]
  local overlapped_3f = _arg_311_["overlapped?"]
  local _arg_312_ = _arg_311_["pair"]
  local ch1 = _arg_312_[1]
  local ch2 = _arg_312_[2]
  local _arg_313_ = _arg_311_["pos"]
  local _ = _arg_313_[1]
  local col = _arg_313_[2]
  local shortcut_3f = _arg_311_["shortcut?"]
  local squeezed_3f = _arg_311_["squeezed?"]
  local to_eol_3f = ((ch1 == "\n") and (ch2 == ""))
  local _let_314_ = get_horizontal_bounds({["match-width"] = 1})
  local left_bound = _let_314_[1]
  local right_bound = _let_314_[2]
  local function _316_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  local _let_315_ = map(_316_, {ch1, ch2})
  local ch10 = _let_315_[1]
  local ch20 = _let_315_[2]
  local masked_char_24 = {ch20, hl.group["masked-ch"]}
  local label_24 = {label, hl.group.label}
  local shortcut_24 = {label, hl.group.shortcut}
  local distant_label_24 = {label, hl.group["label-distant"]}
  local overlapped_label_24 = {label, hl.group["label-overlapped"]}
  local overlapped_shortcut_24 = {label, hl.group["shortcut-overlapped"]}
  local overlapped_distant_label_24 = {label, hl.group["label-distant-overlapped"]}
  do
    local _317_ = label_state
    if (_317_ == nil) then
      if not (_repeat or to_eol_3f) then
        if overlapped_3f then
          target.beacon = {1, {{ch20, hl.group["unlabeled-match"]}}}
        else
          target.beacon = {0, {{(ch10 .. ch20), hl.group["unlabeled-match"]}}}
        end
      else
      target.beacon = nil
      end
    elseif (_317_ == "active-primary") then
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
        local _321_
        if squeezed_3f then
          _321_ = 1
        else
          _321_ = 2
        end
        target.beacon = {_321_, {shortcut_24}}
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
    elseif (_317_ == "active-secondary") then
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
        local _327_
        if squeezed_3f then
          _327_ = 1
        else
          _327_ = 2
        end
        target.beacon = {_327_, {distant_label_24}}
      elseif overlapped_3f then
        target.beacon = {1, {overlapped_distant_label_24}}
      elseif squeezed_3f then
        target.beacon = {0, {masked_char_24, distant_label_24}}
      else
        target.beacon = {2, {distant_label_24}}
      end
    elseif (_317_ == "inactive") then
      target.beacon = nil
    else
    target.beacon = nil
    end
  end
  return nil
end
local function set_beacons(target_list, _331_)
  local _arg_332_ = _331_
  local _repeat = _arg_332_["repeat"]
  for _, target in ipairs(target_list) do
    set_beacon(target, _repeat)
  end
  return nil
end
local function light_up_beacons(target_list, _3fstart_idx)
  for i = (_3fstart_idx or 1), #target_list do
    local _let_333_ = target_list[i]
    local beacon = _let_333_["beacon"]
    local _let_334_ = _let_333_["pos"]
    local line = _let_334_[1]
    local col = _let_334_[2]
    local _335_ = beacon
    if ((type(_335_) == "table") and (nil ~= (_335_)[1]) and (nil ~= (_335_)[2]) and true) then
      local offset = (_335_)[1]
      local chunks = (_335_)[2]
      local _3fleft_off_3f = (_335_)[3]
      local _336_
      if _3fleft_off_3f then
        _336_ = 0
      else
      _336_ = nil
      end
      hl["set-extmark"](hl, dec(line), dec((col + offset)), {virt_text = chunks, virt_text_pos = "overlay", virt_text_win_col = _336_})
    end
  end
  return nil
end
local function get_target_with_active_primary_label(target_list, input)
  local res = nil
  for _, _339_ in ipairs(target_list) do
    local _each_340_ = _339_
    local target = _each_340_
    local label = _each_340_["label"]
    local label_state = _each_340_["label-state"]
    if res then break end
    if ((label == input) and (label_state == "active-primary")) then
      res = target
    end
  end
  return res
end
local function ignore_input_until_timeout(char_to_ignore)
  local _342_ = get_input(opts.jump_on_partial_input_safety_timeout)
  if (nil ~= _342_) then
    local input = _342_
    if (input ~= char_to_ignore) then
      return vim.fn.feedkeys(input, "i")
    end
  end
end
local sx = {state = {cold = {["reverse?"] = nil, ["x-mode?"] = nil, in1 = nil, in2 = nil}, dot = {in1 = nil, in2 = nil, in3 = nil}}}
sx.go = function(self, reverse_3f, x_mode_3f, repeat_invoc)
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
    local function _346_(_241)
      if invoked_as_reverse_3f then
        return not _241
      else
        return _241
      end
    end
    reverse_3f0 = _346_(self.state.cold["reverse?"])
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
      local _350_
      local function _351_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _352_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _350_ = (_351_() or _352_())
      if (_350_ == _3cbackspace_3e) then
        backspace_repeat_3f = true
        new_search_3f = false
        local function _354_()
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
        return (self.state.cold.in1 or _354_())
      elseif (nil ~= _350_) then
        local _in = _350_
        return _in
      end
    end
  end
  local function update_state_2a(in1)
    local function _360_(_358_)
      local _arg_359_ = _358_
      local cold = _arg_359_["cold"]
      local dot = _arg_359_["dot"]
      if new_search_3f then
        if cold then
          local _361_ = cold
          _361_["in1"] = in1
          _361_["x-mode?"] = x_mode_3f0
          _361_["reverse?"] = reverse_3f0
          self.state.cold = _361_
        end
        if dot then
          if dot_repeatable_op_3f then
            do
              local _363_ = dot
              _363_["in1"] = in1
              _363_["x-mode?"] = x_mode_3f0
              self.state.dot = _363_
            end
            return nil
          end
        end
      end
    end
    return _360_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _367_(target, _3fto_pre_eol_3f)
      local to_pre_eol_3f0 = (_3fto_pre_eol_3f or to_pre_eol_3f)
      local adjusted_pos
      do
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
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
        local adjusted_pos_6_auto = get_cursor_pos()
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        else
          if (not reverse_3f0 and (x_mode_3f0 and not reverse_3f0)) then
            local _373_ = string.sub(vim.fn.mode("t"), -1)
            if (_373_ == "v") then
              push_cursor_21("bwd")
            elseif (_373_ == "o") then
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
    jump_to_21 = _367_
  end
  local function highlight_new_curpos_and_op_area(from_pos, to_pos)
    local forced_motion = string.sub(vim.fn.mode("t"), -1)
    local blockwise_3f = (forced_motion == replace_keycodes("<c-v>"))
    local function _379_()
      if reverse_3f0 then
        return to_pos
      else
        return from_pos
      end
    end
    local _let_378_ = _379_()
    local startline = _let_378_[1]
    local startcol = _let_378_[2]
    local start = _let_378_
    local function _381_()
      if reverse_3f0 then
        return from_pos
      else
        return to_pos
      end
    end
    local _let_380_ = _381_()
    local _ = _let_380_[1]
    local endcol = _let_380_[2]
    local _end = _let_380_
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
    local _386_ = targets.sublists[ch]
    if (nil ~= _386_) then
      local sublist = _386_
      local _let_387_ = sublist
      local _let_388_ = _let_387_[1]
      local _let_389_ = _let_388_["pos"]
      local line = _let_389_[1]
      local col = _let_389_[2]
      local rest = {(table.unpack or unpack)(_let_387_, 2)}
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
      local _393_
      if (cold_repeat_3f or backspace_repeat_3f) then
        _393_ = "cold"
      elseif instant_repeat_3f then
        _393_ = "instant"
      else
      _393_ = nil
      end
      set_beacons(sublist, {["repeat"] = _393_})
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
      local _396_
      do
        local res_2_auto
        do
          local function _397_()
            if initial_invoc_3f then
              return opts.exit_after_idle_msecs.labeled
            end
          end
          res_2_auto = get_input(_397_())
        end
        hl:cleanup()
        _396_ = res_2_auto
      end
      if (nil ~= _396_) then
        local input = _396_
        if (sublist["autojump?"] and opts.labels and not empty_3f(opts.labels)) then
          return {input, 0}
        elseif (((input == next_group_key) or (input == prev_group_key)) and not instant_repeat_3f) then
          local labels = get_labels(sublist)
          local num_of_groups = ceil((#sublist / #labels))
          local max_offset = dec(num_of_groups)
          local group_offset_2a
          local _399_
          do
            local _398_ = input
            if (_398_ == next_group_key) then
              _399_ = inc
            else
              local _ = _398_
              _399_ = dec
            end
          end
          group_offset_2a = clamp(_399_(group_offset), 0, max_offset)
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
  local _408_ = get_first_input()
  if (nil ~= _408_) then
    local in1 = _408_
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
    local _410_
    local function _412_()
      local t_411_ = instant_state
      if (nil ~= t_411_) then
        t_411_ = (t_411_).sublist
      end
      return t_411_
    end
    local function _414_()
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
    _410_ = (_412_() or get_targets(in1, reverse_3f0) or _414_())
    if ((type(_410_) == "table") and ((type((_410_)[1]) == "table") and ((type(((_410_)[1]).pair) == "table") and true and (nil ~= (((_410_)[1]).pair)[2]))) and ((_410_)[2] == nil)) then
      local only = (_410_)[1]
      local _0 = (((_410_)[1]).pair)[1]
      local ch2 = (((_410_)[1]).pair)[2]
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
    elseif (nil ~= _410_) then
      local targets = _410_
      if not instant_repeat_3f then
        local _420_ = targets
        populate_sublists(_420_)
        set_labels(_420_, to_eol_3f)
        set_label_states(_420_)
      end
      if (new_search_3f and not to_eol_3f) then
        do
          local _422_ = targets
          set_shortcuts_and_populate_shortcuts_map(_422_)
          set_beacons(_422_, {["repeat"] = nil})
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
      local _425_
      local function _426_()
        if to_eol_3f then
          return ""
        end
      end
      local function _427_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup()
        return res_2_auto
      end
      local function _428_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _425_ = (prev_in2 or _426_() or _427_() or _428_())
      if (nil ~= _425_) then
        local in2 = _425_
        local _430_
        do
          local t_431_ = targets.shortcuts
          if (nil ~= t_431_) then
            t_431_ = (t_431_)[in2]
          end
          _430_ = t_431_
        end
        if ((type(_430_) == "table") and ((type((_430_).pair) == "table") and true and (nil ~= ((_430_).pair)[2]))) then
          local shortcut = _430_
          local _0 = ((_430_).pair)[1]
          local ch2 = ((_430_).pair)[2]
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
          local _0 = _430_
          to_pre_eol_3f = (in2 == "\13")
          update_state({cold = {in2 = in2}})
          local _434_
          local function _436_()
            local t_435_ = instant_state
            if (nil ~= t_435_) then
              t_435_ = (t_435_).sublist
            end
            return t_435_
          end
          local function _438_()
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
          _434_ = (_436_() or get_sublist(targets, in2) or _438_())
          if ((type(_434_) == "table") and (nil ~= (_434_)[1]) and ((_434_)[2] == nil)) then
            local only = (_434_)[1]
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
          elseif ((type(_434_) == "table") and (nil ~= (_434_)[1])) then
            local first = (_434_)[1]
            local sublist = _434_
            local autojump_3f = sublist["autojump?"]
            local curr_idx
            local function _442_()
              local t_441_ = instant_state
              if (nil ~= t_441_) then
                t_441_ = (t_441_).idx
              end
              return t_441_
            end
            local function _444_()
              if autojump_3f then
                return 1
              else
                return 0
              end
            end
            curr_idx = (_442_() or _444_())
            local from_reverse_cold_repeat_3f
            if instant_repeat_3f then
              from_reverse_cold_repeat_3f = instant_state["from-reverse-cold-repeat?"]
            else
              from_reverse_cold_repeat_3f = (cold_repeat_3f and invoked_as_reverse_3f)
            end
            if (autojump_3f and not instant_repeat_3f) then
              jump_to_21(first.pos)
            end
            local _447_
            local function _448_()
              if (dot_repeat_3f and self.state.dot.in3) then
                return {self.state.dot.in3, 0}
              end
            end
            local function _449_()
              if change_operation_3f() then
                handle_interrupted_change_op_21()
              end
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            end
            _447_ = (_448_() or get_last_input(sublist, inc(curr_idx)) or _449_())
            if ((type(_447_) == "table") and (nil ~= (_447_)[1]) and (nil ~= (_447_)[2])) then
              local in3 = (_447_)[1]
              local group_offset = (_447_)[2]
              local _451_
              if not op_mode_3f then
                _451_ = get_repeat_action(in3, "sx", x_mode_3f0, instant_repeat_3f, from_reverse_cold_repeat_3f)
              else
              _451_ = nil
              end
              if (nil ~= _451_) then
                local action = _451_
                local idx
                do
                  local _453_ = action
                  if (_453_ == "repeat") then
                    idx = min(inc(curr_idx), #targets)
                  elseif (_453_ == "revert") then
                    idx = max(dec(curr_idx), 1)
                  else
                  idx = nil
                  end
                end
                jump_to_21(sublist[idx].pos)
                return sx:go(reverse_3f0, x_mode_3f0, {["from-reverse-cold-repeat?"] = from_reverse_cold_repeat_3f, idx = idx, in1 = in1, in2 = in2, sublist = sublist})
              else
                local _1 = _451_
                local _455_ = get_target_with_active_primary_label(sublist, in3)
                if (nil ~= _455_) then
                  local target = _455_
                  do
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key("sx", reverse_3f0, x_mode_3f0, "dot")))
                    end
                    local _457_
                    if (group_offset > 0) then
                      _457_ = nil
                    else
                      _457_ = in3
                    end
                    update_state({dot = {in2 = in2, in3 = _457_}})
                    jump_to_21(target.pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _2 = _455_
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
    local _let_470_ = vim.split(opt, ".", true)
    local _0 = _let_470_[1]
    local scope = _let_470_[2]
    local name = _let_470_[3]
    local _471_
    if (opt == "vim.wo.scrolloff") then
      _471_ = api.nvim_eval("&l:scrolloff")
    else
      _471_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _471_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_473_ = vim.split(opt, ".", true)
    local _ = _let_473_[1]
    local scope = _let_473_[2]
    local name = _let_473_[3]
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
  for _, _474_ in ipairs(plug_keys) do
    local _each_475_ = _474_
    local lhs = _each_475_[1]
    local rhs_call = _each_475_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _476_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_477_ = _476_
    local lhs = _each_477_[1]
    local rhs_call = _each_477_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}, {"n", ";", "<Plug>Lightspeed_;_ft"}, {"x", ";", "<Plug>Lightspeed_;_ft"}, {"o", ";", "<Plug>Lightspeed_;_ft"}, {"n", ",", "<Plug>Lightspeed_,_ft"}, {"x", ",", "<Plug>Lightspeed_,_ft"}, {"o", ",", "<Plug>Lightspeed_,_ft"}}
  for _, _478_ in ipairs(default_keymaps) do
    local _each_479_ = _478_
    local mode = _each_479_[1]
    local lhs = _each_479_[2]
    local rhs = _each_479_[3]
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
