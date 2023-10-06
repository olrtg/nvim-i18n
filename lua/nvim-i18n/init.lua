local M = {}

M.open = function()
	local ui = require("nvim-i18n.ui")
	local detected = require("nvim-i18n.detector").detector()

	if not detected then
		vim.notify("Could not detect any framework in your project", vim.log.levels.ERROR)
		return
	end

	-- NOTE: We should check if a buffer exist first before calling treesitter here

	local captures = {}

	for _, query_string in pairs(detected.query_strings) do
		local parser = vim.treesitter.get_parser()
		local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_string)

		if not ok then
			vim.print("Failed to parse query")
			return
		end

		local tree = parser:parse()[1]

		for capture_id, capture_node in query:iter_captures(tree:root(), 0, 0, -1) do
			local capture_name = query.captures[capture_id]

			if capture_name == "path" then
				local path = vim.treesitter.get_node_text(capture_node, 0)
				table.insert(captures, path)
			end
		end
	end

	local split = ui.create_split()
	ui.create_tree(split, ui.get_translation_nodes(captures))
end

M.setup = function()
	vim.api.nvim_create_user_command("I18n", M.open, {})
end

return M
