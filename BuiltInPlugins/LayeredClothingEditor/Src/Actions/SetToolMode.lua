--[[
	Sets current tool being used in editor: Ring, Lattice, Point
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(toolMode)
	return {
		toolMode = toolMode,
	}
end)