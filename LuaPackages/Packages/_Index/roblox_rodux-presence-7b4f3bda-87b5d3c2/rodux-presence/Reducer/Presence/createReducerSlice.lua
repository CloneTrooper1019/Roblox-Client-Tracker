local PresenceReducer = script:FindFirstAncestor("rodux-presence")
local Root = PresenceReducer.Parent
local Cryo = require(Root.Cryo)

local getDeepValue = require(PresenceReducer.getDeepValue)

local Actions = PresenceReducer.Actions
local ReceivedUserPresence = require(Actions.ReceivedUserPresence)

return function(reducerName, presenceField, options)
	local PresenceNetworking = options.presenceNetworking

	local function handlePresenceModel(state, presenceModel)
		local slicedState = state[reducerName]
		local userId = tostring(presenceModel.userId)

		local previousValue = getDeepValue(state, string.format("byUserId.%s.%s", userId, presenceField))
		if previousValue and slicedState[previousValue] then
			-- remove old entry
			previousValue = tostring(previousValue)
			slicedState = Cryo.Dictionary.join(slicedState, {
				[previousValue] = Cryo.List.removeValue(slicedState[previousValue], userId),
			})
		end

		local gameInstanceIdList = slicedState[presenceModel[presenceField]]
		if not gameInstanceIdList or not table.find(gameInstanceIdList, userId) then
			return Cryo.Dictionary.join(slicedState, {
				[tostring(presenceModel[presenceField])] = Cryo.List.join(gameInstanceIdList or {}, { userId }),
			})
		end

		return slicedState
	end

	return function(state, action)
		assert(state, "state should not be nil")

		if action.type == ReceivedUserPresence.name then
			return handlePresenceModel(state, action.payload)
		elseif action.type == PresenceNetworking.GetPresencesFromUserIds.Succeeded.name then
			local userPresences = action.responseBody.userPresences

			local slicedState = state[reducerName]
			for _, userPresence in ipairs(userPresences) do
				slicedState = handlePresenceModel(state, userPresence)
			end

			return slicedState
		end

		return state[reducerName]
	end
end
