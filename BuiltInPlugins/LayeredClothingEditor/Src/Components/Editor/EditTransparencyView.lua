--[[
	Frame for editing transparency of mesh and cages of editing item

	Required Props:
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		callback ChangeCageTransparency: function to change cage transparency, which is provided via mapDispatchToProps
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		string EditingCage: type of cage being edited (inner/outer)
		table CagesTransparency: cages transparency, which is provided via store
		number LayoutOrder: render order of component in layout
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local TransparencySlider = require(Plugin.Src.Components.TransparencySlider)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)
local GetTransparency = require(Plugin.Src.Util.GetTransparency)

local ChangeCageTransparency = require(Plugin.Src.Thunks.ChangeCageTransparency)

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Constants = require(Plugin.Src.Util.Constants)

local EditTransparencyView = Roact.PureComponent:extend("EditTransparencyView")
local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator

local Typecheck = Util.Typecheck
Typecheck.wrap(EditTransparencyView, script)

function EditTransparencyView:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder
	local editingItem = props.EditingItemContext:getItem()
	local editingCage = props.EditingCage

	-- todo should use cage info saved in store, when cage info is fetched from correct rbf data
	local outerCage = ItemCharacteristics.getOuterCage(editingItem)
	local innerCage = ItemCharacteristics.getInnerCage(editingItem)

	local theme = props.Stylizer
	local localization = props.Localization
	local orderIterator = LayoutOrderIterator.new()

	local transparencySliderHeight = theme.SliderHeight
	local transparencyViewHeight = transparencySliderHeight * 2

	return Roact.createElement("Frame", {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, transparencyViewHeight),
		BackgroundColor3 = theme.BackgroundColor,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Mesh = Roact.createElement(TransparencySlider, {
			Title = localization:getText("Transparency", "Mesh"),
			Value = GetTransparency(editingItem),
			Size = UDim2.new(1, -theme.MainPadding, 0, theme.SliderHeight),
			LayoutOrder = orderIterator:getNextOrder(),
			Item = editingItem,
			IsDisabled = not editingItem,
		}),
		OuterCage = editingCage == Enum.CageType.Outer and Roact.createElement(TransparencySlider, {
			Title = localization:getText("Transparency", "OuterCage"),
			Value = Constants.DEFAULT_CAGE_TRANSPARENCY,
			Size = UDim2.new(1, -theme.MainPadding, 0, theme.SliderHeight),
			LayoutOrder = orderIterator:getNextOrder(),
			IsDisabled = not outerCage,
			SetValue = function(value)
				props.ChangeCageTransparency(Enum.CageType.Outer, value)
			end,
		}),
		InnerCage = editingCage == Enum.CageType.Inner and Roact.createElement(TransparencySlider, {
			Title = localization:getText("Transparency", "InnerCage"),
			Value = Constants.DEFAULT_CAGE_TRANSPARENCY,
			Size = UDim2.new(1, -theme.MainPadding, 0, theme.SliderHeight),
			LayoutOrder = orderIterator:getNextOrder(),
			IsDisabled = not innerCage,
			SetValue = function(value)
				props.ChangeCageTransparency(Enum.CageType.Inner, value)
			end,
		}),
	})
end

ContextServices.mapToProps(EditTransparencyView,{
	Localization = ContextServices.Localization,
	Stylizer = ContextServices.Stylizer,
	EditingItemContext = EditingItemContext,
})

local function mapStateToProps(state, props)
	local selectItem = state.selectItem
	return {
		EditingCage = selectItem.editingCage,
		CagesTransparency = selectItem.cagesTransparency,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		ChangeCageTransparency = function(cage, value)
			dispatch(ChangeCageTransparency(cage, value))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(EditTransparencyView)