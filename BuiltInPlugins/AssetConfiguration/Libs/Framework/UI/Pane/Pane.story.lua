local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local TextLabel = UI.Decoration.TextLabel
local Pane = UI.Pane

return function()
	return Roact.createElement(Pane, {
		BackgroundColor = Color3.fromRGB(100, 100, 100),
		AutomaticSize = Enum.AutomaticSize.XY,
		Padding = 50,
		Spacing = 10,
		Layout = Enum.FillDirection.Vertical
	}, { 
		First = Roact.createElement(Pane, {
			Padding = 10,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 1,
		}, {
			Roact.createElement(TextLabel, {
				Text = "This pane has the Default style",
				AutomaticSize = Enum.AutomaticSize.XY,
			})
		}),
		Second = Roact.createElement(Pane, {
			Style = "Box",
			Padding = 10,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 2,
		}, {
			Roact.createElement(TextLabel, {
				Text = "This pane has the Box style",
				AutomaticSize = Enum.AutomaticSize.XY,
			})
		}),
		Third = Roact.createElement(Pane, {
			Style = "RoundBox",
			Padding = 10,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 3,
		}, {
			Roact.createElement(TextLabel, {
				Text = "This pane has a RoundBox style",
				AutomaticSize = Enum.AutomaticSize.XY,
			})
		}),
		Fourth = Roact.createElement(Pane, {
			Style = "BorderBox",
			Padding = 10,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 4,
		}, {
			Roact.createElement(TextLabel, {
				Text = "This pane has a BorderBox style",
				AutomaticSize = Enum.AutomaticSize.XY,
			})
		}),
		Fifth = Roact.createElement(Pane, {
			Style = "BorderBox",
			Padding = 10,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 5,
			BackgroundColor = Color3.fromRGB(255, 200, 200),
			BorderColor = Color3.fromRGB(255, 100, 0)
		}, {
			Roact.createElement(TextLabel, {
				Text = "This pane has a BorderBox style with custom colors",
				TextColor = Color3.fromRGB(0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
			})
		})
	})
end
