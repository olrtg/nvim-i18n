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

--- A function that edits the translation file and patches the locale file
M.edit_translation = function(locale, path, new_translation)
    local translation_file = M.read_translation_file("src/locales/" .. locale .. ".json")
    local keys = M.parse_key_path(path)

    local translation = translation_file

    for _, key in ipairs(keys) do
        translation = translation[key]
    end

    translation = new_translation

    local new_translation_file = vim.json.encode(translation_file)

    -- NOTE: This doesn't work as expected, maybe we need to find a way to just change a specific line
    -- the whole decoding and encoding is not working as expected, it creates a lot of changes in the file
    new_translation_file = vim.fn.system("npx prettier --parser json", new_translation_file)

    vim.fn.writefile(vim.split(new_translation_file, "\n"), "src/locales/" .. locale .. ".json")
end

return M
