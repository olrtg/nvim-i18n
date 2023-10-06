return {
	id = "react-i18next",
	display = "React I18next",
	namespace_delimiter = ":",

	detection = {
		package_json = { "react-i18next" },
	},

	common_dirs = {
		"locales",
		"src/locales",
		"public/locales",
	},

	filetypes = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
	},

	query_strings = {
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
