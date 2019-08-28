--[[
	This component is responsible for configging asset's gernre field.

	Props:
	onDropDownSelect, function, will return current selected item if selected.
]]

local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local DropdownMenu = require(Plugin.Core.Components.DropdownMenu)

local Util = Plugin.Core.Util
local ContextHelper = require(Util.ContextHelper)
local Constants = require(Util.Constants)
local AssetConfigConstants = require(Util.AssetConfigConstants)

local withTheme = ContextHelper.withTheme

local ConfigGenre = Roact.PureComponent:extend("ConfigGenre")

local TITLE_HEIGHT = 40

local DROP_DOWN_WIDTH = 220
local DORP_DOWN_HEIGHT = 38

function ConfigGenre:init(props)
	self.state = {
	}
end

function ConfigGenre:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state

		local Title = props.Title
		local LayoutOrder = props.LayoutOrder
		local TotalHeight = props.TotalHeight

		local genres = props.genres or {}
		local genreIndex = AssetConfigConstants.getGenreIndex(genres[1])
		local genreTypes = AssetConfigConstants.getGenreTypes()

		local onDropDownSelect = props.onDropDownSelect

		local publishAssetTheme = theme.publishAsset

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, TotalHeight),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			LayoutOrder = LayoutOrder,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.new(0, AssetConfigConstants.TITLE_GUTTER_WIDTH, 1, 0),

				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = Title,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = Constants.FONT_SIZE_TITLE,
				TextColor3 = publishAssetTheme.titleTextColor,
				Font = Constants.FONT,

				LayoutOrder = 1,
			}),

			DropDown = Roact.createElement(DropdownMenu, {
				Size = UDim2.new(0, DROP_DOWN_WIDTH, 0, DORP_DOWN_HEIGHT),
				visibleDropDownCount = 5,
				selectedDropDownIndex = genreIndex,

				items = genreTypes,
				fontSize = Constants.FONT_SIZE_MEDIUM,
				onItemClicked = onDropDownSelect,

				LayoutOrder = 2,
			})
		})
	end)
end

return ConfigGenre