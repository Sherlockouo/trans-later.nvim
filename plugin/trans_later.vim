if exists('g:loaded_trans_later')
  finish
endif
let g:loaded_trans_later = 1

" 自动加载 Lua 插件
lua require("trans_later").setup()
