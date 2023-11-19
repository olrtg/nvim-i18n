local M = {}

--- @param key string
--- @return string[]
function M.parse_key_path(key)
	local parse_key = vim.fn.split(key, "\\.")

	return parse_key
end

--- @param path string
function M.get_ts_query_by_path(path)
	local keys = M.parse_key_path(path)

	return M.get_ts_query_by_keys(keys)
end

--- @param keys string[]
--- @return string
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
