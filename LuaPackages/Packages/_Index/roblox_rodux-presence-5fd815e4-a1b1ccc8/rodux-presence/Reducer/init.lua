local byUserId = require(script.Presence.byUserId)
local byGameId = require(script.Presence.byGameId)
local byGameInstanceId = require(script.Presence.byGameInstanceId)
local byPlaceId = require(script.Presence.byPlaceId)

return function(options)
	return function(state, action)
		local newState = state or {
			byUserId = {},
			byGameInstanceId = {},
			byGameId = {},
			byPlaceId = {},
		}

		return {
			byUserId = byUserId(options)(newState.byUserId, action),
			byGameInstanceId = byGameInstanceId(options)(newState, action),
			byGameId = byGameId(options)(newState, action),
			byPlaceId = byPlaceId(options)(newState, action),
		}
	end
end
