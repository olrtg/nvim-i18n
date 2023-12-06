local M = {}

--- @param path string An object-like path to a translation (example: 'path.to.translation')
--- @return string[] # A table of keys (example: { 'path', 'to', 'translation' })
function M.parse_key_path(path)
	local parse_key = vim.fn.split(path, "\\.") --[=[@as string[]]=]

	return parse_key
end

--- @param path string An object-like path to a translation (example: 'path.to.translation')
--- @return string # A Tree-sitter query
function M.get_ts_query_by_path(path)
	local keys = M.parse_key_path(path)

	return M.get_ts_query_by_keys(keys)
end

--- @param keys string[] # A table of keys (example: { 'path', 'to', 'translation' })
--- @return string # A Tree-sitter query
function M.get_ts_query_by_keys(keys)
	local g = require("nvim-i18n.generator").json
	local query = ""

	for i = #keys, 1, -1 do
		local value = keys[i]

		if i == #keys then
			query = g.pair(g.key(value), g.value(value))
		else
			query = g.pair(g.key(value), query)
		end
	end

	return query
end

return M
