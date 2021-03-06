--[[
	Sets what tracks are currently open in the editor.
	Use the thunk SortAndSetTracks to sort tracks before setting them.
]]

local Action = require(script.Parent.Action)

return Action(script.Name, function(tracks, unusedTracks)
	return {
		tracks = tracks,
		unusedTracks = unusedTracks,
	}
end)