local M = {}

-- 引入配置和翻译模块
local config = require("trans_later.config")
local translator = require("trans_later.translator")

-- 设置插件
function M.setup(user_config)
	config.setup(user_config)
	vim.api.nvim_create_user_command("Translate", translator.translate, { nargs = 0 })
	vim.api.nvim_set_keymap("n", "T", ":Translate<CR>", { noremap = true, silent = true })
end

return M
