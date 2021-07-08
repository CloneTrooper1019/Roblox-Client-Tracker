local createReducerSlice = require(script.Parent.createReducerSlice)
return function(options)
	return createReducerSlice("byPlaceId", "placeId", options)
end
