local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		StartColor = StyleKey.DimmedText,
		EndColor = StyleKey.DialogMainButtonSelected,
	}
else
	return function(theme, getColor)
		local Default = Style.new({
			StartColor = theme:GetColor("DimmedText"),
			EndColor = theme:GetColor("DialogMainButton", "Selected")
		})

		return {
			Default = Default,
		}
	end
end
