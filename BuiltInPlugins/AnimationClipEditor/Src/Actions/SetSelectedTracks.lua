--[[
	Used to set which track(s) are currently selected.

	Params:
		array selected = list of track names that are selected.
]]

local Action = require(script.Parent.Action)

return Action(script.Name, function(tracks)
	return {
		selectedTracks = tracks,
	}
end)