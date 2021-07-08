local createReducerSlice = require(script.Parent.createReducerSlice)
return function(options)
	return createReducerSlice("byGameInstanceId", "gameId", options)
end
