if !has('nvim-0.7')
  echohl WarningMsg
  echom "Lightspeed needs Neovim >= 0.7"
  echohl None
  finish
endif

if exists('g:loaded_lightspeed')
  finish
endif
let g:loaded_lightspeed = 1

lua require'lightspeed'
