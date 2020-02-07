local Plugin = script.Parent.Parent.Parent.Parent

local Sort = require(Plugin.Core.Types.Sort)
local RequestReason = require(Plugin.Core.Types.RequestReason)

local UpdatePageInfoAndSendRequest = require(Plugin.Core.Networking.Requests.UpdatePageInfoAndSendRequest)
local StopAllSounds = require(Plugin.Core.Actions.StopAllSounds)

local FFlagEnableDefaultSortFix = game:GetFastFlag("EnableDefaultSortFix")

return function(networkInterface, settings, categoryIndex)
	return function(store)
		store:dispatch(StopAllSounds())

		local currentTab = store:getState().pageInfo.currentTab
		local sortIndex = Sort.getDefaultSortForCategory(categoryIndex, FFlagEnableDefaultSortFix and currentTab or nil)
		store:dispatch(UpdatePageInfoAndSendRequest(networkInterface, settings, {
			categoryIndex = categoryIndex,
			searchTerm = "",
			sortIndex = sortIndex,
			targetPage = 1,
			currentPage = 0,
			requestReason = RequestReason.ChangeCategory,
		}))

	end
end
