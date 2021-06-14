if !has('nvim-0.5')
  echohl WarningMsg
  echom "Lightspeed needs Neovim >= 0.5"
  echohl None
  finish
endif
lua require'lightspeed'
