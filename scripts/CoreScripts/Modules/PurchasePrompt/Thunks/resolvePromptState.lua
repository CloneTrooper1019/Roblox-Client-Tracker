local Root = script.Parent.Parent
local UserInputService = game:GetService("UserInputService")

local SetPromptState = require(Root.Actions.SetPromptState)
local ProductInfoReceived = require(Root.Actions.ProductInfoReceived)
local AccountInfoReceived = require(Root.Actions.AccountInfoReceived)
local PromptNativeUpsell = require(Root.Actions.PromptNativeUpsell)
local ErrorOccurred = require(Root.Actions.ErrorOccurred)
local CompleteRequest = require(Root.Actions.CompleteRequest)
local PromptState = require(Root.Enums.PromptState)
local PurchaseError = require(Root.Enums.PurchaseError)
local UpsellFlow = require(Root.Enums.UpsellFlow)
local selectRobuxProduct = require(Root.NativeUpsell.selectRobuxProduct)
local getUpsellFlow = require(Root.NativeUpsell.getUpsellFlow)
local Analytics = require(Root.Services.Analytics)
local ExternalSettings = require(Root.Services.ExternalSettings)
local meetsPrerequisites = require(Root.Utils.meetsPrerequisites)
local getPlayerProductInfoPrice = require(Root.Utils.getPlayerProductInfoPrice)
local Thunk = require(Root.Thunk)

local GetFFlagProductPurchaseUpsell = require(Root.Flags.GetFFlagProductPurchaseUpsell)
local GetFFlagProductPurchaseUpsellABTest = require(Root.Flags.GetFFlagProductPurchaseUpsellABTest)
local GetFFlagProductPurchaseAnalytics = require(Root.Flags.GetFFlagProductPurchaseAnalytics)

local requiredServices = {
	Analytics,
	ExternalSettings,
}

local function resolvePromptState(productInfo, accountInfo, alreadyOwned, isRobloxPurchase)
	return Thunk.new(script.Name, requiredServices, function(store, services)
		local state = store:getState()
		local analytics = services[Analytics]
		local externalSettings = services[ExternalSettings]

		store:dispatch(ProductInfoReceived(productInfo))
		store:dispatch(AccountInfoReceived(accountInfo))

		local restrictThirdParty =
			(not externalSettings.getFlagBypassThirdPartySettingForRobloxPurchase() or not isRobloxPurchase)
			and (externalSettings.getLuaUseThirdPartyPermissions() or externalSettings.getFlagRestrictSales2())

		local canPurchase, failureReason = meetsPrerequisites(productInfo, alreadyOwned, restrictThirdParty, externalSettings)
		if not canPurchase then
			if externalSettings.getFlagHideThirdPartyPurchaseFailure() then
				if not externalSettings.isStudio() and failureReason == PurchaseError.ThirdPartyDisabled then
					-- Do not annoy player with 3rd party failure notifications.
					return store:dispatch(CompleteRequest())
				end
				return store:dispatch(ErrorOccurred(failureReason))
			else
				return store:dispatch(ErrorOccurred(failureReason))
			end
		end

		local isPlayerPremium = accountInfo.MembershipType == 4
		local price = getPlayerProductInfoPrice(productInfo, isPlayerPremium)
		local platform = UserInputService:GetPlatform()
		local upsellFlow = getUpsellFlow(platform)

		if price > accountInfo.RobuxBalance then

			if externalSettings.getFFlagDisableRobuxUpsell() then
				return store:dispatch(ErrorOccurred(PurchaseError.NotEnoughRobuxNoUpsell))
			end

			if upsellFlow == UpsellFlow.Web
					and not GetFFlagProductPurchaseUpsell() and not GetFFlagProductPurchaseUpsellABTest() then
				return store:dispatch(SetPromptState(PromptState.RobuxUpsell))
			else
				local neededRobux = price - accountInfo.RobuxBalance
				local hasMembership = accountInfo.MembershipType > 0

				return selectRobuxProduct(platform, neededRobux, hasMembership)
					:andThen(function(product)
						if GetFFlagProductPurchaseAnalytics() then
							analytics.signalProductPurchaseUpsellShown(productInfo.productId, state.requestType, product.productId)
						end
						store:dispatch(PromptNativeUpsell(product.productId, product.robuxValue))
					end, function()
						-- No upsell item will provide sufficient funds to make this purchase
						if platform == Enum.Platform.XBoxOne then
							store:dispatch(ErrorOccurred(PurchaseError.NotEnoughRobuxXbox))
						else
							store:dispatch(ErrorOccurred(PurchaseError.NotEnoughRobux))
						end
					end)
			end
		end

		if GetFFlagProductPurchaseAnalytics() then
			analytics.signalProductPurchaseShown(productInfo.productId, state.requestType)
		end

		return store:dispatch(SetPromptState(PromptState.PromptPurchase))
	end)
end

return resolvePromptState
