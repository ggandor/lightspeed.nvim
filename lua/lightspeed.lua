local api = vim.api
local function inc(x)
  return (x + 1)
end
local function dec(x)
  return (x - 1)
end
local function clamp(val, min, max)
  if (val < min) then
    return min
  elseif (val > max) then
    return max
  elseif "else" then
    return val
  end
end
local function last(tbl)
  return tbl[#tbl]
end
local empty_3f = vim.tbl_isempty
local function reverse_lookup(tbl)
  local tbl_9_auto = {}
  for k, v in ipairs(tbl) do
    local _2_, _3_ = v, k
    if ((nil ~= _2_) and (nil ~= _3_)) then
      local k_10_auto = _2_
      local v_11_auto = _3_
      tbl_9_auto[k_10_auto] = v_11_auto
    end
  end
  return tbl_9_auto
end
local function getchar_as_str()
  local ok_3f, ch = pcall(vim.fn.getchar)
  local function _5_()
    if (type(ch) == "number") then
      return vim.fn.nr2char(ch)
    else
      return ch
    end
  end
  return ok_3f, _5_()
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
local function yank_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "y"))
end
local function change_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "c"))
end
local function delete_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator == "d"))
end
local function dot_repeatable_operation_3f()
  return (operator_pending_mode_3f() and (vim.v.operator ~= "y"))
end
local function get_cursor_pos()
  return {vim.fn.line("."), vim.fn.col(".")}
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
local opts = {cycle_group_bwd_key = nil, cycle_group_fwd_key = nil, grey_out_search_area = true, highlight_unique_chars = false, instant_repeat_bwd_key = nil, instant_repeat_fwd_key = nil, jump_on_partial_input_safety_timeout = 400, jump_to_first_match = true, labels = nil, limit_ft_matches = 5, match_only_the_start_of_same_char_seqs = true, substitute_chars = {["\13"] = "\194\172"}, x_mode_prefix_key = "<c-x>"}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local hl
local function _11_(self, hl_group, line, startcol, endcol)
  return api.nvim_buf_add_highlight(0, self.ns, hl_group, line, startcol, endcol)
end
local function _12_(self, line, col, opts0)
  return api.nvim_buf_set_extmark(0, self.ns, line, col, opts0)
end
local function _13_(self)
  return api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
end
hl = {["add-hl"] = _11_, ["set-extmark"] = _12_, cleanup = _13_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local groupdefs
  local _15_
  do
    local _14_ = bg
    if (_14_ == "light") then
      _15_ = "#f02077"
    else
      local _ = _14_
      _15_ = "#ff2f87"
    end
  end
  local _20_
  do
    local _19_ = bg
    if (_19_ == "light") then
      _20_ = "#ff4090"
    else
      local _ = _19_
      _20_ = "#e01067"
    end
  end
  local _25_
  do
    local _24_ = bg
    if (_24_ == "light") then
      _25_ = "Blue"
    else
      local _ = _24_
      _25_ = "Cyan"
    end
  end
  local _30_
  do
    local _29_ = bg
    if (_29_ == "light") then
      _30_ = "#399d9f"
    else
      local _ = _29_
      _30_ = "#99ddff"
    end
  end
  local _35_
  do
    local _34_ = bg
    if (_34_ == "light") then
      _35_ = "Cyan"
    else
      local _ = _34_
      _35_ = "Blue"
    end
  end
  local _40_
  do
    local _39_ = bg
    if (_39_ == "light") then
      _40_ = "#59bdbf"
    else
      local _ = _39_
      _40_ = "#79bddf"
    end
  end
  local _45_
  do
    local _44_ = bg
    if (_44_ == "light") then
      _45_ = "#cc9999"
    else
      local _ = _44_
      _45_ = "#b38080"
    end
  end
  local _50_
  do
    local _49_ = bg
    if (_49_ == "light") then
      _50_ = "Black"
    else
      local _ = _49_
      _50_ = "White"
    end
  end
  local _55_
  do
    local _54_ = bg
    if (_54_ == "light") then
      _55_ = "#272020"
    else
      local _ = _54_
      _55_ = "#f3ecec"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _15_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _20_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _25_, gui = "bold,underline", guibg = "NONE", guifg = _30_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _35_, gui = "underline", guifg = _40_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _45_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _50_, gui = "bold", guibg = "NONE", guifg = _55_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _59_ in ipairs(groupdefs) do
    local _each_60_ = _59_
    local group = _each_60_[1]
    local attrs = _each_60_[2]
    local attrs_str
    local _61_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _61_ = tbl_12_auto
    end
    attrs_str = table.concat(_61_, " ")
    local _62_
    if force_3f then
      _62_ = ""
    else
      _62_ = "default "
    end
    vim.cmd(("highlight " .. _62_ .. group .. " " .. attrs_str))
  end
  for _, _64_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_65_ = _64_
    local from_group = _each_65_[1]
    local to_group = _each_65_[2]
    local _66_
    if force_3f then
      _66_ = ""
    else
      _66_ = "default "
    end
    vim.cmd(("highlight " .. _66_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_68_ = vim.tbl_map(dec, get_cursor_pos())
  local curline = _let_68_[1]
  local curcol = _let_68_[2]
  local _let_69_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_69_[1]
  local win_bot = _let_69_[2]
  local function _71_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_70_ = _71_()
  local start = _let_70_[1]
  local finish = _let_70_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function highlight_range(hl_group, _72_, _74_, _76_)
  local _arg_73_ = _72_
  local startline = _arg_73_[1]
  local startcol = _arg_73_[2]
  local start = _arg_73_
  local _arg_75_ = _74_
  local endline = _arg_75_[1]
  local endcol = _arg_75_[2]
  local _end = _arg_75_
  local _arg_77_ = _76_
  local forced_motion = _arg_77_["forced-motion"]
  local inclusive_motion_3f = _arg_77_["inclusive-motion?"]
  local ctrl_v = replace_keycodes("<c-v>")
  local hl_range
  local function _78_(start0, _end0, end_inclusive_3f)
    return vim.highlight.range(0, hl.ns, hl_group, start0, _end0, nil, end_inclusive_3f)
  end
  hl_range = _78_
  local _79_ = forced_motion
  if (_79_ == ctrl_v) then
    local _let_80_ = {math.min(startcol, endcol), math.max(startcol, endcol)}
    local startcol0 = _let_80_[1]
    local endcol0 = _let_80_[2]
    for line = startline, endline do
      hl_range({line, startcol0}, {line, endcol0}, true)
    end
    return nil
  elseif (_79_ == "V") then
    return hl_range({startline, 0}, {endline, -1})
  elseif (_79_ == "v") then
    return hl_range(start, _end, not inclusive_motion_3f)
  else
    local _ = _79_
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
  local function _83_()
    local _82_ = direction
    if (_82_ == "fwd") then
      return "W"
    elseif (_82_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _83_())
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function onscreen_match_positions(pattern, reverse_3f, _85_)
  local _arg_86_ = _85_
  local ft_search_3f = _arg_86_["ft-search?"]
  local limit = _arg_86_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _88_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_88_())
  local cleanup
  local function _89_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _89_
  local non_editable_width = dec(leftmost_editable_wincol())
  local col_in_edit_area = (vim.fn.wincol() - non_editable_width)
  local left_bound = (vim.fn.col(".") - dec(col_in_edit_area))
  local window_width = api.nvim_win_get_width(0)
  local right_bound = (left_bound + dec((window_width - non_editable_width - 1)))
  local function skip_to_fold_edge_21()
    local _90_
    local _91_
    if reverse_3f then
      _91_ = vim.fn.foldclosed
    else
      _91_ = vim.fn.foldclosedend
    end
    _90_ = _91_(vim.fn.line("."))
    if (_90_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _90_) then
      local fold_edge = _90_
      vim.fn.cursor(fold_edge, 0)
      local function _93_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _93_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_95_ = get_cursor_pos()
    local line = _local_95_[1]
    local col = _local_95_[2]
    local from_pos = _local_95_
    local _96_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _96_ = {dec(line), right_bound}
        else
        _96_ = nil
        end
      else
        _96_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _96_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _96_ = {inc(line), left_bound}
        else
        _96_ = nil
        end
      end
    else
    _96_ = nil
    end
    if (nil ~= _96_) then
      local to_pos = _96_
      if (from_pos ~= to_pos) then
        vim.fn.cursor(to_pos)
        return "moved-the-cursor"
      end
    end
  end
  vim.o.cpo = cpo:gsub("c", "")
  local match_count = 0
  local function rec(match_at_curpos_3f)
    if (limit and (match_count >= limit)) then
      return cleanup()
    else
      local _104_
      local _105_
      if match_at_curpos_3f then
        _105_ = "c"
      else
        _105_ = ""
      end
      _104_ = vim.fn.searchpos(pattern, (opts0 .. _105_), stopline)
      if ((type(_104_) == "table") and ((_104_)[1] == 0) and true) then
        local _ = (_104_)[2]
        return cleanup()
      elseif ((type(_104_) == "table") and (nil ~= (_104_)[1]) and (nil ~= (_104_)[2])) then
        local line = (_104_)[1]
        local col = (_104_)[2]
        local pos = _104_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _107_ = skip_to_fold_edge_21()
          if (_107_ == "moved-the-cursor") then
            return rec(false)
          elseif (_107_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_108_,_109_,_110_) return (_108_ <= _109_) and (_109_ <= _110_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _111_ = skip_to_next_in_window_pos_21()
              if (_111_ == "moved-the-cursor") then
                return rec(true)
              else
                local _ = _111_
                return cleanup()
              end
            end
          end
        end
      end
    end
  end
  return rec
end
local function highlight_unique_chars(reverse_3f, ignorecase)
  local unique_chars = {}
  for pos in onscreen_match_positions("..", reverse_3f, {}) do
    local ch = char_at_pos(pos, {})
    local _119_
    do
      local _118_ = unique_chars[ch]
      if (_118_ == nil) then
        _119_ = pos
      else
        local _ = _118_
        _119_ = false
      end
    end
    unique_chars[ch] = _119_
  end
  for ch, pos_or_false in pairs(unique_chars) do
    if pos_or_false then
      local _let_123_ = pos_or_false
      local line = _let_123_[1]
      local col = _let_123_[2]
      hl["set-extmark"](hl, dec(line), dec(col), {virt_text = {{ch, hl.group["unique-ch"]}}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function highlight_cursor(_3fpos)
  local _let_125_ = (_3fpos or get_cursor_pos())
  local line = _let_125_[1]
  local col = _let_125_[2]
  local pos = _let_125_
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
  local _128_ = mode
  if (_128_ == "sx") then
    return doau_when_exists("LightspeedSxEnter")
  elseif (_128_ == "ft") then
    return doau_when_exists("LightspeedFtEnter")
  end
end
local function get_input_and_clean_up()
  local ok_3f, res = getchar_as_str()
  hl:cleanup()
  if (ok_3f and (res ~= replace_keycodes("<esc>"))) then
    return res
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
  local __3ebool
  local function _134_(_241)
    return not not _241
  end
  __3ebool = _134_
  local _136_
  do
    local _135_ = repeat_invoc
    if (_135_ == "dot") then
      _136_ = "dotrepeat_"
    else
      local _ = _135_
      _136_ = ""
    end
  end
  local _141_
  do
    local _140_ = {kind, __3ebool(reverse_3f), __3ebool(x_or_t_3f)}
    if ((type(_140_) == "table") and ((_140_)[1] == "ft") and ((_140_)[2] == false) and ((_140_)[3] == false)) then
      _141_ = "f"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "ft") and ((_140_)[2] == true) and ((_140_)[3] == false)) then
      _141_ = "F"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "ft") and ((_140_)[2] == false) and ((_140_)[3] == true)) then
      _141_ = "t"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "ft") and ((_140_)[2] == true) and ((_140_)[3] == true)) then
      _141_ = "T"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "sx") and ((_140_)[2] == false) and ((_140_)[3] == false)) then
      _141_ = "s"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "sx") and ((_140_)[2] == false) and ((_140_)[3] == true)) then
      _141_ = "S"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "sx") and ((_140_)[2] == true) and ((_140_)[3] == false)) then
      _141_ = "x"
    elseif ((type(_140_) == "table") and ((_140_)[1] == "sx") and ((_140_)[2] == true) and ((_140_)[3] == true)) then
      _141_ = "X"
    else
    _141_ = nil
    end
  end
  return ("<Plug>Lightspeed_" .. _136_ .. _141_)
end
local ft = {state = {cold = {["in"] = nil, ["reverse?"] = nil, ["t-mode?"] = nil}, dot = {["in"] = nil}, instant = {["in"] = nil, stack = nil}}}
ft.go = function(self, reverse_3f, t_mode_3f, repeat_invoc)
  local instant_repeat_3f = ((repeat_invoc == "instant") or (repeat_invoc == "reverted-instant"))
  local reverted_instant_repeat_3f = (repeat_invoc == "reverted-instant")
  local cold_repeat_3f = (repeat_invoc == "cold")
  local dot_repeat_3f = (repeat_invoc == "dot")
  local count
  if reverted_instant_repeat_3f then
    count = 0
  else
    count = vim.v.count1
  end
  local _let_152_ = vim.tbl_map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_152_[1]
  local revert_key = _let_152_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("ft", reverse_3f, t_mode_3f, "dot"))
  if not instant_repeat_3f then
    enter("ft")
  end
  if not repeat_invoc then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _155_
  if instant_repeat_3f then
    _155_ = self.state.instant["in"]
  elseif dot_repeat_3f then
    _155_ = self.state.dot["in"]
  elseif cold_repeat_3f then
    _155_ = self.state.cold["in"]
  else
    local _156_
    local function _157_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedFtLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _156_ = (get_input_and_clean_up() or _157_())
    if (_156_ == "\13") then
      local function _159_()
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
      _155_ = (self.state.cold["in"] or _159_())
    elseif (nil ~= _156_) then
      local in0 = _156_
      _155_ = in0
    else
    _155_ = nil
    end
  end
  if (nil ~= _155_) then
    local in1 = _155_
    if not repeat_invoc then
      self.state.cold = {["in"] = in1, ["reverse?"] = reverse_3f, ["t-mode?"] = t_mode_3f}
    end
    local function _165_()
      if reverse_3f then
        return "nWb"
      else
        return "nW"
      end
    end
    local _local_164_ = vim.fn.searchpos("\\_.", _165_())
    local next_line = _local_164_[1]
    local next_col = _local_164_[2]
    local match_pos = nil
    local i = 0
    local function _168_()
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit
      if opts.limit_ft_matches then
        limit = (count + opts.limit_ft_matches)
      else
      limit = nil
      end
      return onscreen_match_positions(pattern, reverse_3f, {["ft-search?"] = true, limit = limit})
    end
    for _166_ in _168_() do
      local _each_169_ = _166_
      local line = _each_169_[1]
      local col = _each_169_[2]
      local pos = _each_169_
      if not (repeat_invoc and t_mode_3f and (i == 0) and (line == next_line) and (col == next_col)) then
        i = (i + 1)
        if (i <= count) then
          match_pos = pos
        else
          if not op_mode_3f then
            hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
          end
        end
      end
    end
    if ((count > 0) and not match_pos) then
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
        vim.fn.cursor(match_pos)
        if t_mode_3f then
          local function _175_()
            if reverse_3f then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_175_())
        end
        if (op_mode_3f_4_auto and not reverse_3f and true) then
          local _177_ = string.sub(vim.fn.mode("t"), -1)
          if (_177_ == "v") then
            push_cursor_21("bwd")
          elseif (_177_ == "o") then
            if not cursor_before_eof_3f() then
              push_cursor_21("fwd")
            else
              vim.cmd("set virtualedit=onemore")
              vim.cmd("norm! l")
              vim.cmd(restore_virtualedit_autocmd_5_auto)
            end
          end
        end
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        end
      end
      if op_mode_3f then
        if dot_repeatable_op_3f then
          self.state.dot = {["in"] = in1}
          return set_dot_repeat(cmd_for_dot_repeat, count)
        end
      else
        highlight_cursor()
        vim.cmd("redraw")
        local _184_
        local function _185_()
          do
          end
          doau_when_exists("LightspeedFtLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _184_ = (get_input_and_clean_up() or _185_())
        if (nil ~= _184_) then
          local in2 = _184_
          local mode
          if (vim.fn.mode() == "n") then
            mode = "n"
          else
            mode = "x"
          end
          local repeat_3f = ((in2 == repeat_key) or string.match(vim.fn.maparg(in2, mode), get_plug_key("ft", false, t_mode_3f)))
          local revert_3f = ((in2 == revert_key) or string.match(vim.fn.maparg(in2, mode), get_plug_key("ft", true, t_mode_3f)))
          local do_instant_repeat_3f = (repeat_3f or revert_3f)
          if do_instant_repeat_3f then
            if not instant_repeat_3f then
              self.state.instant = {["in"] = in1, stack = {}}
            end
            if revert_3f then
              local _188_ = table.remove(self.state.instant.stack)
              if (nil ~= _188_) then
                local old_pos = _188_
                vim.fn.cursor(old_pos)
              end
            elseif repeat_3f then
              table.insert(self.state.instant.stack, get_cursor_pos())
            end
            local function _191_()
              if revert_3f then
                return "reverted-instant"
              else
                return "instant"
              end
            end
            return ft:go(reverse_3f, t_mode_3f, _191_())
          else
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
  local function _197_(t, k)
    if ((k == "instant-repeat?") or (k == "prev-t-like?")) then
      return api.nvim_echo(deprec_msg, true, {})
    end
  end
  setmetatable(ft, {__index = _197_})
end
local function get_labels()
  local function _199_()
    if opts.jump_to_first_match then
      return {"f", "s", "n", "u", "t", "/", "q", "F", "S", "G", "H", "L", "M", "N", "U", "R", "T", "Z", "?", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "a", ";", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "z", "."}
    end
  end
  return (opts.labels or _199_())
end
local function get_cycle_keys()
  local function _200_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _201_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return vim.tbl_map(replace_keycodes, {(opts.cycle_group_fwd_key or _200_()), (opts.cycle_group_bwd_key or _201_())})
end
local function get_match_map_for(ch1, reverse_3f)
  local match_map = {}
  local prefix = "\\V\\C"
  local input = ch1:gsub("\\", "\\\\")
  local pattern = (prefix .. input .. "\\_.")
  local match_count = 0
  local prev = {}
  for _202_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_203_ = _202_
    local line = _each_203_[1]
    local col = _each_203_[2]
    local pos = _each_203_
    local overlap_with_prev_3f
    local _204_
    if reverse_3f then
      _204_ = dec
    else
      _204_ = inc
    end
    overlap_with_prev_3f = ((line == prev.line) and (col == _204_(prev.col)))
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local same_pair_3f = (ch2 == prev.ch2)
    local function _206_()
      if not opts.match_only_the_start_of_same_char_seqs then
        return prev["skipped?"]
      end
    end
    if (_206_() or not (overlap_with_prev_3f and same_pair_3f)) then
      local partially_covered_3f = (overlap_with_prev_3f and not reverse_3f)
      if not match_map[ch2] then
        match_map[ch2] = {}
      end
      table.insert(match_map[ch2], {line, col, partially_covered_3f})
      if (overlap_with_prev_3f and reverse_3f) then
        last(match_map[prev.ch2])[3] = true
      end
      prev = {["skipped?"] = false, ch2 = ch2, col = col, line = line}
      match_count = (match_count + 1)
    else
      prev = {["skipped?"] = true, ch2 = ch2, col = col, line = line}
    end
  end
  local _210_ = match_count
  if (_210_ == 0) then
    return nil
  elseif (_210_ == 1) then
    local ch2 = vim.tbl_keys(match_map)[1]
    local pos = vim.tbl_values(match_map)[1][1]
    return {ch2, pos}
  else
    local _ = _210_
    return match_map
  end
end
local function set_beacon_at(_212_, ch1, ch2, _214_)
  local _arg_213_ = _212_
  local line = _arg_213_[1]
  local col = _arg_213_[2]
  local partially_covered_3f = _arg_213_[3]
  local pos = _arg_213_
  local _arg_215_ = _214_
  local distant_3f = _arg_215_["distant?"]
  local labeled_3f = _arg_215_["labeled?"]
  local repeat_3f = _arg_215_["repeat?"]
  local shortcut_3f = _arg_215_["shortcut?"]
  local ch10 = (opts.substitute_chars[ch1] or ch1)
  local ch20
  local function _216_()
    if not labeled_3f then
      return opts.substitute_chars[ch2]
    end
  end
  ch20 = (_216_() or ch2)
  local partially_covered_3f0
  if not repeat_3f then
    partially_covered_3f0 = partially_covered_3f
  else
  partially_covered_3f0 = nil
  end
  local shortcut_3f0
  if not repeat_3f then
    shortcut_3f0 = shortcut_3f
  else
  shortcut_3f0 = nil
  end
  local label_hl
  if shortcut_3f0 then
    label_hl = hl.group.shortcut
  elseif distant_3f then
    label_hl = hl.group["label-distant"]
  else
    label_hl = hl.group.label
  end
  local overlapped_label_hl
  if shortcut_3f0 then
    overlapped_label_hl = hl.group["shortcut-overlapped"]
  elseif distant_3f then
    overlapped_label_hl = hl.group["label-distant-overlapped"]
  else
    overlapped_label_hl = hl.group["label-overlapped"]
  end
  local function _223_()
    if not labeled_3f then
      if partially_covered_3f0 then
        return {inc(col), {ch20, hl.group["unlabeled-match"]}, nil}
      else
        return {col, {ch10, hl.group["unlabeled-match"]}, {ch20, hl.group["unlabeled-match"]}}
      end
    elseif partially_covered_3f0 then
      return {inc(col), {ch20, overlapped_label_hl}, nil}
    elseif repeat_3f then
      return {inc(col), {ch20, label_hl}, nil}
    else
      return {col, {ch10, hl.group["masked-ch"]}, {ch20, label_hl}}
    end
  end
  local _let_221_ = _223_()
  local startcol = _let_221_[1]
  local chunk1 = _let_221_[2]
  local _3fchunk2 = _let_221_[3]
  return hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
end
local function set_beacon_groups(ch2, positions, labels, shortcuts, _224_)
  local _arg_225_ = _224_
  local group_offset = _arg_225_["group-offset"]
  local repeat_3f = _arg_225_["repeat?"]
  local group_offset0 = (group_offset or 0)
  local _7clabels_7c = #labels
  local start = inc((group_offset0 * _7clabels_7c))
  local set_group
  local function _226_(start0, distant_3f)
    for i = start0, dec((start0 + _7clabels_7c)) do
      if ((i < 1) or (i > #positions)) then break end
      local pos = positions[i]
      local label = (labels[(i % _7clabels_7c)] or labels[_7clabels_7c])
      local shortcut_3f
      if not distant_3f then
        shortcut_3f = shortcuts[pos]
      else
      shortcut_3f = nil
      end
      set_beacon_at(pos, ch2, label, {["distant?"] = distant_3f, ["labeled?"] = true, ["repeat?"] = repeat_3f, ["shortcut?"] = shortcut_3f})
    end
    return nil
  end
  set_group = _226_
  set_group(start, false)
  return set_group((start + _7clabels_7c), true)
end
local function get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
  local collides_with_a_ch2_3f
  local function _228_(_241)
    return vim.tbl_contains(vim.tbl_keys(match_map), _241)
  end
  collides_with_a_ch2_3f = _228_
  local by_distance_from_cursor
  local function _235_(_229_, _232_)
    local _arg_230_ = _229_
    local _arg_231_ = _arg_230_[1]
    local l1 = _arg_231_[1]
    local c1 = _arg_231_[2]
    local _ = _arg_230_[2]
    local _0 = _arg_230_[3]
    local _arg_233_ = _232_
    local _arg_234_ = _arg_233_[1]
    local l2 = _arg_234_[1]
    local c2 = _arg_234_[2]
    local _1 = _arg_233_[2]
    local _2 = _arg_233_[3]
    if (l1 == l2) then
      if reverse_3f then
        return (c1 > c2)
      else
        return (c1 < c2)
      end
    else
      if reverse_3f then
        return (l1 > l2)
      else
        return (l1 < l2)
      end
    end
  end
  by_distance_from_cursor = _235_
  local shortcuts = {}
  for ch2, positions in pairs(match_map) do
    for i, pos in ipairs(positions) do
      local labeled_pos_3f = not ((#positions == 1) or (jump_to_first_3f and (i == 1)))
      if labeled_pos_3f then
        local _239_
        local _240_
        if jump_to_first_3f then
          _240_ = dec(i)
        else
          _240_ = i
        end
        _239_ = labels[_240_]
        if (nil ~= _239_) then
          local label = _239_
          if not collides_with_a_ch2_3f(label) then
            table.insert(shortcuts, {pos, label, ch2})
          end
        end
      end
    end
  end
  table.sort(shortcuts, by_distance_from_cursor)
  local lookup_by_pos
  do
    local labels_used_up = {}
    local tbl_9_auto = {}
    for _, _245_ in ipairs(shortcuts) do
      local _each_246_ = _245_
      local pos = _each_246_[1]
      local label = _each_246_[2]
      local ch2 = _each_246_[3]
      local _247_, _248_ = nil, nil
      if not labels_used_up[label] then
        labels_used_up[label] = true
        _247_, _248_ = pos, {label, ch2}
      else
      _247_, _248_ = nil
      end
      if ((nil ~= _247_) and (nil ~= _248_)) then
        local k_10_auto = _247_
        local v_11_auto = _248_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    lookup_by_pos = tbl_9_auto
  end
  local lookup_by_label
  do
    local tbl_9_auto = {}
    for pos, _251_ in pairs(lookup_by_pos) do
      local _each_252_ = _251_
      local label = _each_252_[1]
      local ch2 = _each_252_[2]
      local _253_, _254_ = label, {pos, ch2}
      if ((nil ~= _253_) and (nil ~= _254_)) then
        local k_10_auto = _253_
        local v_11_auto = _254_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    lookup_by_label = tbl_9_auto
  end
  return vim.tbl_extend("error", lookup_by_pos, lookup_by_label)
end
local function ignore_char_until_timeout(char_to_ignore)
  local start = os.clock()
  local timeout_secs = (opts.jump_on_partial_input_safety_timeout / 1000)
  local ok_3f, input = getchar_as_str()
  if not ((input == char_to_ignore) and (os.clock() < (start + timeout_secs))) then
    if ok_3f then
      return vim.fn.feedkeys(input, "i")
    end
  end
end
local sx = {state = {cold = {["reverse?"] = nil, ["x-mode?"] = nil, in1 = nil, in2 = nil}, dot = {["x-mode?"] = nil, in1 = nil, in2 = nil, in3 = nil}}}
sx.go = function(self, reverse_3f, invoked_in_x_mode_3f, repeat_invoc)
  local dot_repeat_3f = (repeat_invoc == "dot")
  local cold_repeat_3f = (repeat_invoc == "cold")
  local op_mode_3f = operator_pending_mode_3f()
  local change_op_3f = change_operation_3f()
  local delete_op_3f = delete_operation_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
  local _let_258_ = get_cycle_keys()
  local cycle_fwd_key = _let_258_[1]
  local cycle_bwd_key = _let_258_[2]
  local labels = get_labels()
  local jump_to_first_3f = (opts.jump_to_first_match and not op_mode_3f)
  local cmd_for_dot_repeat = replace_keycodes(get_plug_key("sx", reverse_3f, invoked_in_x_mode_3f, "dot"))
  local x_mode_3f = invoked_in_x_mode_3f
  local enter_repeat_3f = nil
  local new_search_3f = nil
  local function save_state_for_repeat(_259_)
    local _arg_260_ = _259_
    local cold = _arg_260_["cold"]
    local dot = _arg_260_["dot"]
    if new_search_3f then
      if cold then
        local _261_ = cold
        _261_["x-mode?"] = x_mode_3f
        _261_["reverse?"] = reverse_3f
        self.state.cold = _261_
      end
      if (dot_repeatable_op_3f and dot) then
        do
          local _263_ = dot
          _263_["x-mode?"] = x_mode_3f
          self.state.dot = _263_
        end
        return nil
      end
    end
  end
  local jump_wrapped_21
  do
    local first_jump_3f = true
    local function _266_(target)
      do
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if first_jump_3f then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(target)
        if x_mode_3f then
          push_cursor_21("fwd")
          if reverse_3f then
            push_cursor_21("fwd")
          end
        end
        if (op_mode_3f_4_auto and not reverse_3f and (x_mode_3f and not reverse_3f)) then
          local _270_ = string.sub(vim.fn.mode("t"), -1)
          if (_270_ == "v") then
            push_cursor_21("bwd")
          elseif (_270_ == "o") then
            if not cursor_before_eof_3f() then
              push_cursor_21("fwd")
            else
              vim.cmd("set virtualedit=onemore")
              vim.cmd("norm! l")
              vim.cmd(restore_virtualedit_autocmd_5_auto)
            end
          end
        end
        if not op_mode_3f_4_auto then
          force_matchparen_refresh()
        end
      end
      if dot_repeatable_op_3f then
        set_dot_repeat(cmd_for_dot_repeat)
      end
      first_jump_3f = false
      return nil
    end
    jump_wrapped_21 = _266_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_276_, ch2)
    local _arg_277_ = _276_
    local target_line = _arg_277_[1]
    local target_col = _arg_277_[2]
    local from_pos = vim.tbl_map(dec, get_cursor_pos())
    jump_wrapped_21({target_line, target_col})
    if new_search_3f then
      do
        local ctrl_v = replace_keycodes("<c-v>")
        local forward_x_3f = (x_mode_3f and not reverse_3f)
        local backward_x_3f = (x_mode_3f and reverse_3f)
        local forced_motion = string.sub(vim.fn.mode("t"), -1)
        local to_col
        if backward_x_3f then
          to_col = inc(inc(target_col))
        elseif forward_x_3f then
          to_col = inc(target_col)
        else
          to_col = target_col
        end
        local to_pos = vim.tbl_map(dec, {target_line, to_col})
        local function _280_()
          if reverse_3f then
            return to_pos
          else
            return from_pos
          end
        end
        local _let_279_ = _280_()
        local startline = _let_279_[1]
        local startcol = _let_279_[2]
        local start = _let_279_
        local function _282_()
          if reverse_3f then
            return from_pos
          else
            return to_pos
          end
        end
        local _let_281_ = _282_()
        local _ = _let_281_[1]
        local endcol = _let_281_[2]
        local _end = _let_281_
        local _3fhighlight_cursor_at
        if op_mode_3f then
          local function _283_()
            if (forced_motion == ctrl_v) then
              return {startline, math.min(startcol, endcol)}
            elseif not reverse_3f then
              return from_pos
            end
          end
          _3fhighlight_cursor_at = vim.tbl_map(inc, _283_())
        else
        _3fhighlight_cursor_at = nil
        end
        if not change_op_3f then
          highlight_cursor(_3fhighlight_cursor_at)
        end
        if op_mode_3f then
          highlight_range(hl.group["pending-op-area"], start, _end, {["forced-motion"] = forced_motion, ["inclusive-motion?"] = forward_x_3f})
        end
      end
      vim.cmd("redraw")
      ignore_char_until_timeout(ch2)
      if change_op_3f then
        echo("")
      end
      return hl:cleanup()
    end
  end
  local function select_match_group(in2, positions_to_label, shortcuts, enter_repeat_3f0)
    local ret = nil
    local group_offset = 0
    local loop_3f = true
    while loop_3f do
      local _289_
      local function _290_()
        if dot_repeat_3f then
          return self.state.dot.in3
        end
      end
      local function _291_()
        loop_3f = false
        ret = nil
        return nil
      end
      _289_ = (_290_() or get_input_and_clean_up() or _291_())
      if (nil ~= _289_) then
        local input = _289_
        if not ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          loop_3f = false
          ret = {group_offset, input}
        else
          local max_offset = math.floor((#positions_to_label / #labels))
          local _293_
          do
            local _292_ = input
            if (_292_ == cycle_fwd_key) then
              _293_ = inc
            else
              local _ = _292_
              _293_ = dec
            end
          end
          group_offset = clamp(_293_(group_offset), 0, max_offset)
          if (opts.grey_out_search_area and not cold_repeat_3f) then
            grey_out_search_area(reverse_3f)
          end
          do
            set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["group-offset"] = group_offset, ["repeat?"] = enter_repeat_3f0})
          end
          highlight_cursor()
          vim.cmd("redraw")
        end
      end
    end
    return ret
  end
  enter("sx")
  if not repeat_invoc then
    echo("")
    if (opts.grey_out_search_area and not cold_repeat_3f) then
      grey_out_search_area(reverse_3f)
    end
    do
      if opts.highlight_unique_chars then
        highlight_unique_chars(reverse_3f)
      end
    end
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _303_
  if dot_repeat_3f then
    x_mode_3f = self.state.dot["x-mode?"]
    _303_ = self.state.dot.in1
  elseif cold_repeat_3f then
    _303_ = self.state.cold.in1
  else
    local _304_
    local function _305_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      doau_when_exists("LightspeedSxLeave")
      doau_when_exists("LightspeedLeave")
      return nil
    end
    _304_ = (get_input_and_clean_up() or _305_())
    if (nil ~= _304_) then
      local in0 = _304_
      do
        local _307_ = in0
        if (_307_ == "\13") then
          enter_repeat_3f = true
        elseif (_307_ == x_mode_prefix_key) then
          x_mode_3f = true
        end
      end
      local res = in0
      if (x_mode_3f and not invoked_in_x_mode_3f) then
        local _309_
        local function _310_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          end
          do
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        end
        _309_ = (get_input_and_clean_up() or _310_())
        if (_309_ == "\13") then
          enter_repeat_3f = true
        elseif (nil ~= _309_) then
          local in0_2a = _309_
          res = in0_2a
        end
      end
      new_search_3f = not (repeat_invoc or enter_repeat_3f)
      if enter_repeat_3f then
        local function _314_()
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
        _303_ = (self.state.cold.in1 or _314_())
      else
        _303_ = res
      end
    else
    _303_ = nil
    end
  end
  if (nil ~= _303_) then
    local in1 = _303_
    local prev_in2
    if (cold_repeat_3f or enter_repeat_3f) then
      prev_in2 = self.state.cold.in2
    elseif dot_repeat_3f then
      prev_in2 = self.state.dot.in2
    else
    prev_in2 = nil
    end
    local _320_
    local function _321_()
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
    _320_ = (get_match_map_for(in1, reverse_3f) or _321_())
    if ((type(_320_) == "table") and (nil ~= (_320_)[1]) and (nil ~= (_320_)[2])) then
      local ch2 = (_320_)[1]
      local pos = (_320_)[2]
      local unique_match = _320_
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          save_state_for_repeat({cold = {in1 = in1, in2 = ch2}, dot = {in1 = in1, in2 = ch2, in3 = labels[1]}})
          jump_and_ignore_ch2_until_timeout_21(pos, ch2)
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
    elseif (nil ~= _320_) then
      local match_map = _320_
      local shortcuts = get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
      if new_search_3f then
        if (opts.grey_out_search_area and not cold_repeat_3f) then
          grey_out_search_area(reverse_3f)
        end
        do
          for ch2, positions in pairs(match_map) do
            local _let_326_ = positions
            local first = _let_326_[1]
            local rest = {(table.unpack or unpack)(_let_326_, 2)}
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest
            else
              positions_to_label = positions
            end
            if (jump_to_first_3f or empty_3f(rest)) then
              set_beacon_at(first, in1, ch2, {})
            end
            if not empty_3f(rest) then
              set_beacon_groups(ch2, positions_to_label, labels, shortcuts, {})
            end
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _331_
      local function _332_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        doau_when_exists("LightspeedSxLeave")
        doau_when_exists("LightspeedLeave")
        return nil
      end
      _331_ = (prev_in2 or get_input_and_clean_up() or _332_())
      if (nil ~= _331_) then
        local in2 = _331_
        local _334_
        if new_search_3f then
          _334_ = shortcuts[in2]
        else
        _334_ = nil
        end
        if ((type(_334_) == "table") and (nil ~= (_334_)[1]) and (nil ~= (_334_)[2])) then
          local pos = (_334_)[1]
          local ch2 = (_334_)[2]
          local shortcut = _334_
          do
            save_state_for_repeat({cold = {in1 = in1, in2 = ch2}, dot = {in1 = in1, in2 = ch2, in3 = in2}})
            jump_wrapped_21(pos)
          end
          doau_when_exists("LightspeedSxLeave")
          doau_when_exists("LightspeedLeave")
          return nil
        else
          local _ = _334_
          save_state_for_repeat({cold = {in1 = in1, in2 = in2}, dot = {in1 = in1, in2 = in2, in3 = labels[1]}})
          local _336_
          local function _337_()
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
          _336_ = (match_map[in2] or _337_())
          if (nil ~= _336_) then
            local positions = _336_
            local _let_339_ = positions
            local _let_340_ = _let_339_[1]
            local line = _let_340_[1]
            local col = _let_340_[2]
            local first = _let_340_
            local rest = {(table.unpack or unpack)(_let_339_, 2)}
            local _let_341_ = rest
            local f_rest = _let_341_[1]
            local r_rest = {(table.unpack or unpack)(_let_341_, 2)}
            local _let_342_ = vim.fn.searchpos("\\_.", "nWb")
            local next_line = _let_342_[1]
            local next_col = _let_342_[2]
            local skip_one_3f = (cold_repeat_3f and x_mode_3f and reverse_3f and (line == next_line) and (col == dec(next_col)))
            local function _344_()
              if skip_one_3f then
                return {f_rest, r_rest, rest}
              else
                return {first, rest, positions}
              end
            end
            local _let_343_ = _344_()
            local first0 = _let_343_[1]
            local rest0 = _let_343_[2]
            local positions0 = _let_343_[3]
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest0
            else
              positions_to_label = positions0
            end
            if (first0 and (cold_repeat_3f or jump_to_first_3f or empty_3f(rest0))) then
              jump_wrapped_21(first0)
            end
            if empty_3f(rest0) then
              do
              end
              doau_when_exists("LightspeedSxLeave")
              doau_when_exists("LightspeedLeave")
              return nil
            elseif cold_repeat_3f then
              if not op_mode_3f then
                do
                  if (opts.grey_out_search_area and not cold_repeat_3f) then
                    grey_out_search_area(reverse_3f)
                  end
                  do
                    for _0, _348_ in ipairs(rest0) do
                      local _each_349_ = _348_
                      local line0 = _each_349_[1]
                      local col0 = _each_349_[2]
                      hl["add-hl"](hl, hl.group["one-char-match"], dec(line0), dec(col0), inc(col0))
                    end
                  end
                  highlight_cursor()
                  vim.cmd("redraw")
                end
                do
                  vim.fn.feedkeys((get_input_and_clean_up() or ""), "i")
                end
                doau_when_exists("LightspeedSxLeave")
                doau_when_exists("LightspeedLeave")
                return nil
              end
            else
              if not (dot_repeat_3f and self.state.dot.in3) then
                if (opts.grey_out_search_area and not cold_repeat_3f) then
                  grey_out_search_area(reverse_3f)
                end
                do
                  set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["repeat?"] = enter_repeat_3f})
                end
                highlight_cursor()
                vim.cmd("redraw")
              end
              local _353_
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
              _353_ = (select_match_group(in2, positions_to_label, shortcuts, enter_repeat_3f) or _354_())
              if ((type(_353_) == "table") and (nil ~= (_353_)[1]) and (nil ~= (_353_)[2])) then
                local group_offset = (_353_)[1]
                local in3 = (_353_)[2]
                if (dot_repeatable_op_3f and not dot_repeat_3f) then
                  if (group_offset == 0) then
                    self.state.dot.in3 = in3
                  else
                    self.state.dot.in3 = nil
                  end
                end
                local _358_
                do
                  local _359_ = reverse_lookup(labels)[in3]
                  if _359_ then
                    local _360_ = ((group_offset * #labels) + _359_)
                    if _360_ then
                      _358_ = positions_to_label[_360_]
                    else
                      _358_ = _360_
                    end
                  else
                    _358_ = _359_
                  end
                end
                if (nil ~= _358_) then
                  local pos = _358_
                  do
                    jump_wrapped_21(pos)
                  end
                  doau_when_exists("LightspeedSxLeave")
                  doau_when_exists("LightspeedLeave")
                  return nil
                else
                  local _0 = _358_
                  if jump_to_first_3f then
                    do
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
local temporary_editor_opts = {["vim.wo.conceallevel"] = 0, ["vim.wo.scrolloff"] = 0}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_373_ = vim.split(opt, ".", true)
    local _0 = _let_373_[1]
    local scope = _let_373_[2]
    local name = _let_373_[3]
    local _374_
    if (opt == "vim.wo.scrolloff") then
      _374_ = api.nvim_eval("&l:scrolloff")
    else
      _374_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _374_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_376_ = vim.split(opt, ".", true)
    local _ = _let_376_[1]
    local scope = _let_376_[2]
    local name = _let_376_[3]
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
  local plug_keys = {{"<Plug>Lightspeed_s", "sx:go(false)"}, {"<Plug>Lightspeed_S", "sx:go(true)"}, {"<Plug>Lightspeed_x", "sx:go(false, true)"}, {"<Plug>Lightspeed_X", "sx:go(true, true)"}, {"<Plug>Lightspeed_f", "ft:go(false)"}, {"<Plug>Lightspeed_F", "ft:go(true)"}, {"<Plug>Lightspeed_t", "ft:go(false, true)"}, {"<Plug>Lightspeed_T", "ft:go(true, true)"}, {"<Plug>Lightspeed_;_sx", "sx:go(require'lightspeed'.sx.state.cold['reverse?'], require'lightspeed'.sx.state.cold['x-mode?'], 'cold')"}, {"<Plug>Lightspeed_,_sx", "sx:go(not require'lightspeed'.sx.state.cold['reverse?'], require'lightspeed'.sx.state.cold['x-mode?'], 'cold')"}, {"<Plug>Lightspeed_;_ft", "ft:go(require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}, {"<Plug>Lightspeed_,_ft", "ft:go(not require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}, {"<Plug>Lightspeed_;", "ft:go(require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}, {"<Plug>Lightspeed_,", "ft:go(not require'lightspeed'.ft.state.cold['reverse?'], require'lightspeed'.ft.state.cold['t-mode?'], 'cold')"}}
  for _, _377_ in ipairs(plug_keys) do
    local _each_378_ = _377_
    local lhs = _each_378_[1]
    local rhs_call = _each_378_[2]
    for _0, mode in ipairs({"n", "x", "o"}) do
      api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
    end
  end
  for _, _379_ in ipairs({{"<Plug>Lightspeed_dotrepeat_s", "sx:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_S", "sx:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_x", "sx:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_X", "sx:go(true, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_f", "ft:go(false, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_F", "ft:go(true, false, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_t", "ft:go(false, true, 'dot')"}, {"<Plug>Lightspeed_dotrepeat_T", "ft:go(true, true, 'dot')"}}) do
    local _each_380_ = _379_
    local lhs = _each_380_[1]
    local rhs_call = _each_380_[2]
    api.nvim_set_keymap("o", lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _381_ in ipairs(default_keymaps) do
    local _each_382_ = _381_
    local mode = _each_382_[1]
    local lhs = _each_382_[2]
    local rhs = _each_382_[3]
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
