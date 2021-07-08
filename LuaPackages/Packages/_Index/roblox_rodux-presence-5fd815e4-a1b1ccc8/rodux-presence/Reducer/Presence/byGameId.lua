local createReducerSlice = require(script.Parent.createReducerSlice)
return function(options)
	return createReducerSlice("byGameId", "universeId", options)
end
