--[[
	Rbf point data for each deformer before any edits have been made. Store positional information
	Format:
	{
		[deformer1] = {
			[<point_index>] = {
				Cluster = <cluster_index>, -- default -1
				Position = <Vector3>,
			},
			...
		},

		[deformer2] = {
			[<point_index>] = {
				Cluster = <cluster_index>, -- default -1
				Position = <Vector3>,
			},
			...
		},
		...
	}
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(originalPointData)
	return {
		originalPointData = originalPointData,
	}
end)