return {
	json = {
		--- @param key string
		--- @param value string
		--- @return string
		pair = function(key, value)
			return string.format("(object (pair key: %s value: %s))", key, value)
		end,

		--- @param value string
		--- @return string
		key = function(value)
			return string.format('(string (string_content) @%s_key (#eq? @%s_key "%s"))', value, value, value)
		end,

		--- @param value string
		--- @return string
		value = function(value)
			return string.format("(string (string_content) @%s_value)", value)
		end,
	},
	yaml = {},
}
