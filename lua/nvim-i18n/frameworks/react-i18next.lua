return {
	id = "react-i18next",
	display = "React I18next",
	namespace_delimiter = ":",

	detection = {
		package_json = { "react-i18next" },
	},

	filetypes = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
	},

	parsers = {
		[[
            ;; query
            (call_expression
              function: (identifier) @t (#eq? @t "t")
              arguments: (arguments (string (string_fragment) @path))
            )
        ]],
		-- TODO: add i18nKey use case
	},
}
