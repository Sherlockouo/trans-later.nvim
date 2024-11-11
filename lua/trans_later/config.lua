local M = {}

-- 默认配置
M.options = {
	default_lang = "en",
	default_target_lang = "zh",
}

-- 用户配置合并
function M.setup(user_config)
	M.options = vim.tbl_deep_extend("force", M.options, user_config or {})
end

return M
