--[[
    The Explorer Overlay contains the TreeView of all the asset folders in Asset Manager.
    Clicking on any of the folders will bring you to that folder in the Tile View.

    Necessary Properties:
        CloseOverlay = callback, that closes the overlay.
    Optional Properties:
]]

local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local UILibrary = require(Plugin.Packages.UILibrary)
local ContextServices = require(Plugin.Packages.Framework.ContextServices)

local ShowOnTop = UILibrary.Focus.ShowOnTop

local Button = UILibrary.Component.RoundFrame
local TreeView = UILibrary.Component.TreeView
local TreeViewItem = UILibrary.Component.TreeViewItem

local SetScreen = require(Plugin.Src.Actions.SetScreen)

local ExplorerOverlay = Roact.PureComponent:extend("ExplorerOverlay")

function ExplorerOverlay:render()
    local props = self.props
    local theme = props.Theme:get("Plugin")
    local overlayTheme = theme.Overlay

    local onFolderClicked = self.props.setScreen

    local content = {}

    content.TreeViewOverlay = Roact.createElement(ShowOnTop, {
        Priority = 1,
    }, {
        Background = Roact.createElement(Button, {
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(overlayTheme.Background.WidthScale, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = overlayTheme.Background.Transparency,
            BackgroundColor3 = Color3.new(0,0,0),
            ZIndex = 1,

            OnActivated = self.props.CloseOverlay,
        }),

        Overlay = Roact.createElement("Frame", {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(overlayTheme.Foreground.WidthScale, 0, 1, 0),
            BackgroundTransparency = 0,
            BackgroundColor3 = theme.BackgroundColor,
            BorderSizePixel = 0,
        }, {
            UILayout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),

            CloseButton = Roact.createElement(Button, {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 0,
                BackgroundColor3 = theme.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = 1,
            }, {
                Padding = Roact.createElement("UIPadding", {
                    PaddingRight = UDim.new(0, overlayTheme.Padding.Right),
                }),

                CloseButtonLayout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),

                CloseIcon = Roact.createElement("ImageButton", {
                    Size = UDim2.new(0, overlayTheme.CloseButton.Size, 0, overlayTheme.CloseButton.Size),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = overlayTheme.CloseButton.Images.Close,

                    [Roact.Event.Activated] = self.props.CloseOverlay,
                })
            }),

            TreeView = Roact.createElement(TreeView, {
                dataTree = self.props.FileExplorerData,
                getChildren = function(instance)
                    return instance.Children
                end,

                renderElement = function(properties)
                    return Roact.createElement(TreeViewItem, properties)
                end,

                onSelectionChanged = function(instances)
                    if instances[1] then
                        local screen = instances[1].Screen
                        onFolderClicked(screen)
                    end
                end,

                expandRoot = true,

                LayoutOrder = 2,
            })
        })
    })

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, content)
end

local function mapDispatchToProps(dispatch)
    return {
        setScreen = function(screen)
            dispatch(SetScreen(screen))
        end,
    }
end

ContextServices.mapToProps(ExplorerOverlay, {
    Theme = ContextServices.Theme,
    Localization = ContextServices.Localization,
})

return RoactRodux.connect(nil, mapDispatchToProps)(ExplorerOverlay)