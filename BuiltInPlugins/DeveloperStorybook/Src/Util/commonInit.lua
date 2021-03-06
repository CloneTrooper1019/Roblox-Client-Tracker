--[[
	Performs common initialisation for DeveloperStorybook at most once.
]]
local commonInitCalled = false

return function()
	if commonInitCalled then
		return
	end
	commonInitCalled = true

	local Main = script.Parent.Parent.Parent
	local Roact = require(Main.Packages.Roact)

	--[[
		Since the symlink for DeveloperFramework as a path dependency is not
		checked in, we need to ensure the DeveloperFramework folder is in the correct
		location in the package index. We do this by including the folder in the Rojo
		config and then moving it to the correct location at runtime here. We remove
		any existing DeveloperFramework folder which may be present as a result of
		rotrieve install being ran locally and creating a gitignored symlink.
	]]
	local function devFrameworkLoadingPatch()
		local existingPackage = Main.Packages._Index.DeveloperFramework:FindFirstChild("DeveloperFramework")
		if existingPackage then
			existingPackage:Destroy()
		end
		local frameworkFolder = Main.Packages.DEPRECATED_Framework
		frameworkFolder.Name = "DeveloperFramework"
		frameworkFolder.Parent = Main.Packages._Index.DeveloperFramework
		
		local RefactorFlags = require(frameworkFolder.Util.RefactorFlags)
		RefactorFlags.THEME_REFACTOR = true
	end

	-- TODO DEVTOOLS-4458: Replace this with Rotriever & Rojo sub-project linking solution
	devFrameworkLoadingPatch()

	Roact.setGlobalConfig({
		elementTracing = true,
		propValidation = true,
		typeChecks = true
	})
end
