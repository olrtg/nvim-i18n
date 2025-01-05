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

--- @param char string|number
--- @return string
function M.char_to_hex(char)
	return string.format("%%%02X", string.byte(char))
end

--- @param url string
--- @return string
function M.encode_url(url)
	url = url:gsub("\n", "\r\n")
	url = url:gsub("([^%w _%%%-%.~])", M.char_to_hex)
	url = url:gsub(" ", "+")
	return url
end

---@class Payload
---@field text string
---@field from string
---@field to string
---
---@param payload Payload
---@return unknown
function M.get_translation_from_google_translate(payload)
	local encoded_text = M.encode_url(payload.text)

	local response = vim.json.decode(
		require("plenary.curl").get(
			"https://translate.googleapis.com/translate_a/single?client=gtx&sl="
				.. payload.from
				.. "&tl="
				.. payload.to
				.. "&hl=zh-CN&dt=t&dt=bd&ie=UTF-8&oe=UTF-8&dj=1&source=icon&q="
				.. encoded_text
		).body
	)

	return response.sentences[1].trans
end

return M
