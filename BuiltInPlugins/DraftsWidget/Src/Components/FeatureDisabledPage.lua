local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme

local FeatureDisabledPage = Roact.Component:extend("FeatureDisabledPage")

function FeatureDisabledPage:render()
	local disableReason = self.props.Text

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 16),
				PaddingTop = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),

			Error = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,

				Text = disableReason,
				Font = theme.Labels.MainFont,
				TextColor3 = theme.Labels.MainText,
				TextSize = 18,

				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextWrapped = true,
			}),
		})
	end)
end

return FeatureDisabledPage
