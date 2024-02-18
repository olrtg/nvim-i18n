local M = {}

local utils = require("nvim-i18n.utils")

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
		local parser = vim.treesitter.get_parser()
		local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_string)

		if not ok then
			vim.notify("nvim-i18n: Failed to parse query", vim.log.levels.ERROR)
			return
		end

		local tree = parser:parse()[1]

		for capture_id, capture_node in query:iter_captures(tree:root(), utils.CURRENT_BUFFER, 0, -1) do
			local capture_name = query.captures[capture_id]

			if capture_name == "path" then
				local path = vim.treesitter.get_node_text(capture_node, utils.CURRENT_BUFFER)
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
