if !has('nvim-0.5.1')
  echohl WarningMsg
  echom "Lightspeed needs Neovim >= 0.5.1"
  echohl None
  finish
endif
lua require'lightspeed'
