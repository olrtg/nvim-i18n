local M = {}

--- Detects the supported locales in the project
--- @return string[]
function M.detect_languages(detected_framework)
	--- @type string[]
	local locales = {}

	local files = {}

	for _, dir in pairs(detected_framework.common_dirs) do
		for _, file_extension in pairs(detected_framework.file_extensions) do
			files = vim.fn.globpath(vim.fn.getcwd(), dir .. "/*." .. file_extension, true, true) --[=[@as string[]]=]

			if #files > 1 then
				break
			end
		end

		if #files > 1 then
			break
		end
	end

	for _, file in ipairs(files) do
		local locale = vim.fn.fnamemodify(file, ":t:r")
		table.insert(locales, locale)
	end

	return locales
end

--- @param path string
function M.read_file(path)
	--- @type string[]
	local raw_file = vim.fn.readfile(path)
	--- @type string
	local file = vim.fn.join(raw_file, "\n")

	return file
end

--- @param path string
function M.read_translation_file(path)
	local file = M.read_file(path)
	--- @type table
	local translation_file = vim.json.decode(file)

	return translation_file
end

--- @param translation_file table
--- @param keys string[]
function M.get_translation(translation_file, keys)
	local translation = vim.deepcopy(translation_file)

	for _, key in ipairs(keys) do
		translation = translation[key]
	end

	return translation --[=[@as string]=]
end

--- A function that edits the translation file and patches the locale file
--- @param locale string
--- @param key string
--- @param new_translation string
--- @param callback function
function M.edit_translation(locale, key, new_translation, callback)
	local file_location = "src/locales/" .. locale .. ".json"

	local file = M.read_file(file_location)
	local keys = require("nvim-i18n.utils").parse_key_path(key)

	local to_query = require("nvim-i18n.utils").get_ts_query_by_keys(keys)

	local parser = vim.treesitter.get_string_parser(file, "json")
	local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), to_query)

	if not ok then
		vim.notify("nvim-i18n: Failed to parse query", vim.log.levels.ERROR)
		return
	end

	local tree = parser:parse()[1]

	local new_file = vim.split(file, "\n")

	for capture_id, capture_node in query:iter_captures(tree:root(), file, 0, -1) do
		local capture_name = query.captures[capture_id]

		if capture_name == keys[#keys] .. "_value" then
			local start_row = capture_node:range()
			local indentation = new_file[start_row + 1]:match("^%s+")
			local final_char = new_file[start_row + 1]:sub(-1) == "," and "," or ""

			new_file[start_row + 1] =
				string.format('%s"%s": "%s"%s', indentation, keys[#keys], new_translation, final_char)
		end
	end

	local write_result = vim.fn.writefile(new_file, file_location)
	if write_result == 0 then
		callback()
	else
		vim.notify("nvim-i18n: Failed to write to file: " .. file_location, vim.log.levels.ERROR)
	end
end

return M
