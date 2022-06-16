-- <Plug> keys
local plug_mappings = {
  ['<Plug>Lightspeed_s'] = function() require'lightspeed'.sx:go({}) end,
  ['<Plug>Lightspeed_S'] = function() require'lightspeed'.sx:go({ ['reverse?'] = true }) end,
  ['<Plug>Lightspeed_x'] = function() require'lightspeed'.sx:go({ ['x-mode?'] = true }) end,
  ['<Plug>Lightspeed_X'] = function() require'lightspeed'.sx:go({ ['reverse?'] = true, ['x-mode?'] = true}) end,

  ['<Plug>Lightspeed_gs'] = function() require'lightspeed'.sx:go({ ['cross-window?'] = true }) end,
  ['<Plug>Lightspeed_gS'] = function() require'lightspeed'.sx:go({ ['cross-window?'] = true, ['reverse?'] = true }) end,

  ['<Plug>Lightspeed_omni_s'] = function() require'lightspeed'.sx:go({ ['omni?'] = true }) end,
  ['<Plug>Lightspeed_omni_gs'] = function() require'lightspeed'.sx:go({ ['omni?'] = true, ['cross-window?'] = true }) end,

  ['<Plug>Lightspeed_f'] = function() require'lightspeed'.ft:go({}) end,
  ['<Plug>Lightspeed_F'] = function() require'lightspeed'.ft:go({ ['reverse?'] = true }) end,
  ['<Plug>Lightspeed_t'] = function() require'lightspeed'.ft:go({ ['t-mode?'] = true }) end,
  ['<Plug>Lightspeed_T'] = function() require'lightspeed'.ft:go({ ['t-mode?'] = true , ['reverse?'] = true }) end,

  ['<Plug>Lightspeed_;_sx'] = function() require'lightspeed'.sx:go({ ['repeat-invoc'] = 'cold' }) end,
  ['<Plug>Lightspeed_,_sx'] = function() require'lightspeed'.sx:go({ ['repeat-invoc'] = 'cold', ['reverse?'] = true }) end,
  ['<Plug>Lightspeed_;_ft'] = function() require'lightspeed'.ft:go({ ['repeat-invoc'] = 'cold' }) end,
  ['<Plug>Lightspeed_,_ft'] = function() require'lightspeed'.ft:go({ ['repeat-invoc'] = 'cold', ['reverse?'] = true}) end,
}

for lhs, rhs in pairs(plug_mappings) do
  vim.keymap.set({'n', 'x', 'o'}, lhs, rhs, {silent = true})
end


-- Default keympaps
if vim.g.lightspeed_no_default_keymaps then
  return
end

local default_keymaps = {
  { 'n', 's', '<Plug>Lightspeed_s' },
  { 'n', 'S', '<Plug>Lightspeed_S' },
  { 'x', 's', '<Plug>Lightspeed_s' },
  { 'x', 'S', '<Plug>Lightspeed_S' },
  { 'o', 'z', '<Plug>Lightspeed_s' },
  { 'o', 'Z', '<Plug>Lightspeed_S' },

  { 'n', 'gs', '<Plug>Lightspeed_gs' },
  { 'n', 'gS', '<Plug>Lightspeed_gS' },

  { 'o', 'x', '<Plug>Lightspeed_x' },
  { 'o', 'X', '<Plug>Lightspeed_X' },

  { 'n', 'f', '<Plug>Lightspeed_f' },
  { 'n', 'F', '<Plug>Lightspeed_F' },
  { 'x', 'f', '<Plug>Lightspeed_f' },
  { 'x', 'F', '<Plug>Lightspeed_F' },
  { 'o', 'f', '<Plug>Lightspeed_f' },
  { 'o', 'F', '<Plug>Lightspeed_F' },

  { 'n', 't', '<Plug>Lightspeed_t' },
  { 'n', 'T', '<Plug>Lightspeed_T' },
  { 'x', 't', '<Plug>Lightspeed_t' },
  { 'x', 'T', '<Plug>Lightspeed_T' },
  { 'o', 't', '<Plug>Lightspeed_t' },
  { 'o', 'T', '<Plug>Lightspeed_T' },

  { 'n', ';', '<Plug>Lightspeed_;_ft' },
  { 'x', ';', '<Plug>Lightspeed_;_ft' },
  { 'o', ';', '<Plug>Lightspeed_;_ft' },

  { 'n', ',', '<Plug>Lightspeed_,_ft' },
  { 'x', ',', '<Plug>Lightspeed_,_ft' },
  { 'o', ',', '<Plug>Lightspeed_,_ft' },
}

for _, t in ipairs(default_keymaps) do
  local mode = t[1]
  local lhs = t[2]
  local rhs = t[3]
  -- User has not mapped (a keyseq starting with) `lhs` to something else.
  -- User has not already mapped something to the <Plug> key.
  if vim.fn.mapcheck(lhs, mode) == "" and vim.fn.hasmapto(rhs, mode) == 0 then
    vim.keymap.set(mode, lhs, rhs, {silent = true})
  end
end
