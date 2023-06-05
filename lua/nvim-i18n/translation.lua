local M = {}

--- Detects the supported locales in the project
M.detect_languages = function()
    local locales = {}

    ---@type string[]
    ---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
    local files = vim.fn.globpath(vim.fn.getcwd(), "src/locales/*.json", true, true)

    for _, file in ipairs(files) do
        local locale = vim.fn.fnamemodify(file, ":t:r")
        table.insert(locales, locale)
    end

    return locales
end

---@param path string
M.read_translation_file = function(path)
    local raw_file = vim.fn.readfile(path)
    local file = vim.fn.join(raw_file, "\n")
    local translation_file = vim.json.decode(file)

    return translation_file
end

---@param key string
M.parse_key_path = function(key)
    local parse_key = vim.fn.split(key, "\\.")

    return parse_key
end

---@param translation_file table
---@param keys any[]
M.get_translation = function(translation_file, keys)
    local translation = translation_file

    for _, key in ipairs(keys) do
        translation = translation[key]
    end

    return translation
end

return M
