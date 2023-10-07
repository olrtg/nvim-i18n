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

	file_extensions = {
		"json",
		"yml",
		"yaml",
	},

	query_strings = {
		[[
            ;; query
            (call_expression
              function: (identifier) @t (#eq? @t "t")
              arguments: (arguments (string (string_fragment) @path)))
        ]],

		[[
			;; query
			(jsx_element
			  open_tag: (jsx_opening_element
				name: (identifier) @id (#eq? @id "Trans")
				attribute: (jsx_attribute (
				  (property_identifier) @prop (#eq? @prop "i18nKey")
				  (string (string_fragment) @path)))))
		]],
	},
}
