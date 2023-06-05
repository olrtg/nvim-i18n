local M = {}

local NuiSplit = require("nui.split")
local NuiTree = require("nui.tree")

local t = require("nvim-i18n.translation")

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

M.create_tree = function(split, nodes)
    local tree = NuiTree({
        winid = split.winid,
        nodes = nodes,
    })

    local map_options = { noremap = true, nowait = true }

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

---@param matches string[]
M.get_translation_nodes = function(matches)
    local nodes = {}
    local locales = t.detect_languages()

    for _, match in ipairs(matches) do
        local child_nodes = {}

        for _, locale in ipairs(locales) do
            local translation_file = t.read_translation_file("src/locales/" .. locale .. ".json")
            local keys = t.parse_key_path(match)
            local translation = t.get_translation(translation_file, keys)

            table.insert(child_nodes, NuiTree.Node({ text = locale .. ": " .. translation }))
        end

        if nodes[match] == nil then
            nodes[match] = NuiTree.Node({ text = match }, child_nodes)
        end
    end

    return vim.tbl_values(nodes)
end

return M
