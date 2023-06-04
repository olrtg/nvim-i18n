local M = {}

local state = {}

--- @param captures string[]
function get_nui_tree_nodes(captures) end

M.open = function()
    local Split = require("nui.split")
    local NuiText = require("nui.text")
    local NuiTree = require("nui.tree")

    -- local event = require("nui.utils.autocmd").event
    local ts_utils = require("nvim-treesitter.ts_utils")

    -- This matches `t('path.to.translation')` function calls
    local query_t_calls = [[
        (call_expression
          function: (identifier) @t (#match? @t "t")
          arguments: (arguments (string (string_fragment) @path))
        )
    ]]

    local parser = vim.treesitter.get_parser()
    local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_t_calls)

    if not ok then
        vim.print("Failed to parse query")
        return
    end

    local tree = parser:parse()[1]

    local captures = {}

    for capture_id, capture_node in query:iter_captures(tree:root(), 0, 0, -1) do
        local capture_name = query.captures[capture_id]

        if capture_name == "path" then
            local path = vim.treesitter.get_node_text(capture_node, 0)
            table.insert(captures, path)
        end
    end

    local raw_file = vim.fn.readfile("src/locales/en.json")
    local file = vim.fn.join(raw_file, "\n")
    local translation_file = vim.json.decode(file)

    local key = vim.fn.input({ prompt = "Enter key: " })
    local parse_key = vim.fn.split(key, "\\.")

    local split = Split({
        relative = "editor",
        position = "bottom",
        size = "40%",
    })

    -- mount/open the component
    split:mount()

    split:map("n", "q", function()
        split:unmount()
    end, { noremap = true })

    local tree = NuiTree({
        winid = split.winid,
        nodes = {
            NuiTree.Node({ text = "a" }),
            NuiTree.Node({ text = "b" }, {
                NuiTree.Node({ text = "b-1" }),
                NuiTree.Node({ text = { "b-2", "b-3" } }),
            }),
        },
    })

    local map_options = { noremap = true, nowait = true }

    -- print current node
    split:map("n", "<CR>", function()
        local node = tree:get_node()
        vim.print(node)
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

    -- unmount component when cursor leaves buffer
    -- split:on(event.BufLeave, function()
    --     split:unmount()
    -- end)
end

M.setup = function()
    vim.api.nvim_create_user_command("I18n", M.open, {})
end

return M
