local M = {}

local NuiSplit = require("nui.split")
local NuiTree = require("nui.tree")

local t = require("nvim-i18n.translation")
local u = require("nvim-i18n.utils")

function M.create_split()
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
function M.create_tree(split, nodes)
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

	-- collapse all nodes
	split:map("n", "H", function()
		local ns = tree:get_nodes()

		for _, node in pairs(ns) do
			if node:collapse() then
				tree:render()
			end
		end
	end)

	-- expand all nodes
	split:map("n", "L", function()
		local ns = tree:get_nodes()

		for _, node in pairs(ns) do
			if node:expand() then
				tree:render()
			end
		end
	end)

	-- translate all keys with google translate
	split:map("n", "T", function()
		local node = tree:get_node()

		if not node:has_children() then
			local nodes_of_parent = tree:get_nodes(node:get_parent_id())
			local siblings = vim.tbl_filter(function(sibling)
				return sibling:get_id() ~= node:get_id()
			end, nodes_of_parent)

			local locale = node.text:match("^[^:]+")
			local node_without_locale = node.text:gsub("^[^:]+: ", "")
			local path = tree:get_node(node:get_parent_id()).text

			for _, sibling in pairs(siblings) do
				local sibling_locale = sibling.text:match("^[^:]+")
				local translation = u.get_translation_from_google_translate({
					text = node_without_locale,
					from = locale,
					to = sibling_locale,
				})

				t.edit_translation(sibling_locale, path, translation, function()
					sibling.text = sibling_locale .. ": " .. translation
				end)
			end
		end

		tree:render()
	end)

	tree:render()
end

--- @param detected_framework table
--- @param captures string[]
function M.get_translation_nodes(detected_framework, captures)
	local nodes = {}
	local locales = t.detect_languages(detected_framework)

	for _, capture in ipairs(captures) do
		local child_nodes = {}

		for _, locale in ipairs(locales) do
			-- TODO: check all common dirs
			local translation_file = t.read_translation_file("src/locales/" .. locale .. ".json")
			local keys = u.parse_key_path(capture)
			local translation = t.get_translation(translation_file, keys) or ""

			table.insert(child_nodes, NuiTree.Node({ text = locale .. ": " .. translation }))
		end

		if nodes[capture] == nil then
			nodes[capture] = NuiTree.Node({ text = capture }, child_nodes)
		end
	end

	return vim.tbl_values(nodes)
end

--- @param node table
function M.prompt_new_translation(node)
	local node_without_locale = node.text:gsub("^[^:]+: ", "")

	local translation = vim.ui.input(
		{ prompt = "Enter new translation: ", default = node_without_locale },
		function(new_translation)
			return new_translation
		end
	)

	return translation
end

function M.translate_with_service() end

return M
