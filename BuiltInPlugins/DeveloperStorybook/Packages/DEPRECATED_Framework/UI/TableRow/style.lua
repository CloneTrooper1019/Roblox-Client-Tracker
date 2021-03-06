local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local StyleKey = require(Framework.Style.StyleKey)

if THEME_REFACTOR then
	return {
		Border = StyleKey.SubBackground,
		BackgroundOdd = StyleKey.MainBackground,
		BackgroundEven = StyleKey.SubBackground2,
		[StyleModifier.Hover] = {
			BackgroundOdd = StyleKey.ButtonHover,
			BackgroundEven = StyleKey.ButtonHover,
		},
		[StyleModifier.Selected] = {
			BackgroundOdd = StyleKey.DialogMainButton,
			BackgroundEven = StyleKey.DialogMainButton,
		},
		Tooltip = {
			MaxWidth = 1000
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		return {
			Default = common.MainText,
		}
	end
end
