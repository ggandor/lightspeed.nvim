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
  local tbl_10_auto = {}
  for k, v in ipairs(tbl) do
    local _2_, _3_ = v, k
    if ((nil ~= _2_) and (nil ~= _3_)) then
      local k_11_auto = _2_
      local v_12_auto = _3_
      tbl_10_auto[k_11_auto] = v_12_auto
    end
  end
  return tbl_10_auto
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
local opts = {jump_to_first_match = true, jump_on_partial_input_safety_timeout = 400, highlight_unique_chars = false, grey_out_search_area = true, disable_hlsearch = true, match_only_the_start_of_same_char_seqs = true, limit_ft_matches = 5, x_mode_prefix_key = "<c-x>", substitute_chars = {["\13"] = "\194\172"}, instant_repeat_fwd_key = nil, instant_repeat_bwd_key = nil, cycle_group_fwd_key = nil, cycle_group_bwd_key = nil, labels = nil}
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
  api.nvim_buf_clear_namespace(0, self.ns, 0, -1)
  if opts.disable_hlsearch then
    return vim.cmd("let &hlsearch=&hlsearch")
  end
end
hl = {group = {label = "LightspeedLabel", ["label-distant"] = "LightspeedLabelDistant", ["label-overlapped"] = "LightspeedLabelOverlapped", ["label-distant-overlapped"] = "LightspeedLabelDistantOverlapped", shortcut = "LightspeedShortcut", ["shortcut-overlapped"] = "LightspeedShortcutOverlapped", ["masked-ch"] = "LightspeedMaskedChar", ["unlabeled-match"] = "LightspeedUnlabeledMatch", ["one-char-match"] = "LightspeedOneCharMatch", ["unique-ch"] = "LightspeedUniqueChar", ["pending-op-area"] = "LightspeedPendingOpArea", ["pending-change-op-area"] = "LightspeedPendingChangeOpArea", greywash = "LightspeedGreyWash", cursor = "LightspeedCursor"}, ns = api.nvim_create_namespace(""), ["add-hl"] = _11_, ["set-extmark"] = _12_, cleanup = _13_}
local function init_highlight()
  local bg = vim.o.background
  local groupdefs
  local _16_
  do
    local _15_ = bg
    if (_15_ == "light") then
      _16_ = "#f02077"
    else
      local _ = _15_
      _16_ = "#ff2f87"
    end
  end
  local _21_
  do
    local _20_ = bg
    if (_20_ == "light") then
      _21_ = "#ff4090"
    else
      local _ = _20_
      _21_ = "#e01067"
    end
  end
  local _26_
  do
    local _25_ = bg
    if (_25_ == "light") then
      _26_ = "#399d9f"
    else
      local _ = _25_
      _26_ = "#99ddff"
    end
  end
  local _31_
  do
    local _30_ = bg
    if (_30_ == "light") then
      _31_ = "Blue"
    else
      local _ = _30_
      _31_ = "Cyan"
    end
  end
  local _36_
  do
    local _35_ = bg
    if (_35_ == "light") then
      _36_ = "#59bdbf"
    else
      local _ = _35_
      _36_ = "#79bddf"
    end
  end
  local _41_
  do
    local _40_ = bg
    if (_40_ == "light") then
      _41_ = "Cyan"
    else
      local _ = _40_
      _41_ = "Blue"
    end
  end
  local _46_
  do
    local _45_ = bg
    if (_45_ == "light") then
      _46_ = "#cc9999"
    else
      local _ = _45_
      _46_ = "#b38080"
    end
  end
  local _51_
  do
    local _50_ = bg
    if (_50_ == "light") then
      _51_ = "#272020"
    else
      local _ = _50_
      _51_ = "#f3ecec"
    end
  end
  local _56_
  do
    local _55_ = bg
    if (_55_ == "light") then
      _56_ = "Black"
    else
      local _ = _55_
      _56_ = "White"
    end
  end
  local _61_
  do
    local _60_ = bg
    if (_60_ == "light") then
      _61_ = "#f02077"
    else
      local _ = _60_
      _61_ = "#ff2f87"
    end
  end
  groupdefs = {{hl.group.label, {guifg = _16_, ctermfg = "Red", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["label-overlapped"], {guifg = _21_, ctermfg = "Magenta", gui = "underline", cterm = "underline"}}, {hl.group["label-distant"], {guifg = _26_, ctermfg = _31_, gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["label-distant-overlapped"], {guifg = _36_, ctermfg = _41_, gui = "underline", cterm = "underline"}}, {hl.group.shortcut, {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold,underline", cterm = "bold,underline"}}, {hl.group["one-char-match"], {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White", gui = "bold", cterm = "bold"}}, {hl.group["masked-ch"], {guifg = _46_, ctermfg = "DarkGrey"}}, {hl.group["unlabeled-match"], {guifg = _51_, ctermfg = _56_, gui = "bold", cterm = "bold"}}, {hl.group["pending-op-area"], {guibg = "#f00077", ctermbg = "Red", guifg = "#ffffff", ctermfg = "White"}}, {hl.group["pending-change-op-area"], {guifg = _61_, ctermfg = "Red", gui = "strikethrough", cterm = "strikethrough"}}, {hl.group.greywash, {guifg = "#777777", ctermfg = "Grey"}}}
  for _, _65_ in ipairs(groupdefs) do
    local _each_66_ = _65_
    local group = _each_66_[1]
    local attrs = _each_66_[2]
    local attrs_str
    local _67_
    do
      local tbl_13_auto = {}
      for k, v in pairs(attrs) do
        tbl_13_auto[(#tbl_13_auto + 1)] = (k .. "=" .. v)
      end
      _67_ = tbl_13_auto
    end
    attrs_str = table.concat(_67_, " ")
    vim.cmd(("highlight default " .. group .. " " .. attrs_str))
  end
  for _, _68_ in ipairs({{hl.group["unique-ch"], hl.group["unlabeled-match"]}, {hl.group["shortcut-overlapped"], hl.group.shortcut}, {hl.group.cursor, "Cursor"}}) do
    local _each_69_ = _68_
    local from_group = _each_69_[1]
    local to_group = _each_69_[2]
    vim.cmd(("highlight default link " .. from_group .. " " .. to_group))
  end
  return nil
end
init_highlight()
local function add_highlight_autocmds()
  vim.cmd("augroup LightspeedInitHighlight")
  vim.cmd("autocmd!")
  vim.cmd("autocmd ColorScheme * lua require'lightspeed'.init_highlight()")
  return vim.cmd("augroup end")
end
add_highlight_autocmds()
local function grey_out_search_area(reverse_3f)
  local _let_70_ = vim.tbl_map(dec, get_cursor_pos())
  local curline = _let_70_[1]
  local curcol = _let_70_[2]
  local _let_71_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
  local win_top = _let_71_[1]
  local win_bot = _let_71_[2]
  local function _73_()
    if reverse_3f then
      return {{win_top, 0}, {curline, curcol}}
    else
      return {{curline, inc(curcol)}, {win_bot, -1}}
    end
  end
  local _let_72_ = _73_()
  local start = _let_72_[1]
  local finish = _let_72_[2]
  return vim.highlight.range(0, hl.ns, hl.group.greywash, start, finish)
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local _75_
  do
    local _74_ = direction
    if (_74_ == "fwd") then
      _75_ = "W"
    elseif (_74_ == "bwd") then
      _75_ = "bW"
    else
    _75_ = nil
    end
  end
  return vim.fn.search("\\_.", _75_, __fnl_global___3fstopline)
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function force_matchparen_refresh()
  vim.cmd("silent! doautocmd matchparen CursorMoved")
  return vim.cmd("silent! doautocmd matchup_matchparen CursorMoved")
end
local function onscreen_match_positions(pattern, reverse_3f, _79_)
  local _arg_80_ = _79_
  local ft_search_3f = _arg_80_["ft-search?"]
  local limit = _arg_80_["limit"]
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f then
    opts0 = "b"
  else
    opts0 = ""
  end
  local stopline
  local function _82_()
    if reverse_3f then
      return "w0"
    else
      return "w$"
    end
  end
  stopline = vim.fn.line(_82_())
  local cleanup
  local function _83_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _83_
  local non_editable_width = dec(leftmost_editable_wincol())
  local col_in_edit_area = (vim.fn.wincol() - non_editable_width)
  local left_bound = (vim.fn.col(".") - dec(col_in_edit_area))
  local window_width = api.nvim_win_get_width(0)
  local right_bound = (left_bound + dec((window_width - non_editable_width - 1)))
  local function skip_to_fold_edge_21()
    local _84_
    local _85_
    if reverse_3f then
      _85_ = vim.fn.foldclosed
    else
      _85_ = vim.fn.foldclosedend
    end
    _84_ = _85_(vim.fn.line("."))
    if (_84_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _84_) then
      local fold_edge = _84_
      vim.fn.cursor(fold_edge, 0)
      local function _87_()
        if reverse_3f then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _87_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_onscreen_pos_21()
    local _local_89_ = get_cursor_pos()
    local line = _local_89_[1]
    local col = _local_89_[2]
    local from_pos = _local_89_
    local _90_
    if (col < left_bound) then
      if reverse_3f then
        if (dec(line) >= stopline) then
          _90_ = {dec(line), right_bound}
        else
        _90_ = nil
        end
      else
        _90_ = {line, left_bound}
      end
    elseif (col > right_bound) then
      if reverse_3f then
        _90_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _90_ = {inc(line), left_bound}
        else
        _90_ = nil
        end
      end
    else
    _90_ = nil
    end
    if (nil ~= _90_) then
      local to_pos = _90_
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
      local _98_
      local function _99_()
        if match_at_curpos_3f then
          return "c"
        else
          return ""
        end
      end
      _98_ = vim.fn.searchpos(pattern, (opts0 .. _99_()), stopline)
      if ((_G.type(_98_) == "table") and ((_98_)[1] == 0) and true) then
        local _ = (_98_)[2]
        return cleanup()
      elseif ((_G.type(_98_) == "table") and (nil ~= (_98_)[1]) and (nil ~= (_98_)[2])) then
        local line = (_98_)[1]
        local col = (_98_)[2]
        local pos = _98_
        if ft_search_3f then
          match_count = (match_count + 1)
          return pos
        else
          local _100_ = skip_to_fold_edge_21()
          if (_100_ == "moved-the-cursor") then
            return rec(false)
          elseif (_100_ == "not-in-fold") then
            if (vim.wo.wrap or (function(_101_,_102_,_103_) return (_101_ <= _102_) and (_102_ <= _103_) end)(left_bound,col,right_bound)) then
              match_count = (match_count + 1)
              return pos
            else
              local _104_ = skip_to_next_onscreen_pos_21()
              if (_104_ == "moved-the-cursor") then
                return rec(true)
              else
                local _ = _104_
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
    local _112_
    do
      local _111_ = unique_chars[ch]
      if (_111_ == nil) then
        _112_ = pos
      else
        local _ = _111_
        _112_ = false
      end
    end
    unique_chars[ch] = _112_
  end
  for ch, pos_or_false in pairs(unique_chars) do
    if pos_or_false then
      local _let_116_ = pos_or_false
      local line = _let_116_[1]
      local col = _let_116_[2]
      hl["set-extmark"](hl, dec(line), dec(col), {virt_text = {{ch, hl.group["unique-ch"]}}, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local function highlight_cursor(_3fpos)
  local _let_118_ = (_3fpos or get_cursor_pos())
  local line = _let_118_[1]
  local col = _let_118_[2]
  local pos = _let_118_
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
local function get_input_and_clean_up()
  local ok_3f, res = getchar_as_str()
  hl:cleanup()
  if (ok_3f and (res ~= replace_keycodes("<esc>"))) then
    return res
  else
    if change_operation_3f() then
      handle_interrupted_change_op_21()
    end
    do
    end
    return nil
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
local ft = {["instant-repeat?"] = nil, ["started-reverse?"] = nil, ["prev-reverse?"] = nil, ["prev-t-like?"] = nil, ["prev-search"] = nil, ["prev-dot-repeatable-search"] = nil, stack = {}}
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
  if self["instant-repeat?"] then
    if revert_3f then
      if t_like_3f then
        count = 1
      else
        count = 0
      end
    else
      if (t_like_3f and not switched_directions_3f) then
        count = inc(vim.v.count1)
      else
        count = vim.v.count1
      end
    end
  else
    count = vim.v.count1
  end
  local _let_131_ = vim.tbl_map(replace_keycodes, {opts.instant_repeat_fwd_key, opts.instant_repeat_bwd_key})
  local repeat_key = _let_131_[1]
  local revert_key = _let_131_[2]
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
  if not (self["instant-repeat?"] or dot_repeat_3f) then
    echo("")
    highlight_cursor()
    vim.cmd("redraw")
  end
  local enter_repeat_3f = nil
  local _134_
  if self["instant-repeat?"] then
    _134_ = self["prev-search"]
  elseif dot_repeat_3f then
    _134_ = self["prev-dot-repeatable-search"]
  else
    local _135_ = get_input_and_clean_up()
    if (_135_ == "\13") then
      enter_repeat_3f = true
      local function _136_()
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_no_prev_search()
        end
        return nil
      end
      _134_ = (self["prev-search"] or _136_())
    elseif (nil ~= _135_) then
      local _in = _135_
      _134_ = _in
    else
    _134_ = nil
    end
  end
  if (nil ~= _134_) then
    local in1 = _134_
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
    local i = 0
    local match_pos = nil
    local function _144_()
      local pattern = ("\\V" .. in1:gsub("\\", "\\\\"))
      local limit
      if opts.limit_ft_matches then
        limit = (count + opts.limit_ft_matches)
      else
      limit = nil
      end
      return onscreen_match_positions(pattern, reverse_3f0, {["ft-search?"] = true, limit = limit})
    end
    for _142_ in _144_() do
      local _each_145_ = _142_
      local line = _each_145_[1]
      local col = _each_145_[2]
      local pos = _each_145_
      i = (i + 1)
      if (i <= count) then
        match_pos = pos
      else
        if not op_mode_3f then
          hl["add-hl"](hl, hl.group["one-char-match"], dec(line), dec(col), col)
        end
      end
    end
    if (i == 0) then
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        echo_not_found(in1)
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
          local function _150_()
            if reverse_3f0 then
              return "fwd"
            else
              return "bwd"
            end
          end
          push_cursor_21(_150_())
        end
        if (op_mode_3f_4_auto and not reverse_3f0 and true) then
          local _152_ = string.sub(vim.fn.mode("t"), -1)
          if (_152_ == "v") then
            push_cursor_21("bwd")
          elseif (_152_ == "o") then
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
        local function _159_()
          if t_like_3f then
            return "t"
          else
            return "f"
          end
        end
        repeat_3f = ((in2 == repeat_key) or string.match(vim.fn.maparg(in2, mode), ("<Plug>Lightspeed_" .. _159_())))
        local revert_3f0
        local function _160_()
          if t_like_3f then
            return "T"
          else
            return "F"
          end
        end
        revert_3f0 = ((in2 == revert_key) or string.match(vim.fn.maparg(in2, mode), ("<Plug>Lightspeed_" .. _160_())))
        hl:cleanup()
        self["instant-repeat?"] = (ok_3f and (repeat_3f or revert_3f0))
        if not self["instant-repeat?"] then
          self.stack = {}
          local _161_
          if ok_3f then
            _161_ = in2
          else
            _161_ = replace_keycodes("<esc>")
          end
          return vim.fn.feedkeys(_161_, "i")
        else
          if revert_3f0 then
            local _163_ = table.remove(self.stack)
            if (nil ~= _163_) then
              local prev_pos = _163_
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
  local function _170_()
    if opts.jump_to_first_match then
      return {"s", "f", "n", "/", "u", "t", "q", "S", "F", "G", "H", "L", "M", "N", "?", "U", "R", "Z", "T", "Q"}
    else
      return {"f", "j", "d", "k", "s", "l", "a", ";", "e", "i", "w", "o", "g", "h", "v", "n", "c", "m", "z", "."}
    end
  end
  return (opts.labels or _170_())
end
local function get_cycle_keys()
  local function _171_()
    if opts.jump_to_first_match then
      return "<tab>"
    else
      return "<space>"
    end
  end
  local function _172_()
    if opts.jump_to_first_match then
      return "<s-tab>"
    else
      return "<tab>"
    end
  end
  return vim.tbl_map(replace_keycodes, {(opts.cycle_group_fwd_key or _171_()), (opts.cycle_group_bwd_key or _172_())})
end
local function get_match_map_for(ch1, reverse_3f)
  local match_map = {}
  local prefix = "\\V\\C"
  local input = ch1:gsub("\\", "\\\\")
  local pattern = (prefix .. input .. "\\_.")
  local match_count = 0
  local prev = {}
  for _173_ in onscreen_match_positions(pattern, reverse_3f, {}) do
    local _each_174_ = _173_
    local line = _each_174_[1]
    local col = _each_174_[2]
    local pos = _each_174_
    local overlap_with_prev_3f
    local _175_
    if reverse_3f then
      _175_ = dec
    else
      _175_ = inc
    end
    overlap_with_prev_3f = ((line == prev.line) and (col == _175_(prev.col)))
    local ch2 = (char_at_pos(pos, {["char-offset"] = 1}) or "\13")
    local same_pair_3f = (ch2 == prev.ch2)
    local _177_
    if not opts.match_only_the_start_of_same_char_seqs then
      _177_ = prev["skipped?"]
    else
    _177_ = nil
    end
    if (_177_ or not (overlap_with_prev_3f and same_pair_3f)) then
      local partially_covered_3f = (overlap_with_prev_3f and not reverse_3f)
      if not match_map[ch2] then
        match_map[ch2] = {}
      end
      table.insert(match_map[ch2], {line, col, partially_covered_3f, __fnl_global___3fch3})
      if (overlap_with_prev_3f and reverse_3f) then
        last(match_map[prev.ch2])[3] = true
      end
      prev = {line = line, col = col, ch2 = ch2, ["skipped?"] = false}
      match_count = (match_count + 1)
    else
      prev = {line = line, col = col, ch2 = ch2, ["skipped?"] = true}
    end
  end
  local _182_ = match_count
  if (_182_ == 0) then
    return nil
  elseif (_182_ == 1) then
    local ch2 = vim.tbl_keys(match_map)[1]
    local pos = vim.tbl_values(match_map)[1][1]
    return {ch2, pos}
  else
    local _ = _182_
    return match_map
  end
end
local function set_beacon_at(_184_, ch1, ch2, _186_)
  local _arg_185_ = _184_
  local line = _arg_185_[1]
  local col = _arg_185_[2]
  local partially_covered_3f = _arg_185_[3]
  local pos = _arg_185_
  local _arg_187_ = _186_
  local labeled_3f = _arg_187_["labeled?"]
  local init_round_3f = _arg_187_["init-round?"]
  local repeat_3f = _arg_187_["repeat?"]
  local distant_3f = _arg_187_["distant?"]
  local shortcut_3f = _arg_187_["shortcut?"]
  local ch10 = (opts.substitute_chars[ch1] or ch1)
  local ch20
  local _188_
  if not labeled_3f then
    _188_ = opts.substitute_chars[ch2]
  else
  _188_ = nil
  end
  ch20 = (_188_ or ch2)
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
  local function _197_()
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
  local _let_194_ = _197_()
  local startcol = _let_194_[1]
  local chunk1 = _let_194_[2]
  local _3fchunk2 = _let_194_[3]
  return hl["set-extmark"](hl, dec(line), dec(startcol), {virt_text = {chunk1, _3fchunk2}, virt_text_pos = "overlay"})
end
local function set_beacon_groups(ch2, positions, labels, shortcuts, _198_)
  local _arg_199_ = _198_
  local group_offset = _arg_199_["group-offset"]
  local init_round_3f = _arg_199_["init-round?"]
  local repeat_3f = _arg_199_["repeat?"]
  local group_offset0 = (group_offset or 0)
  local _7clabels_7c = #labels
  local set_group
  local function _200_(start, distant_3f)
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
      set_beacon_at(pos, ch2, label, {["labeled?"] = true, ["init-round?"] = init_round_3f, ["distant?"] = distant_3f, ["repeat?"] = repeat_3f, ["shortcut?"] = shortcut_3f})
    end
    return nil
  end
  set_group = _200_
  local start = inc((group_offset0 * _7clabels_7c))
  local _end = dec((start + _7clabels_7c))
  set_group(start, false)
  return set_group((start + _7clabels_7c), true)
end
local function get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
  local collides_with_a_ch2_3f
  local function _202_(_241)
    return vim.tbl_contains(vim.tbl_keys(match_map), _241)
  end
  collides_with_a_ch2_3f = _202_
  local by_distance_from_cursor
  local function _209_(_203_, _206_)
    local _arg_204_ = _203_
    local _arg_205_ = _arg_204_[1]
    local l1 = _arg_205_[1]
    local c1 = _arg_205_[2]
    local _ = _arg_204_[2]
    local _0 = _arg_204_[3]
    local _arg_207_ = _206_
    local _arg_208_ = _arg_207_[1]
    local l2 = _arg_208_[1]
    local c2 = _arg_208_[2]
    local _1 = _arg_207_[2]
    local _2 = _arg_207_[3]
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
  by_distance_from_cursor = _209_
  local shortcuts = {}
  for ch2, positions in pairs(match_map) do
    for i, pos in ipairs(positions) do
      local labeled_pos_3f = not ((#positions == 1) or (jump_to_first_3f and (i == 1)))
      if labeled_pos_3f then
        local _213_
        local _214_
        if jump_to_first_3f then
          _214_ = dec(i)
        else
          _214_ = i
        end
        _213_ = labels[_214_]
        if (nil ~= _213_) then
          local label = _213_
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
    local tbl_10_auto = {}
    for _, _219_ in ipairs(shortcuts) do
      local _each_220_ = _219_
      local pos = _each_220_[1]
      local label = _each_220_[2]
      local ch2 = _each_220_[3]
      local _221_, _222_ = nil, nil
      if not labels_used_up[label] then
        labels_used_up[label] = true
        _221_, _222_ = pos, {label, ch2}
      else
      _221_, _222_ = nil
      end
      if ((nil ~= _221_) and (nil ~= _222_)) then
        local k_11_auto = _221_
        local v_12_auto = _222_
        tbl_10_auto[k_11_auto] = v_12_auto
      end
    end
    lookup_by_pos = tbl_10_auto
  end
  local lookup_by_label
  do
    local tbl_10_auto = {}
    for pos, _225_ in pairs(lookup_by_pos) do
      local _each_226_ = _225_
      local label = _each_226_[1]
      local ch2 = _each_226_[2]
      local _227_, _228_ = label, {pos, ch2}
      if ((nil ~= _227_) and (nil ~= _228_)) then
        local k_11_auto = _227_
        local v_12_auto = _228_
        tbl_10_auto[k_11_auto] = v_12_auto
      end
    end
    lookup_by_label = tbl_10_auto
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
local s = {["prev-search"] = {in1 = nil, in2 = nil}, ["prev-dot-repeatable-search"] = {in1 = nil, in2 = nil, in3 = nil, ["x-mode?"] = nil}}
s.to = function(self, reverse_3f, arg_x_mode_3f, dot_repeat_3f)
  local op_mode_3f = operator_pending_mode_3f()
  local change_op_3f = change_operation_3f()
  local delete_op_3f = delete_operation_3f()
  local dot_repeatable_op_3f = dot_repeatable_operation_3f()
  local x_mode_prefix_key = replace_keycodes((opts.x_mode_prefix_key or opts.full_inclusive_prefix_key))
  local _let_232_ = get_cycle_keys()
  local cycle_fwd_key = _let_232_[1]
  local cycle_bwd_key = _let_232_[2]
  local labels = get_labels()
  local label_indexes = reverse_lookup(labels)
  local jump_to_first_3f = (opts.jump_to_first_match and not op_mode_3f)
  local cmd_for_dot_repeat
  local function _235_()
    if arg_x_mode_3f then
      if reverse_3f then
        return "X"
      else
        return "x"
      end
    else
      if reverse_3f then
        return "S"
      else
        return "s"
      end
    end
  end
  cmd_for_dot_repeat = replace_keycodes(("<Plug>Lightspeed_dotrepeat_" .. _235_()))
  local enter_repeat_3f = nil
  local new_search_3f = nil
  local x_mode_3f = nil
  local restore_scrolloff_cmd = nil
  local function switch_off_scrolloff()
    if jump_to_first_3f then
      local _3floc
      if (api.nvim_eval("&l:scrolloff") ~= -1) then
        _3floc = "l:"
      else
        _3floc = ""
      end
      local saved_val = api.nvim_eval(("&" .. _3floc .. "scrolloff"))
      restore_scrolloff_cmd = ("let &" .. _3floc .. "scrolloff=" .. saved_val)
      return vim.cmd(("let &" .. _3floc .. "scrolloff=0"))
    end
  end
  local function restore_scrolloff()
    if jump_to_first_3f then
      return vim.cmd((restore_scrolloff_cmd or ""))
    end
  end
  local function cycle_through_match_groups(in2, positions_to_label, shortcuts, enter_repeat_3f0)
    local ret = nil
    local group_offset = 0
    local loop_3f = true
    while loop_3f do
      local _239_
      local _240_
      if dot_repeat_3f then
        _240_ = self["prev-dot-repeatable-search"].in3
      else
      _240_ = nil
      end
      local function _242_()
        loop_3f = false
        restore_scrolloff()
        ret = nil
        return nil
      end
      _239_ = (_240_ or get_input_and_clean_up() or _242_())
      if (nil ~= _239_) then
        local input = _239_
        if not ((input == cycle_fwd_key) or (input == cycle_bwd_key)) then
          loop_3f = false
          ret = {group_offset, input}
        else
          local max_offset = math.floor((#positions_to_label / #labels))
          local _244_
          do
            local _243_ = input
            if (_243_ == cycle_fwd_key) then
              _244_ = inc
            else
              local _ = _243_
              _244_ = dec
            end
          end
          group_offset = clamp(_244_(group_offset), 0, max_offset)
          if opts.grey_out_search_area then
            grey_out_search_area(reverse_3f)
          end
          do
            set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["group-offset"] = group_offset, ["repeat?"] = enter_repeat_3f0})
          end
          if opts.disable_hlsearch then
            vim.cmd("nohlsearch")
          end
          highlight_cursor()
          vim.cmd("redraw")
        end
      end
    end
    return ret
  end
  local function save_state_for(_252_)
    local _arg_253_ = _252_
    local enter_repeat = _arg_253_["enter-repeat"]
    local dot_repeat = _arg_253_["dot-repeat"]
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
    local function _257_(target)
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
          local _261_ = string.sub(vim.fn.mode("t"), -1)
          if (_261_ == "v") then
            push_cursor_21("bwd")
          elseif (_261_ == "o") then
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
    jump_with_wrap_21 = _257_
  end
  local function jump_and_ignore_ch2_until_timeout_21(_267_, ch2)
    local _arg_268_ = _267_
    local target_line = _arg_268_[1]
    local target_col = _arg_268_[2]
    local _ = _arg_268_[3]
    local target_pos = _arg_268_
    local orig_pos = get_cursor_pos()
    jump_with_wrap_21(target_pos)
    if new_search_3f then
      local ctrl_v = replace_keycodes("<c-v>")
      local forward_x_3f = (x_mode_3f and not reverse_3f)
      local backward_x_3f = (x_mode_3f and reverse_3f)
      local forced_motion = string.sub(vim.fn.mode("t"), -1)
      local from_pos = vim.tbl_map(dec, orig_pos)
      local to_pos
      local function _269_()
        if backward_x_3f then
          return inc(inc(target_col))
        elseif forward_x_3f then
          return inc(target_col)
        else
          return target_col
        end
      end
      to_pos = vim.tbl_map(dec, {target_line, _269_()})
      local function _271_()
        if reverse_3f then
          return to_pos
        else
          return from_pos
        end
      end
      local _let_270_ = _271_()
      local startline = _let_270_[1]
      local startcol = _let_270_[2]
      local start = _let_270_
      local function _273_()
        if reverse_3f then
          return from_pos
        else
          return to_pos
        end
      end
      local _let_272_ = _273_()
      local endline = _let_272_[1]
      local endcol = _let_272_[2]
      local _end = _let_272_
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
        local _278_ = forced_motion
        if (_278_ == ctrl_v) then
          for line = startline, endline do
            hl_range({line, math.min(startcol, endcol)}, {line, inc(math.max(startcol, endcol))})
          end
        elseif (_278_ == "V") then
          hl_range({startline, 0}, {endline, -1})
        elseif (_278_ == "v") then
          local function _279_()
            if inclusive_motion_3f then
              return endcol
            else
              return inc(endcol)
            end
          end
          hl_range(start, {endline, _279_()})
        elseif (_278_ == "o") then
          local function _280_()
            if inclusive_motion_3f then
              return inc(endcol)
            else
              return endcol
            end
          end
          hl_range(start, {endline, _280_()})
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
    echo("")
    if opts.grey_out_search_area then
      grey_out_search_area(reverse_3f)
    end
    do
      if opts.highlight_unique_chars then
        highlight_unique_chars(reverse_3f)
      end
    end
    if opts.disable_hlsearch then
      vim.cmd("nohlsearch")
    end
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _289_
  if dot_repeat_3f then
    x_mode_3f = self["prev-dot-repeatable-search"]["x-mode?"]
    _289_ = self["prev-dot-repeatable-search"].in1
  else
    local _290_ = get_input_and_clean_up()
    if (nil ~= _290_) then
      local in0 = _290_
      enter_repeat_3f = (in0 == "\13")
      new_search_3f = not (enter_repeat_3f or dot_repeat_3f)
      x_mode_3f = (arg_x_mode_3f or (in0 == x_mode_prefix_key))
      if enter_repeat_3f then
        local function _291_()
          if change_operation_3f() then
            handle_interrupted_change_op_21()
          end
          do
            echo_no_prev_search()
          end
          return nil
        end
        _289_ = (self["prev-search"].in1 or _291_())
      elseif (x_mode_3f and not arg_x_mode_3f) then
        _289_ = get_input_and_clean_up()
      else
        _289_ = in0
      end
    else
    _289_ = nil
    end
  end
  if (nil ~= _289_) then
    local in1 = _289_
    local _296_
    local function _297_()
      if change_operation_3f() then
        handle_interrupted_change_op_21()
      end
      do
        local function _299_()
          if enter_repeat_3f then
            return (in1 .. self["prev-search"].in2)
          elseif dot_repeat_3f then
            return (in1 .. self["prev-dot-repeatable-search"].in2)
          else
            return in1
          end
        end
        echo_not_found(_299_())
      end
      return nil
    end
    _296_ = (get_match_map_for(in1, reverse_3f) or _297_())
    if ((_G.type(_296_) == "table") and (nil ~= (_296_)[1]) and (nil ~= (_296_)[2])) then
      local ch2 = (_296_)[1]
      local pos = (_296_)[2]
      if (new_search_3f or (enter_repeat_3f and (ch2 == self["prev-search"].in2)) or (dot_repeat_3f and (ch2 == self["prev-dot-repeatable-search"].in2))) then
        save_state_for({["enter-repeat"] = {in1 = in1, in2 = ch2}, ["dot-repeat"] = {in1 = in1, in2 = ch2, in3 = labels[1]}})
        return jump_and_ignore_ch2_until_timeout_21(pos, ch2)
      else
        if change_operation_3f() then
          handle_interrupted_change_op_21()
        end
        do
          echo_not_found((in1 .. ch2))
        end
        return nil
      end
    elseif (nil ~= _296_) then
      local match_map = _296_
      local shortcuts = get_shortcuts(match_map, labels, reverse_3f, jump_to_first_3f)
      if new_search_3f then
        if opts.grey_out_search_area then
          grey_out_search_area(reverse_3f)
        end
        do
          for ch2, positions in pairs(match_map) do
            local _let_303_ = positions
            local first = _let_303_[1]
            local rest = {(table.unpack or unpack)(_let_303_, 2)}
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
        if opts.disable_hlsearch then
          vim.cmd("nohlsearch")
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _309_
      if enter_repeat_3f then
        _309_ = self["prev-search"].in2
      elseif dot_repeat_3f then
        _309_ = self["prev-dot-repeatable-search"].in2
      else
        _309_ = get_input_and_clean_up()
      end
      if (nil ~= _309_) then
        local in2 = _309_
        local _311_
        if new_search_3f then
          _311_ = shortcuts[in2]
        else
        _311_ = nil
        end
        if ((_G.type(_311_) == "table") and (nil ~= (_311_)[1]) and (nil ~= (_311_)[2])) then
          local pos = (_311_)[1]
          local ch2 = (_311_)[2]
          save_state_for({["enter-repeat"] = {in1 = in1, in2 = ch2}, ["dot-repeat"] = {in1 = in1, in2 = ch2, in3 = in2}})
          return jump_with_wrap_21(pos)
        elseif (_311_ == nil) then
          save_state_for({["enter-repeat"] = {in1 = in1, in2 = in2}, ["dot-repeat"] = {in1 = in1, in2 = in2, in3 = labels[1]}})
          local _313_
          local function _314_()
            if change_operation_3f() then
              handle_interrupted_change_op_21()
            end
            do
              echo_not_found((in1 .. in2))
            end
            return nil
          end
          _313_ = (match_map[in2] or _314_())
          if (nil ~= _313_) then
            local positions = _313_
            local _let_316_ = positions
            local first = _let_316_[1]
            local rest = {(table.unpack or unpack)(_let_316_, 2)}
            local positions_to_label
            if jump_to_first_3f then
              positions_to_label = rest
            else
              positions_to_label = positions
            end
            if (jump_to_first_3f or empty_3f(rest)) then
              jump_with_wrap_21(first)
            end
            if not empty_3f(rest) then
              switch_off_scrolloff()
              if not (dot_repeat_3f and self["prev-dot-repeatable-search"].in3) then
                if opts.grey_out_search_area then
                  grey_out_search_area(reverse_3f)
                end
                do
                  set_beacon_groups(in2, positions_to_label, labels, shortcuts, {["repeat?"] = enter_repeat_3f})
                end
                if opts.disable_hlsearch then
                  vim.cmd("nohlsearch")
                end
                highlight_cursor()
                vim.cmd("redraw")
              end
              local _322_ = cycle_through_match_groups(in2, positions_to_label, shortcuts, enter_repeat_3f)
              if ((_G.type(_322_) == "table") and (nil ~= (_322_)[1]) and (nil ~= (_322_)[2])) then
                local group_offset = (_322_)[1]
                local in3 = (_322_)[2]
                restore_scrolloff()
                if (dot_repeatable_op_3f and not dot_repeat_3f) then
                  if (group_offset == 0) then
                    self["prev-dot-repeatable-search"].in3 = in3
                  else
                    self["prev-dot-repeatable-search"].in3 = nil
                  end
                end
                local _325_
                local _327_
                do
                  local _326_ = label_indexes[in3]
                  if _326_ then
                    local _328_ = ((group_offset * #labels) + _326_)
                    if _328_ then
                      _327_ = positions_to_label[_328_]
                    else
                      _327_ = _328_
                    end
                  else
                    _327_ = _326_
                  end
                end
                local function _332_()
                  if change_operation_3f() then
                    handle_interrupted_change_op_21()
                  end
                  do
                    if jump_to_first_3f then
                      vim.fn.feedkeys(in3, "i")
                    end
                  end
                  return nil
                end
                _325_ = (_327_ or _332_())
                if (nil ~= _325_) then
                  local pos = _325_
                  return jump_with_wrap_21(pos)
                end
              end
            end
          end
        end
      end
    end
  end
end
local plug_mappings = {{"n", "<Plug>Lightspeed_s", "s:to(false)"}, {"n", "<Plug>Lightspeed_S", "s:to(true)"}, {"x", "<Plug>Lightspeed_s", "s:to(false)"}, {"x", "<Plug>Lightspeed_S", "s:to(true)"}, {"o", "<Plug>Lightspeed_s", "s:to(false)"}, {"o", "<Plug>Lightspeed_S", "s:to(true)"}, {"n", "<Plug>Lightspeed_x", "s:to(false, true)"}, {"n", "<Plug>Lightspeed_X", "s:to(true, true)"}, {"x", "<Plug>Lightspeed_x", "s:to(false, true)"}, {"x", "<Plug>Lightspeed_X", "s:to(true, true)"}, {"o", "<Plug>Lightspeed_x", "s:to(false, true)"}, {"o", "<Plug>Lightspeed_X", "s:to(true, true)"}, {"n", "<Plug>Lightspeed_f", "ft:to(false)"}, {"n", "<Plug>Lightspeed_F", "ft:to(true)"}, {"x", "<Plug>Lightspeed_f", "ft:to(false)"}, {"x", "<Plug>Lightspeed_F", "ft:to(true)"}, {"o", "<Plug>Lightspeed_f", "ft:to(false)"}, {"o", "<Plug>Lightspeed_F", "ft:to(true)"}, {"x", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"x", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"n", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"n", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"o", "<Plug>Lightspeed_t", "ft:to(false, true)"}, {"o", "<Plug>Lightspeed_T", "ft:to(true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_s", "s:to(false, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_S", "s:to(true, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_x", "s:to(false, true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_X", "s:to(true, true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_f", "ft:to(false, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_F", "ft:to(true, false, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_t", "ft:to(false, true, true)"}, {"o", "<Plug>Lightspeed_dotrepeat_T", "ft:to(true, true, true)"}}
for _, _343_ in ipairs(plug_mappings) do
  local _each_344_ = _343_
  local mode = _each_344_[1]
  local lhs = _each_344_[2]
  local rhs_call = _each_344_[3]
  api.nvim_set_keymap(mode, lhs, ("<cmd>lua require'lightspeed'." .. rhs_call .. "<cr>"), {noremap = true, silent = true})
end
local function add_default_mappings()
  local default_mappings = {{"n", "s", "<Plug>Lightspeed_s"}, {"n", "S", "<Plug>Lightspeed_S"}, {"x", "s", "<Plug>Lightspeed_s"}, {"x", "S", "<Plug>Lightspeed_S"}, {"o", "z", "<Plug>Lightspeed_s"}, {"o", "Z", "<Plug>Lightspeed_S"}, {"o", "x", "<Plug>Lightspeed_x"}, {"o", "X", "<Plug>Lightspeed_X"}, {"n", "f", "<Plug>Lightspeed_f"}, {"n", "F", "<Plug>Lightspeed_F"}, {"x", "f", "<Plug>Lightspeed_f"}, {"x", "F", "<Plug>Lightspeed_F"}, {"o", "f", "<Plug>Lightspeed_f"}, {"o", "F", "<Plug>Lightspeed_F"}, {"n", "t", "<Plug>Lightspeed_t"}, {"n", "T", "<Plug>Lightspeed_T"}, {"x", "t", "<Plug>Lightspeed_t"}, {"x", "T", "<Plug>Lightspeed_T"}, {"o", "t", "<Plug>Lightspeed_t"}, {"o", "T", "<Plug>Lightspeed_T"}}
  for _, _345_ in ipairs(default_mappings) do
    local _each_346_ = _345_
    local mode = _each_346_[1]
    local lhs = _each_346_[2]
    local rhs = _each_346_[3]
    if ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0)) then
      api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
    end
  end
  return nil
end
add_default_mappings()
return {opts = opts, setup = setup, init_highlight = init_highlight, ft = ft, s = s, add_default_mappings = add_default_mappings}
