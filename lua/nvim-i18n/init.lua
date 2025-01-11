local M = {}

function M.open()
	local ui = require("nvim-i18n.ui")
	local detected = require("nvim-i18n.detector").detector()

	if not detected then
		vim.notify("nvim-i18n: Could not detect any framework in your project", vim.log.levels.ERROR)
		return
	end

	if vim.fn.bufexists(0) == 0 then
		vim.notify("You cannot run this command in an empty buffer", vim.log.levels.ERROR)
		return
	end

	local captures = {}

	for _, query_string in pairs(detected.query_strings) do
		local parser = vim.fn.has("nvim-0.12") == 1 and vim.treesitter.get_parser()
			or vim.treesitter.get_parser(nil, nil, { error = false })

		if not parser then
			vim.notify("nvim-i18n: Language of buffer could not be determined", vim.log.levels.ERROR)
			return
		end

		local query = vim.treesitter.query.parse(parser:lang(), query_string)
		local tree = parser:parse()[1]
		local bufnr = vim.api.nvim_get_current_buf()

		for capture_id, capture_node in query:iter_captures(tree:root(), bufnr, 0, -1) do
			local capture_name = query.captures[capture_id]

			if capture_name == "path" then
				local path = vim.treesitter.get_node_text(capture_node, bufnr)
				table.insert(captures, path)
			end
		end
	end

	local split = ui.create_split()
	ui.create_tree(split, ui.get_translation_nodes(detected, captures))
end

function M.setup()
	vim.api.nvim_create_user_command("Internationalization", M.open, {})
end

return M
