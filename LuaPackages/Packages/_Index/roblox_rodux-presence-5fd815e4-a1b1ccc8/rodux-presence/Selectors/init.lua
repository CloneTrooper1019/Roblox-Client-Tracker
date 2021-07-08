local getUserPresenceByUserId = require(script.getUserPresenceByUserId)

return function(options)
	return {
		getUserPresenceByUserId = getUserPresenceByUserId(options),
	}
end
