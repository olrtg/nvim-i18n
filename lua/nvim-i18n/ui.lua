local M = {}

local NuiSplit = require("nui.split")
local NuiTree = require("nui.tree")

local t = require("nvim-i18n.translation")
local u = require("nvim-i18n.utils")

M.create_split = function()
	local split = NuiSplit({
		relative = "editor",
		position = "bottom",
		size = "40%",
	})

	split:mount()

	split:map("n", "q", function()
		split:unmount()
	end, { noremap = true })

	return split
end

--- @param split table
--- @param nodes table
M.create_tree = function(split, nodes)
	local tree = NuiTree({
		winid = split.winid,
		nodes = nodes,
	})

	local map_options = { noremap = true, nowait = true }

	-- toggle or edit current node
	split:map("n", "<CR>", function()
		local node = tree:get_node()

		if not node:has_children() then
			local locale = node.text:match("^[^:]+")
			local node_without_locale = node.text:gsub("^[^:]+: ", "")
			local path = tree:get_node(node:get_parent_id()).text
			vim.ui.input(
				{ prompt = "Enter new translation: ", default = node_without_locale },
				function(new_translation)
					t.edit_translation(locale, path, new_translation, function()
						node.text = locale .. ": " .. new_translation
					end)
				end
			)
		elseif node:is_expanded() then
			node:collapse()
		else
			node:expand()
		end

		tree:render()
	end, map_options)

	-- collapse current node
	split:map("n", "h", function()
		local node = tree:get_node()

		if node:collapse() then
			tree:render()
		end
	end, map_options)

	-- expand current node
	split:map("n", "l", function()
		local node = tree:get_node()

		if node:expand() then
			tree:render()
		end
	end, map_options)

	tree:render()
end

--- @param matches string[]
M.get_translation_nodes = function(detected_framework, matches)
	local nodes = {}
	local locales = t.detect_languages(detected_framework)

	for _, match in ipairs(matches) do
		local child_nodes = {}

		for _, locale in ipairs(locales) do
			local translation_file = t.read_translation_file("src/locales/" .. locale .. ".json")
			local keys = u.parse_key_path(match)
			local translation = t.get_translation(translation_file, keys) or ""

			table.insert(child_nodes, NuiTree.Node({ text = locale .. ": " .. translation }))
		end

		if nodes[match] == nil then
			nodes[match] = NuiTree.Node({ text = match }, child_nodes)
		end
	end

	return vim.tbl_values(nodes)
end

--- @param node table
M.prompt_new_translation = function(node)
	local node_without_locale = node.text:gsub("^[^:]+: ", "")

	local translation = vim.ui.input(
		{ prompt = "Enter new translation: ", default = node_without_locale },
		function(new_translation)
			return new_translation
		end
	)

	return translation
end

return M
