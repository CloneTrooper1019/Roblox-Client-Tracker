local PresenceReducer = script:FindFirstAncestor("rodux-presence")
local Root = PresenceReducer.Parent
local Rodux = require(Root.Rodux)
local Cryo = require(Root.Cryo)

local Actions = PresenceReducer.Actions
local ReceivedUserPresence = require(Actions.ReceivedUserPresence)

local PresenceModel = require(PresenceReducer.Models.PresenceModel)

local DEFAULT_STATE = {}
return function(options)
	local PresenceNetworking = options.presenceNetworking

	return Rodux.createReducer(DEFAULT_STATE, {
		[ReceivedUserPresence.name] = function(state, action)
			local userId = action.payload.userId
			local presenceModel = action.payload

			assert(PresenceModel.isValid(presenceModel))

			return Cryo.Dictionary.join(state, {
				[userId] = PresenceModel.format(presenceModel),
			})
		end,

		[PresenceNetworking.GetPresencesFromUserIds.Succeeded.name] = function(state, action)
			local userPresences = action.responseBody.userPresences

			local additionalPresences = {}
			for _, userPresence in ipairs(userPresences) do
				local userId = tostring(userPresence.userId)
				additionalPresences[userId] = PresenceModel.format(userPresence)
			end

			return Cryo.Dictionary.join(state, additionalPresences)
		end,
	})
end
