local M = {}

-- 创建一个全局变量来存储窗口 ID
M.popup_win = nil

-- 显示悬浮窗翻译内容
local function show_translation(translation)
	-- 如果窗口已经存在，先关闭它
	if M.popup_win and vim.api.nvim_win_is_valid(M.popup_win) then
		vim.api.nvim_win_close(M.popup_win, true)
	end

	-- 创建一个浮动缓冲区
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { translation })
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- 配置浮动窗口选项
	local win_opts = {
		relative = "cursor",
		width = math.min(50, #translation + 2),
		height = 1,
		row = 1,
		col = 0,
		style = "minimal",
		border = "none",
	}

	-- 创建浮动窗口
	M.popup_win = vim.api.nvim_open_win(buf, false, win_opts)

	-- 自动关闭窗口的回调函数
	local function close_popup()
		if M.popup_win and vim.api.nvim_win_is_valid(M.popup_win) then
			vim.api.nvim_win_close(M.popup_win, true)
			M.popup_win = nil
		end
	end

	-- 设置自动命令在失焦时关闭窗口
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, {
		once = true,
		callback = close_popup,
	})
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

-- 翻译函数
function M.translate()
	-- 获取光标下的单词
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("未找到需要翻译的单词", vim.log.levels.WARN)
		return
	end

	local lang = "zh"
	-- 使用 Google Translate API 获取翻译结果
	local translation = translate_text(word, lang)

	-- 显示悬浮窗
	show_translation(translation)
end

return M
