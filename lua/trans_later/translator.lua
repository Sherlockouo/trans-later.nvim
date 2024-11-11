local config = require("trans_later.config")

-- 获取光标下的单词或选中文本
local function get_text()
	local mode = vim.api.nvim_get_mode().mode
	if mode == "v" or mode == "V" or mode == "^V" then
		local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
		local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
		local lines = vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
		return table.concat(lines, " ")
	else
		return vim.fn.expand("<cword>")
	end
end

-- 使用 Google Translate API 进行翻译
local function translate_text(text, target_lang)
	local api_url = string.format(
		"https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&q=%s",
		target_lang,
		vim.fn.escape(text, " ")
	)
	local command = string.format("curl -s '%s'", api_url)
	local result = vim.fn.system(command)
	local translated_text = result:match('%["([^"]+)"')
	return translated_text or "翻译失败"
end

-- 主翻译函数
local function translate()
	local text = get_text()
	if text == "" then
		vim.notify("未找到需要翻译的文本", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "输入目标语言: ", default = config.options.default_lang }, function(lang)
		if not lang or lang == "" then
			lang = config.options.default_lang
		end
		local translation = translate_text(text, lang)
		vim.api.nvim_echo({ { translation, "Normal" } }, false, {})
	end)
end

return {
	translate = translate,
}
