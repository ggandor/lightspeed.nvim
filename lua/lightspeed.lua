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
hl = {["add-hl"] = _11_, ["set-extmark"] = _12_, cleanup = _13_, group = {["label-distant"] = "LightspeedLabelDistant", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", ["label-overlapped"] = "LightspeedLabelOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["one-char-match"] = "LightspeedOneCharMatch", ["pending-change-op-area"] = "LightspeedPendingChangeOpArea", ["pending-op-area"] = "LightspeedPendingOpArea", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["unique-ch"] = "LightspeedUniqueChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", cursor = "LightspeedCursor", greywash = "LightspeedGreyWash", label = "LightspeedLabel", shortcut = "LightspeedShortcut"}, ns = api.nvim_create_namespace("")}
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
  local _60_
  do
    local _59_ = bg
    if (_59_ == "light") then
      _60_ = "#f02077"
    else
      local _ = _59_
      _60_ = "#ff2f87"
    end
  end
  groupdefs = {{hl.group.label, {cterm = "bold,underline", ctermbg = "NONE", ctermfg = "Red", gui = "bold,underline", guibg = "NONE", guifg = _15_}}, {hl.group["label-overlapped"], {cterm = "underline", ctermbg = "NONE", ctermfg = "Magenta", gui = "underline", guibg = "NONE", guifg = _20_}}, {hl.group["label-distant"], {cterm = "bold,underline", ctermbg = "NONE", ctermfg = _25_, gui = "bold,underline", guibg = "NONE", guifg = _30_}}, {hl.group["label-distant-overlapped"], {cterm = "underline", ctermfg = _35_, gui = "underline", guifg = _40_}}, {hl.group.shortcut, {cterm = "bold,underline", ctermbg = "Red", ctermfg = "White", gui = "bold,underline", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["one-char-match"], {cterm = "bold", ctermbg = "Red", ctermfg = "White", gui = "bold", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["masked-ch"], {cterm = "NONE", ctermbg = "NONE", ctermfg = "DarkGrey", gui = "NONE", guibg = "NONE", guifg = _45_}}, {hl.group["unlabeled-match"], {cterm = "bold", ctermbg = "NONE", ctermfg = _50_, gui = "bold", guibg = "NONE", guifg = _55_}}, {hl.group["pending-op-area"], {ctermbg = "Red", ctermfg = "White", guibg = "#f00077", guifg = "#ffffff"}}, {hl.group["pending-change-op-area"], {cterm = "strikethrough", ctermbg = "NONE", ctermfg = "Red", gui = "strikethrough", guibg = "NONE", guifg = _60_}}, {hl.group.greywash, {cterm = "NONE", ctermbg = "NONE", ctermfg = "Grey", gui = "NONE", guibg = "NONE", guifg = "#777777"}}}
  for _, _64_ in ipairs(groupdefs) do
    local _each_65_ = _64_
    local group = _each_65_[1]
    local attrs = _each_65_[2]
    local attrs_str
    local _66_
    do
      local tbl_12_auto = {}
      for k, v in pairs(attrs) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _66_ = tbl_12_auto
    end
    attrs_str = table.concat(_66_, " ")
    local _67_
    if force_3f then
      _67_ = ""
    else
      _67_ = "default "
    end
    vim.cmd(("highlight " .. _67_ .. group .. " " .. attrs_str))
  end
  for _, _69_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_70_ = _69_
    local from_group = _each_70_[1]
    local to_group = _each_70_[2]
    local _71_
    if force_3f then
      _71_ = ""
    else
      _71_ = "default "
    end
    vim.cmd(("highlight " .. _71_ .. "link " .. from_group .. " " .. to_group))
  end
  return nil
end
local function grey_out_search_area(reverse_3f)
  local _let_73_ = vim.tbl_map(dec, get_cursor_pos())
  local curline = _let_73_[1]
  local curcol = _let_73_[2]
  local _let_74_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_74_[1]
  local win_bot = _let_74_[2]
  local function _76_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_75_ = _76_()
  local start = _let_75_[1]
  local finish = _let_75_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local _78_
  do
    local _77_ = direction
    if (_77_ == "fwd") then
      _78_ = "W"
    elseif (_77_ == "bwd") then
      _78_ = "bW"
    else
    _78_ = nil
    end
  end
  return vim.fn.search("\\_.", _78_, __fnl_global___3fstopline)
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function onscreen_match_positions(pattern, reverse_3f, _82_)
  local _arg_83_ = _82_
  local ft_search_3f = _arg_83_["ft-search?"]
  local limit = _arg_83_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _85_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_85_())
  local cleanup
  local function _86_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _86_
  local non_editable_width = dec(leftmost_editable_wincol())
  local col_in_edit_area = (vim.fn.wincol() - non_editable_width)
  local left_bound = (vim.fn.col(".") - dec(col_in_edit_area))
  local window_width = api.nvim_win_get_width(0)
  local right_bound = (left_bound + dec((window_width - non_editable_width - 1)))
  local function skip_to_fold_edge_21()
    local _87_
    local _88_
    if reverse_3f then
      _88_ = vim.fn.foldclosed
    else
      _88_ = vim.fn.foldclosedend
    end
    _87_ = _88_(vim.fn.line("."))
    if (_87_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _87_) then
      local fold_edge = _87_
      vim.fn.cursor(fold_edge, 0)
      local function _90_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _90_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_onscreen_pos_21()
    local _local_92_ = get_cursor_pos()
    local line = _local_92_[1]
    local col = _local_92_[2]
    local from_pos = _local_92_
    local _93_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _93_ = {dec(line), right_bound}
        else
        _93_ = nil
        end
      else
        _93_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _93_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _93_ = {inc(line), left_bound}
        else
        _93_ = nil
        end
      end
    else
    _93_ = nil
    end
    if (nil ~= _93_) then
      local to_pos = _93_
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
      local _101_
      local _102_
      if match_at_curpos_3f then
        _102_ = "c"
      else
        _102_ = ""
      end
      _101_ = vim.fn.searchpos(pattern, (opts0 .. _102_), stopline)
      if ((type(_101_) == "table") and ((_101_)[1] == 0) and true) then
        local _ = (_101_)[2]
        return cleanup()
      elseif ((type(_101_) == "table") and (nil ~= (_101_)[1]) and (nil ~= (_101_)[2])) then
        local line = (_101_)[1]
        local col = (_101_)[2]
        local pos = _101_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _104_ = skip_to_fold_edge_21()
          if (_104_ == "moved-the-cursor") then
            return rec(false)
          elseif (_104_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_105_,_106_,_107_) return (_105_ <= _106_) and (_106_ <= _107_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _108_ = skip_to_next_onscreen_pos_21()
              if (_108_ == "moved-the-cursor") then
                return rec(true)
              else
                local _ = _108_
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
    local _116_
    do
      local _115_ = unique_chars[ch]
      if (_115_ == nil) then
        _116_ = pos
      else
        local _ = _115_
        _116_ = false
      end
    end
    unique_chars[ch] = _116_
  end
  for ch, pos_or_false in pairs(unique_chars) do
    if pos_or_false then
      local _let_120_ = pos_or_false
      local line = _let_120_[1]
      local col = _let_120_[2]
      hl["set-extmark"](hl, dec(line), dec(col), {virt_text = {{ch, hl.group["unique-ch"]}}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function highlight_cursor(_3fpos)
  local _let_122_ = (_3fpos or get_cursor_pos())
  local line = _let_122_[1]
  local col = _let_122_[2]
  local pos = _let_122_
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
local ft = {["instant-repeat?"] = nil, ["prev-dot-repeatable-search"] = nil, ["prev-reverse?"] = nil, ["prev-search"] = nil, ["prev-t-like?"] = nil, ["started-reverse?"] = nil, stack = {}}
ft.to = function(self, reverse_3f, t_like_3f, dot_repeat_3f, revert_3f)
  local _
  if not self["instant-repeat?"] then
    self["started-reverse?"] = reverse_3f
    _ = nil
  else
  _ = nil
  end
  local reverse_3f0
  if self["instant-repeat?"] then
    reverse_3f0 = ((not reverse_3f and self["started-reverse?"]) or (reverse_3f and not self["started-reverse?"]))
  else
    reverse_3f0 = reverse_3f
  end
  local switched_directions_3f = ((reverse_3f0 and not self["prev-reverse?"]) or (not reverse_3f0 and self["prev-reverse?"]))
  local count
  if not self["instant-repeat?"] then
    count = vim.v.count1
  else
    if not revert_3f then
      if (t_like_3f and not switched_directions_3f) then
        count = inc(vim.v.count1)
      else
        count = vim.v.count1
      end
    else
      if t_like_3f then
        count = 1
      else
        count = 0
      end
    end
  end
  local _let_134_ = vim.tbl_map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_134_[1]
  local revert_key = _let_134_[2]
  local op_mode_3f = operator_pending_mode_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local motion
  if (not t_like_3f and not reverse_3f0) then
    motion = "f"
  elseif (not t_like_3f and reverse_3f0) then
    motion = "F"
  elseif (t_like_3f and not reverse_3f0) then
    motion = "t"
  elseif (t_like_3f and reverse_3f0) then
    motion = "T"
  else
  motion = nil
  end
  local cmd_for_dot_repeat = (replace_keycodes("<Plug>Lightspeed_dotrepeat_") .. motion)
  if not (dot_repeat_3f or self["instant-repeat?"]) then
    if vim.fn.exists("#User#LightspeedEnter") then
      vim.cmd("doautocmd <nomodeline> User LightspeedEnter")
    end
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local enter_repeat_3f = nil
  local _138_
  if self["instant-repeat?"] then
    _138_ = self["prev-search"]
  elseif dot_repeat_3f then
    _138_ = self["prev-dot-repeatable-search"]
  else
    local _139_
    local function _140_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      do
      end
      if vim.fn.exists("#User#LightspeedLeave") then
        vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
      end
      return nil
    end
    _139_ = (get_input_and_clean_up() or _140_())
    if (_139_ == "\13") then
      enter_repeat_3f = true
      local function _143_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_no_prev_search()
        end
        do
        end
        if vim.fn.exists("#User#LightspeedLeave") then
          vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
        end
        return nil
      end
      _138_ = (self["prev-search"] or _143_())
    elseif (nil ~= _139_) then
      local _in = _139_
      _138_ = _in
    else
    _138_ = nil
    end
  end
  if (nil ~= _138_) then
    local in1 = _138_
    local new_search_3f = not (enter_repeat_3f or self["instant-repeat?"] or dot_repeat_3f)
    if new_search_3f then
      if dot_repeatable_op_3f then
        self["prev-dot-repeatable-search"] = in1
        set_dot_repeat(cmd_for_dot_repeat, count)
      else
        self["prev-search"] = in1
      end
    end
    self["prev-reverse?"] = reverse_3f0
    self["prev-t-like?"] = t_like_3f
    local match_pos = nil
    local i = 0
    local function _152_()
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit
      if opts.limit_ft_matches then
        limit = (count + opts.limit_ft_matches)
      else
      limit = nil
      end
      return onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit})
    end
    for _150_ in _152_() do
      local _each_153_ = _150_
      local line = _each_153_[1]
      local col = _each_153_[2]
      local pos = _each_153_
      i = (i + 1)
      if (i <= count) then
        match_pos = pos
      else
        if not op_mode_3f then
          hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
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
      do
      end
      if vim.fn.exists("#User#LightspeedLeave") then
        vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
      end
      return nil
    else
      if not revert_3f then
        local op_mode_3f_4_auto = operator_pending_mode_3f()
        local restore_virtualedit_autocmd_5_auto = ("autocmd CursorMoved,WinLeave,BufLeave" .. ",InsertEnter,CmdlineEnter,CmdwinEnter" .. " * ++once set virtualedit=" .. vim.o.virtualedit)
        if not self["instant-repeat?"] then
          vim.cmd("norm! m`")
        end
        vim.fn.cursor(match_pos)
        if t_like_3f then
          local function _159_()
            if reverse_3f0 then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_159_())
        end
        if (op_mode_3f_4_auto and not reverse_3f0 and true) then
          local _161_ = string.sub(vim.fn.mode("t"), -1)
          if (_161_ == "v") then
            push_cursor_21("bwd")
          elseif (_161_ == "o") then
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
      local new_pos = get_cursor_pos()
      if not op_mode_3f then
        highlight_cursor()
        vim.cmd("redraw")
        local ok_3f, in2 = getchar_as_str()
        local mode
        if (vim.fn.mode() == "n") then
          mode = "n"
        else
          mode = "x"
        end
        local repeat_3f
        local _168_
        if t_like_3f then
          _168_ = "t"
        else
          _168_ = "f"
        end
        repeat_3f = ((in2 == repeat_key) or string.match(vim.fn.maparg(in2, mode), ("<Plug>Lightspeed_" .. _168_)))
        local revert_3f0
        local _170_
        if t_like_3f then
          _170_ = "T"
        else
          _170_ = "F"
        end
        revert_3f0 = ((in2 == revert_key) or string.match(vim.fn.maparg(in2, mode), ("<Plug>Lightspeed_" .. _170_)))
        hl:cleanup()
        self["instant-repeat?"] = (ok_3f and (repeat_3f or revert_3f0))
        if not self["instant-repeat?"] then
          do
            self.stack = {}
            local _172_
            if ok_3f then
              _172_ = in2
            else
              _172_ = replace_keycodes("<esc>")
            end
            vim.fn.feedkeys(_172_, "i")
          end
          if vim.fn.exists("#User#LightspeedLeave") then
            vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
          end
          return nil
        else
          if revert_3f0 then
            local _175_ = table.remove(self.stack)
            if (nil ~= _175_) then
              local prev_pos = _175_
              vim.fn.cursor(prev_pos)
            end
          else
            table.insert(self.stack, new_pos)
          end
          return ft:to(false, t_like_3f, false, revert_3f0)
        end
      end
    end
  end
end
local function get_labels()
  local function _182_()
    if opts.jump_to_first_match then
      return {"s", "f", "n", "/", "u", "t", "q", "S", "F", "G", "H", "L", "M", "N", "?", "U", "R", "Z", "T", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "a", ";", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "z", "."}
    end
  end
  return (opts.labels or _182_())
end
local function get_cycle_keys()
  local function _183_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _184_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return vim.tbl_map(replace_keycodes, {(opts.cycle_group_fwd_key or _183_()), (opts.cycle_group_bwd_key or _184_())})
end
local function get_match_map_for(ch1, reverse_3f)
  local match_map = {}
  local prefix = "\\V\\C"
  local input = ch1:gsub("\\", "\\\\")
  local pattern = (prefix .. input .. "\\_.")
  local match_count = 0
  local prev = {}
  for _185_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_186_ = _185_
    local line = _each_186_[1]
    local col = _each_186_[2]
    local pos = _each_186_
    local overlap_with_prev_3f
    local _187_
    if reverse_3f then
      _187_ = dec
    else
      _187_ = inc
    end
    overlap_with_prev_3f = ((line == prev.line) and (col == _187_(prev.col)))
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local same_pair_3f = (ch2 == prev.ch2)
    local function _189_()
      if not opts.match_only_the_start_of_same_char_seqs then
        return prev["skipped?"]
      end
    end
    if (_189_() or not (overlap_with_prev_3f and same_pair_3f)) then
      local partially_covered_3f = (overlap_with_prev_3f and not reverse_3f)
      if not match_map[ch2] then
        match_map[ch2] = {}
      end
      table.insert(match_map[ch2], {line, col, partially_covered_3f, __fnl_global___3fch3})
      if (overlap_with_prev_3f and reverse_3f) then
        last(match_map[prev.ch2])[3] = true
      end
      prev = {["skipped?"] = false, ch2 = ch2, col = col, line = line}
      match_count = (match_count + 1)
    else
      prev = {["skipped?"] = true, ch2 = ch2, col = col, line = line}
    end
  end
  local _193_ = match_count
  if (_193_ == 0) then
    return nil
  elseif (_193_ == 1) then
    local ch2 = vim.tbl_keys(match_map)[1]
    local pos = vim.tbl_values(match_map)[1][1]
    return {ch2, pos}
  else
    local _ = _193_
    return match_map
  end
end
local function set_beacon_at(_195_, ch1, ch2, _197_)
  local _arg_196_ = _195_
  local line = _arg_196_[1]
  local col = _arg_196_[2]
  local partially_covered_3f = _arg_196_[3]
  local pos = _arg_196_
  local _arg_198_ = _197_
  local distant_3f = _arg_198_["distant?"]
  local init_round_3f = _arg_198_["init-round?"]
  local labeled_3f = _arg_198_["labeled?"]
  local repeat_3f = _arg_198_["repeat?"]
  local shortcut_3f = _arg_198_["shortcut?"]
  local ch10 = (opts.substitute_chars[ch1] or ch1)
  local ch20
  local function _199_()
    if not labeled_3f then
      return opts.substitute_chars[ch2]
    end
  end
  ch20 = (_199_() or ch2)
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
  local function _207_()
    if not labeled_3f then
      if partially_covered_3f0 then
        return {inc(col), {ch20, hl.group["unlabeled-match"]}, nil}
      else
        return {col, {ch10, hl.group["unlabeled-match"]}, {ch20, hl.group["unlabeled-match"]}}
      end
    elseif partially_covered_3f0 then
      if init_round_3f then
        return {inc(col), {ch20, overlapped_label_hl}, nil}
      else
        return {col, {ch10, hl.group["masked-ch"]}, {ch20, overlapped_label_hl}}
      end
    elseif repeat_3f then
      return {inc(col), {ch20, label_hl}, nil}
    else
      return {col, {ch10, hl.group["masked-ch"]}, {ch20, label_hl}}
    end
  end
  local _let_204_ = _207_()
  local startcol = _let_204_[1]
  local chunk1 = _let_204_[2]
  local _3fchunk2 = _let_204_[3]
  return hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
end
local function set_beacon_groups(ch2, positions, labels, shortcuts, _208_)
  local _arg_209_ = _208_
  local group_offset = _arg_209_["group-offset"]
  local init_round_3f = _arg_209_["init-round?"]
  local repeat_3f = _arg_209_["repeat?"]
  local group_offset0 = (group_offset or 0)
  local _7clabels_7c = #labels
  local set_group
  local function _210_(start, distant_3f)
    for i = start, dec((start + _7clabels_7c)) do
      if ((i < 1) or (i > #positions)) then break end
      local pos = positions[i]
      local label = (labels[(i % _7clabels_7c)] or labels[_7clabels_7c])
      local shortcut_3f
      if not distant_3f then
        shortcut_3f = shortcuts[pos]
      else
      shortcut_3f = nil
      end
      set_beacon_at(pos, ch2, label, {["distant?"] = distant_3f, ["init-round?"] = init_round_3f, ["labeled?"] = true, ["repeat?"] = repeat_3f, ["shortcut?"] = shortcut_3f})
    end
    return nil
  end
  set_group = _210_
  local start = inc((group_offset0 * _7clabels_7c))
  local _end = dec((start + _7clabels_7c))
  set_group(start, false)
  return set_group((start + _7clabels_7c), true)
end
local function get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
  local collides_with_a_ch2_3f
  local function _212_(_241)
    return vim.tbl_contains(vim.tbl_keys(match_map), _241)
  end
  collides_with_a_ch2_3f = _212_
  local by_distance_from_cursor
  local function _219_(_213_, _216_)
    local _arg_214_ = _213_
    local _arg_215_ = _arg_214_[1]
    local l1 = _arg_215_[1]
    local c1 = _arg_215_[2]
    local _ = _arg_214_[2]
    local _0 = _arg_214_[3]
    local _arg_217_ = _216_
    local _arg_218_ = _arg_217_[1]
    local l2 = _arg_218_[1]
    local c2 = _arg_218_[2]
    local _1 = _arg_217_[2]
    local _2 = _arg_217_[3]
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
  by_distance_from_cursor = _219_
  local shortcuts = {}
  for ch2, positions in pairs(match_map) do
    for i, pos in ipairs(positions) do
      local labeled_pos_3f = not ((#positions == 1) or (jump_to_first_3f and (i == 1)))
      if labeled_pos_3f then
        local _223_
        local _224_
        if jump_to_first_3f then
          _224_ = dec(i)
        else
          _224_ = i
        end
        _223_ = labels[_224_]
        if (nil ~= _223_) then
          local label = _223_
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
    for _, _229_ in ipairs(shortcuts) do
      local _each_230_ = _229_
      local pos = _each_230_[1]
      local label = _each_230_[2]
      local ch2 = _each_230_[3]
      local _231_, _232_ = nil, nil
      if not labels_used_up[label] then
        labels_used_up[label] = true
        _231_, _232_ = pos, {label, ch2}
      else
      _231_, _232_ = nil
      end
      if ((nil ~= _231_) and (nil ~= _232_)) then
        local k_10_auto = _231_
        local v_11_auto = _232_
        tbl_9_auto[k_10_auto] = v_11_auto
      end
    end
    lookup_by_pos = tbl_9_auto
  end
  local lookup_by_label
  do
    local tbl_9_auto = {}
    for pos, _235_ in pairs(lookup_by_pos) do
      local _each_236_ = _235_
      local label = _each_236_[1]
      local ch2 = _each_236_[2]
      local _237_, _238_ = label, {pos, ch2}
      if ((nil ~= _237_) and (nil ~= _238_)) then
        local k_10_auto = _237_
        local v_11_auto = _238_
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
local s = {["prev-dot-repeatable-search"] = {["x-mode?"] = nil, in1 = nil, in2 = nil, in3 = nil}, ["prev-search"] = {in1 = nil, in2 = nil}}
s.to = function(self, reverse_3f, invoked_in_x_mode_3f, dot_repeat_3f)
  local op_mode_3f = operator_pending_mode_3f()
  local change_op_3f = change_operation_3f()
  local delete_op_3f = delete_operation_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
  local _let_242_ = get_cycle_keys()
  local cycle_fwd_key = _let_242_[1]
  local cycle_bwd_key = _let_242_[2]
  local labels = get_labels()
  local jump_to_first_3f = (opts.jump_to_first_match and not op_mode_3f)
  local cmd_for_dot_repeat
  local _243_
  if invoked_in_x_mode_3f then
    if reverse_3f then
      _243_ = "X"
    else
      _243_ = "x"
    end
  else
    if reverse_3f then
      _243_ = "S"
    else
      _243_ = "s"
    end
  end
  cmd_for_dot_repeat = replace_keycodes(("<Plug>Lightspeed_dotrepeat_" .. _243_))
  local enter_repeat_3f = nil
  local new_search_3f = nil
  local x_mode_3f = nil
  local function cycle_through_match_groups(in2, positions_to_label, shortcuts, enter_repeat_3f0)
    local ret = nil
    local group_offset = 0
    local loop_3f = true
    while loop_3f do
      local _247_
      local function _248_()
        if dot_repeat_3f then
          return self["prev-dot-repeatable-search"].in3
        end
      end
      local function _249_()
        loop_3f = false
        ret = nil
        return nil
      end
      _247_ = (_248_() or get_input_and_clean_up() or _249_())
      if (nil ~= _247_) then
        local input = _247_
        if not ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          loop_3f = false
          ret = {group_offset, input}
        else
          local max_offset = math.floor((#positions_to_label / #labels))
          local _251_
          do
            local _250_ = input
            if (_250_ == cycle_fwd_key) then
              _251_ = inc
            else
              local _ = _250_
              _251_ = dec
            end
          end
          group_offset = clamp(_251_(group_offset), 0, max_offset)
          if opts.grey_out_search_area then
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
  local function save_state_for(_258_)
    local _arg_259_ = _258_
    local dot_repeat = _arg_259_["dot-repeat"]
    local enter_repeat = _arg_259_["enter-repeat"]
    if new_search_3f then
      if dot_repeatable_op_3f then
        if dot_repeat then
          dot_repeat["x-mode?"] = x_mode_3f
          self["prev-dot-repeatable-search"] = dot_repeat
          return nil
        end
      elseif enter_repeat then
        self["prev-search"] = enter_repeat
        return nil
      end
    end
  end
  local jump_with_wrap_21
  do
    local first_jump_3f = true
    local function _263_(target)
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
          local _267_ = string.sub(vim.fn.mode("t"), -1)
          if (_267_ == "v") then
            push_cursor_21("bwd")
          elseif (_267_ == "o") then
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
    jump_with_wrap_21 = _263_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_273_, ch2)
    local _arg_274_ = _273_
    local target_line = _arg_274_[1]
    local target_col = _arg_274_[2]
    local _ = _arg_274_[3]
    local target_pos = _arg_274_
    local orig_pos = get_cursor_pos()
    jump_with_wrap_21(target_pos)
    if new_search_3f then
      local ctrl_v = replace_keycodes("<c-v>")
      local forward_x_3f = (x_mode_3f and not reverse_3f)
      local backward_x_3f = (x_mode_3f and reverse_3f)
      local forced_motion = string.sub(vim.fn.mode("t"), -1)
      local from_pos = vim.tbl_map(dec, orig_pos)
      local to_pos
      local function _275_()
        if backward_x_3f then
          return inc(inc(target_col))
        elseif forward_x_3f then
          return inc(target_col)
        else
          return target_col
        end
      end
      to_pos = vim.tbl_map(dec, {target_line, _275_()})
      local function _277_()
        if reverse_3f then
          return to_pos
        else
          return from_pos
        end
      end
      local _let_276_ = _277_()
      local startline = _let_276_[1]
      local startcol = _let_276_[2]
      local start = _let_276_
      local function _279_()
        if reverse_3f then
          return from_pos
        else
          return to_pos
        end
      end
      local _let_278_ = _279_()
      local endline = _let_278_[1]
      local endcol = _let_278_[2]
      local _end = _let_278_
      if not change_op_3f then
        local _3fpos_to_highlight_at
        if op_mode_3f then
          if (forced_motion == ctrl_v) then
            _3fpos_to_highlight_at = {inc(startline), inc(math.min(startcol, endcol))}
          elseif not reverse_3f then
            _3fpos_to_highlight_at = orig_pos
          else
          _3fpos_to_highlight_at = nil
          end
        else
        _3fpos_to_highlight_at = nil
        end
        highlight_cursor(_3fpos_to_highlight_at)
      end
      if op_mode_3f then
        local inclusive_motion_3f = forward_x_3f
        local hl_group
        if (change_op_3f or delete_op_3f) then
          hl_group = hl.group["pending-change-op-area"]
        else
          hl_group = hl.group["pending-op-area"]
        end
        local function hl_range(start0, _end0)
          return vim.highlight.range(0, hl.ns, hl_group, start0, _end0)
        end
        local _284_ = forced_motion
        if (_284_ == ctrl_v) then
          for line = startline, endline do
            hl_range({line, math.min(startcol, endcol)}, {line, inc(math.max(startcol, endcol))})
          end
        elseif (_284_ == "V") then
          hl_range({startline, 0}, {endline, -1})
        elseif (_284_ == "v") then
          local function _285_()
            if inclusive_motion_3f then
              return endcol
            else
              return inc(endcol)
            end
          end
          hl_range(start, {endline, _285_()})
        elseif (_284_ == "o") then
          local function _286_()
            if inclusive_motion_3f then
              return inc(endcol)
            else
              return endcol
            end
          end
          hl_range(start, {endline, _286_()})
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
  if not dot_repeat_3f then
    if vim.fn.exists("#User#LightspeedEnter") then
      vim.cmd("doautocmd <nomodeline> User LightspeedEnter")
    end
    echo("")
    if opts.grey_out_search_area then
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
  local _295_
  if dot_repeat_3f then
    x_mode_3f = self["prev-dot-repeatable-search"]["x-mode?"]
    _295_ = self["prev-dot-repeatable-search"].in1
  else
    local _296_
    local function _297_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
      end
      do
      end
      if vim.fn.exists("#User#LightspeedLeave") then
        vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
      end
      return nil
    end
    _296_ = (get_input_and_clean_up() or _297_())
    if (nil ~= _296_) then
      local in0 = _296_
      enter_repeat_3f = (in0 == "\13")
      new_search_3f = not (enter_repeat_3f or dot_repeat_3f)
      x_mode_3f = (invoked_in_x_mode_3f or (in0 == x_mode_prefix_key))
      if enter_repeat_3f then
        local function _300_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          end
          do
            echo_no_prev_search()
          end
          do
          end
          if vim.fn.exists("#User#LightspeedLeave") then
            vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
          end
          return nil
        end
        _295_ = (self["prev-search"].in1 or _300_())
      elseif (x_mode_3f and not invoked_in_x_mode_3f) then
        local function _303_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          end
          do
          end
          do
          end
          if vim.fn.exists("#User#LightspeedLeave") then
            vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
          end
          return nil
        end
        _295_ = (get_input_and_clean_up() or _303_())
      else
        _295_ = in0
      end
    else
    _295_ = nil
    end
  end
  if (nil ~= _295_) then
    local in1 = _295_
    local prev_in2
    if enter_repeat_3f then
      prev_in2 = self["prev-search"].in2
    elseif dot_repeat_3f then
      prev_in2 = self["prev-dot-repeatable-search"].in2
    else
    prev_in2 = nil
    end
    local _310_
    local function _311_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        echo_not_found((in1 .. (prev_in2 or "")))
      end
      do
      end
      if vim.fn.exists("#User#LightspeedLeave") then
        vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
      end
      return nil
    end
    _310_ = (get_match_map_for(in1, reverse_3f) or _311_())
    if ((type(_310_) == "table") and (nil ~= (_310_)[1]) and (nil ~= (_310_)[2])) then
      local ch2 = (_310_)[1]
      local pos = (_310_)[2]
      local unique_match = _310_
      if (new_search_3f or (ch2 == prev_in2)) then
        do
          save_state_for({["dot-repeat"] = {in1 = in1, in2 = ch2, in3 = labels[1]}, ["enter-repeat"] = {in1 = in1, in2 = ch2}})
          jump_and_ignore_ch2_until_timeout_21(pos, ch2)
        end
        if vim.fn.exists("#User#LightspeedLeave") then
          vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
        end
        return nil
      else
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_not_found((in1 .. prev_in2))
        end
        do
        end
        if vim.fn.exists("#User#LightspeedLeave") then
          vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
        end
        return nil
      end
    elseif (nil ~= _310_) then
      local match_map = _310_
      local shortcuts = get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
      if new_search_3f then
        if opts.grey_out_search_area then
          grey_out_search_area(reverse_3f)
        end
        do
          for ch2, positions in pairs(match_map) do
            local _let_319_ = positions
            local first = _let_319_[1]
            local rest = {(table.unpack or unpack)(_let_319_, 2)}
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest
            else
              positions_to_label = positions
            end
            if (jump_to_first_3f or empty_3f(rest)) then
              set_beacon_at(first, in1, ch2, {["init-round?"] = true})
            end
            if not empty_3f(rest) then
              set_beacon_groups(ch2, positions_to_label, labels, shortcuts, {["init-round?"] = true})
            end
          end
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _324_
      local function _325_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
        end
        do
        end
        if vim.fn.exists("#User#LightspeedLeave") then
          vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
        end
        return nil
      end
      _324_ = (prev_in2 or get_input_and_clean_up() or _325_())
      if (nil ~= _324_) then
        local in2 = _324_
        local _328_
        if new_search_3f then
          _328_ = shortcuts[in2]
        else
        _328_ = nil
        end
        if ((type(_328_) == "table") and (nil ~= (_328_)[1]) and (nil ~= (_328_)[2])) then
          local pos = (_328_)[1]
          local ch2 = (_328_)[2]
          local shortcut = _328_
          do
            save_state_for({["dot-repeat"] = {in1 = in1, in2 = ch2, in3 = in2}, ["enter-repeat"] = {in1 = in1, in2 = ch2}})
            jump_with_wrap_21(pos)
          end
          if vim.fn.exists("#User#LightspeedLeave") then
            vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
          end
          return nil
        else
          local _ = _328_
          save_state_for({["dot-repeat"] = {in1 = in1, in2 = in2, in3 = labels[1]}, ["enter-repeat"] = {in1 = in1, in2 = in2}})
          local _331_
          local function _332_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
              echo_not_found((in1 .. in2))
            end
            do
            end
            if vim.fn.exists("#User#LightspeedLeave") then
              vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
            end
            return nil
          end
          _331_ = (match_map[in2] or _332_())
          if (nil ~= _331_) then
            local positions = _331_
            local _let_335_ = positions
            local first = _let_335_[1]
            local rest = {(table.unpack or unpack)(_let_335_, 2)}
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest
            else
              positions_to_label = positions
            end
            if (jump_to_first_3f or empty_3f(rest)) then
              jump_with_wrap_21(first)
            end
            if empty_3f(rest) then
              do
              end
              if vim.fn.exists("#User#LightspeedLeave") then
                vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
              end
              return nil
            else
              if not (dot_repeat_3f and self["prev-dot-repeatable-search"].in3) then
                if opts.grey_out_search_area then
                  grey_out_search_area(reverse_3f)
                end
                do
                  set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["repeat?"] = enter_repeat_3f})
                end
                highlight_cursor()
                vim.cmd("redraw")
              end
              local _341_
              local function _342_()
                if change_operation_3f() then
                  handle_interrupted_change_op_21()
                end
                do
                end
                do
                end
                if vim.fn.exists("#User#LightspeedLeave") then
                  vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
                end
                return nil
              end
              _341_ = (cycle_through_match_groups(in2, positions_to_label, shortcuts, enter_repeat_3f) or _342_())
              if ((type(_341_) == "table") and (nil ~= (_341_)[1]) and (nil ~= (_341_)[2])) then
                local group_offset = (_341_)[1]
                local in3 = (_341_)[2]
                if (dot_repeatable_op_3f and not dot_repeat_3f) then
                  if (group_offset == 0) then
                    self["prev-dot-repeatable-search"].in3 = in3
                  else
                    self["prev-dot-repeatable-search"].in3 = nil
                  end
                end
                local _347_
                do
                  local _348_ = in3
                  if _348_ then
                    local _349_ = reverse_lookup(labels)[_348_]
                    if _349_ then
                      local _350_ = ((group_offset * #labels) + _349_)
                      if _350_ then
                        _347_ = positions_to_label[_350_]
                      else
                        _347_ = _350_
                      end
                    else
                      _347_ = _349_
                    end
                  else
                    _347_ = _348_
                  end
                end
                if (nil ~= _347_) then
                  local pos_of_active_label = _347_
                  do
                    jump_with_wrap_21(pos_of_active_label)
                  end
                  if vim.fn.exists("#User#LightspeedLeave") then
                    vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
                  end
                  return nil
                else
                  local _0 = _347_
                  if jump_to_first_3f then
                    do
                      vim.fn.feedkeys(in3, "i")
                    end
                    if vim.fn.exists("#User#LightspeedLeave") then
                      vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
                    end
                    return nil
                  else
                    if change_operation_3f() then
                      handle_interrupted_change_op_21()
                    end
                    do
                    end
                    do
                    end
                    if vim.fn.exists("#User#LightspeedLeave") then
                      vim.cmd("doautocmd <nomodeline> User LightspeedLeave")
                    end
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
    local _let_367_ = vim.split(opt, ".", true)
    local _0 = _let_367_[1]
    local scope = _let_367_[2]
    local name = _let_367_[3]
    local _368_
    if (opt == "vim.wo.scrolloff") then
      _368_ = api.nvim_eval("&l:scrolloff")
    else
      _368_ = _G.vim[scope][name]
    end
    saved_editor_opts[opt] = _368_
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_370_ = vim.split(opt, ".", true)
    local _ = _let_370_[1]
    local scope = _let_370_[2]
    local name = _let_370_[3]
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
  local plug_keys = {{"n", "<Plug>Lightspeed_s", "s:to(false)"}, {"n", "<Plug>Lightspeed_S", "s:to(true)"}, {"x", "<Plug>Lightspeed_s", "s:to(false)"}, {"x", "<Plug>Lightspeed_S", "s:to(true)"}, {"o", "<Plug>Lightspeed_s", "s:to(false)"}, {"o", "<Plug>Lightspeed_S", "s:to(true)"}, {"n", "<Plug>Lightspeed_x", "s:to(false, true)"}, {"n", "<Plug>Lightspeed_X", "s:to(true, true)"}, {"x", "<Plug>Lightspeed_x", "s:to(false, true)"}, {"x", "<Plug>Lightspeed_X", "s:to(true, true)"}, {"o", "<Plug>Lightspeed_x", "s:to(false, true)"}, {"o", "<Plug>Lightspeed_X", "s:to(true, true)"}, {"n", "<Plug>Lightspeed_f", "ft:to(false)"}, {"n", "<Plug>Lightspeed_F", "ft:to(true)"}, {"x", "<Plug>Lightspeed_f", "ft:to(false)"}, {"x", "<Plug>Lightspeed_F", "ft:to(true)"}, {"o", "<Plug>Lightspeed_f", "ft:to(false)"}, {"o", "<Plug>Lightspeed_F", "ft:to(true)"}, {"x", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"x", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"n", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"n", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"o", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"o", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_s", "s:to(false, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_S", "s:to(true, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_x", "s:to(false, true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_X", "s:to(true, true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_f", "ft:to(false, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_F", "ft:to(true, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_t", "ft:to(false, true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_T", "ft:to(true, true, true)"}}
  for _, _371_ in ipairs(plug_keys) do
    local _each_372_ = _371_
    local mode = _each_372_[1]
    local lhs = _each_372_[2]
    local rhs_call = _each_372_[3]
    api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
  end
  return nil
end
local function set_default_keymaps()
  local default_keymaps = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _373_ in ipairs(default_keymaps) do
    local _each_374_ = _373_
    local mode = _each_374_[1]
    local lhs = _each_374_[2]
    local rhs = _each_374_[3]
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
return {ft = ft, init_highlight = init_highlight, opts = opts, restore_editor_opts = restore_editor_opts, s = s, save_editor_opts = save_editor_opts, set_default_keymaps = set_default_keymaps, set_temporary_editor_opts = set_temporary_editor_opts, setup = setup}
