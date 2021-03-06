if not plugin then
	return
end

-- Fast flags
require(script.Parent.defineLuaFlags)

local Plugin = script.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local FFlagEnablePlayerEmulatorStylizer = game:GetFastFlag("EnablePlayerEmulatorStylizer")
local RefactorFlags = require(Plugin.Packages.Framework.Util.RefactorFlags)
RefactorFlags.THEME_REFACTOR = FFlagEnablePlayerEmulatorStylizer

local PlayerEmulatorPlugin = require(Plugin.Src.Components.PlayerEmulatorPlugin)

local function main()
	local pluginHandle

	local function onPluginWillDestroy()
		if pluginHandle then
			Roact.unmount(pluginHandle)
		end
	end

	local pluginGui = Roact.createElement(PlayerEmulatorPlugin, {
		plugin = plugin,
		onPluginWillDestroy = onPluginWillDestroy,
	})

	pluginHandle = Roact.mount(pluginGui)
end

main()
