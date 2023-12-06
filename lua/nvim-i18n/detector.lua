local M = {}

--- @param dependency string The name of a dependency (example: 'react-i18next')
--- @return boolean
function M.is_dependency_in_package_json(dependency)
	local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))

	if package_json[dependency] ~= nil then
		return true
	end

	local dev_dependencies = package_json["devDependencies"]
	if dev_dependencies ~= nil and dev_dependencies[dependency] ~= nil then
		return true
	end

	local dependencies = package_json["dependencies"]
	if dependencies ~= nil and dependencies[dependency] ~= nil then
		return true
	end

	return false
end

--- @return boolean
function M.is_web_project()
	return vim.fn.filereadable(vim.fn.getcwd() .. "/package.json") and true or false
end

--- A function that detects relevant info about what the user is using
--- @return table|nil
function M.detector()
	local frameworks = require("nvim-i18n.frameworks")

	if M.is_web_project() then
		for _, framework in pairs(frameworks.web) do
			for _, package in pairs(framework.detection.package_json) do
				-- NOTE: This in theory will just return in the first match but this is not correct
				if M.is_dependency_in_package_json(package) then
					return framework
				end
			end
		end
	end

	return nil
end

return M
