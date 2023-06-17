local M = {}

--- Detects the supported locales in the project
M.detect_languages = function()
    local locales = {}

    --- @type string[]
    --- @diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
    local files = vim.fn.globpath(vim.fn.getcwd(), "src/locales/*.json", true, true)

    for _, file in ipairs(files) do
        local locale = vim.fn.fnamemodify(file, ":t:r")
        table.insert(locales, locale)
    end

    return locales
end

--- @param path string
M.read_file = function(path)
    local raw_file = vim.fn.readfile(path)
    local file = vim.fn.join(raw_file, "\n")

    return file
end

--- @param path string
M.read_translation_file = function(path)
    local file = M.read_file(path)
    local translation_file = vim.json.decode(file)

    return translation_file
end

--- @param key string
M.parse_key_path = function(key)
    local parse_key = vim.fn.split(key, "\\.")

    return parse_key
end

--- @param translation_file table
--- @param keys any[]
M.get_translation = function(translation_file, keys)
    local translation = translation_file

    for _, key in ipairs(keys) do
        translation = translation[key]
    end

    return translation
end

--- A function that edits the translation file and patches the locale file
--- @param locale string
--- @param key string
--- @param new_translation string
--- @param callback function
M.edit_translation = function(locale, key, new_translation, callback)
    local file_location = "src/locales/" .. locale .. ".json"

    local raw_file = M.read_file(file_location)
    local file = vim.split(raw_file, "\n")
    local keys = M.parse_key_path(key)

    for index, line in ipairs(file) do
        local indentation = line:match("^%s+")
        local line_without_indentation = line:gsub("^%s+", "")

        if vim.startswith(line_without_indentation, '"' .. keys[#keys] .. '"') then
            file[index] = indentation .. '"' .. keys[#keys] .. '": "' .. new_translation .. '",'
        end
    end

    if pcall(vim.fn.writefile, file, file_location) then
        callback()
    else
        vim.notify("Failed to write to file: " .. file_location, vim.log.levels.ERROR)
    end
end

return M
