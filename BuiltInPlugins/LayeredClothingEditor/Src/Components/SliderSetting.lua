--[[
	Formatted slider wrapping around DevFramework slider. Contains a label to the left and
	a text input box to the right of the slider.

	Required Props:
		string Title: label text to the left of the slider
		number Value: slider value
		UDim2 Size: size of the component
		boolean UsePercentage: if slider value should display as a percentage
		number LayoutOrder: sort order of frame in a layout
		callback SetValue: function to be called when slider value has changed
		boolean IsDisabled: whether this slider setting is disabled
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number SnapIncrement: optional increment when dragging slider. Default to 1
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Slider = Framework.UI.Slider
local TextInput = Framework.UI.TextInput
local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local StyleModifier = Util.StyleModifier

local SliderSetting = Roact.PureComponent:extend("SliderSetting")

local Typecheck = Util.Typecheck
Typecheck.wrap(SliderSetting, script)

function SliderSetting:init(initialProps)
	self.state = {
		valueText = tostring(initialProps.Value),
	}
	self.previoustPropsValue = initialProps.Value
	self.onValueChanged = function(value)
		if self.props.SetValue then
			self.props.SetValue(value)
		end
	end

	self.onTextChanged = function(text)
		self:setState({
			valueText = text
		})
	end

	self.onTextSubmitted = function()
		local success, result = pcall(function()
			return tonumber(self.state.valueText)
		end)
		if success and result then
			self.onValueChanged(math.clamp(result, 0, self.props.MaxValue))
		else
			self.onValueChanged(0)
		end
	end
end

function SliderSetting:render()
	local props = self.props
	local state = self.state

	local title = props.Title
	local value = props.Value
	self.previoustPropsValue = value
	local maxValue = props.MaxValue
	local size = props.Size
	local usePercentage = props.UsePercentage
	local layoutOrder = props.LayoutOrder
	local isDisabled = props.IsDisabled
	local orderIterator = LayoutOrderIterator.new()
	local theme = props.Stylizer

	local snapIncrement = props.SnapIncrement or theme.DefaultSnap
	local valueText = self.previoustPropsValue == value and state.value or value
	if snapIncrement == theme.DefaultSnap then
		valueText = string.format("%d", valueText)
	else
		valueText = string.format("%" ..snapIncrement .."f", valueText)
	end

	local labelWidth = theme.LabelWidth
	local sliderContainerWidth = - theme.SliderContainerPadding - labelWidth
	local inputWidth = theme.InputWidth
	local inputHeight = theme.InputHeight
	local inputFrameWidth = theme.PercentageLabelWidth + theme.ValueTextBoxPadding + theme.InputWidth
	local sliderWidth = - inputFrameWidth - theme.SliderContainerPadding

	return Roact.createElement("Frame", {
		LayoutOrder = layoutOrder,
		Size = size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, theme.SliderContainerPadding)
		}),
		Label = Roact.createElement("TextLabel", {
			Text = title,
			TextSize = theme.TextSize,
			TextColor3 = isDisabled and theme.TextDisabledColor or theme.TextColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Font = theme.Font,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, labelWidth, 1, 0),
			LayoutOrder = 1,
		}),
		SliderContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, sliderContainerWidth, 1, 0),
			LayoutOrder = 2,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, theme.SliderContainerPadding)
			}),
			ValueSlider = Roact.createElement(Slider, {
				Disabled = isDisabled,
				Min = 0,
				Max = maxValue,
				Value = value,
				SnapIncrement = snapIncrement,
				Size = UDim2.new(1, sliderWidth, 1, 0),
				LayoutOrder = orderIterator:getNextOrder(),
				OnValueChanged = self.onValueChanged,
			}),
			ValueTextBoxFrame = Roact.createElement("Frame", {
				LayoutOrder = orderIterator:getNextOrder(),
				Size = UDim2.new(0, inputFrameWidth, 1, 0),
				BackgroundColor3 = theme.BackgroundColor,
				BorderSizePixel = 0,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, theme.ValueTextBoxPadding),
				}),

				ValueTextBox = Roact.createElement(TextInput, {
					Enabled = not isDisabled,
					LayoutOrder = 1,
					Text = valueText,
					Size = UDim2.new(0, inputWidth, 0, inputHeight),
					OnTextChanged = self.onTextChanged,
					OnFocusLost = self.onTextSubmitted,
					Style = "RoundedBorder",
					StyleModifier = isDisabled and StyleModifier.Disabled or nil
				}),

				PercentageLabel = usePercentage and Roact.createElement("TextLabel", {
					Text = "%",
					TextSize = theme.TextSize,
					TextColor3 = isDisabled and theme.TextDisabledColor or theme.TextColor,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					Font = theme.Font,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, theme.PercentageLabelWidth, 1, 0),
					LayoutOrder = 3,
				}),
			}),
		}),
	})
end

ContextServices.mapToProps(SliderSetting,{
	Stylizer = ContextServices.Stylizer,
})

return SliderSetting