local Packages = script.Parent.Parent.Parent

local Otter = require(Packages.Otter)
local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)
local t = require(Packages.t)
local withStyle = require(Packages.UIBlox.Style.withStyle)
local ModalBottomSheetButton = require(script.Parent.ModalBottomSheetButton)

local ModalBottomSheet = Roact.PureComponent:extend("ModalBottomSheet")

-- https://share.goabstract.com/cfe90baa-ab79-4f34-ad1b-3ef389d39da4?mode=design&sha=a851936a1fe5f2f017aae74abe55715832c6c362
local WIDTH_THRESHOLD = 600
local ELEMENT_HEIGHT = 56
local MAXIMUM_SHEET_ELEMENTS = 7
local MAXIMUM_SHEET_HEIGHT = ELEMENT_HEIGHT * (MAXIMUM_SHEET_ELEMENTS + 0.5)


local MOTOR_OPTIONS = {
	frequency = 4,
	dampingRatio = 1,
}

local validateProps = t.strictInterface({
	buttonModels = t.array(t.table),
	-- this is screenWidth of the app, and is only used to calculate whether the MBS width is fixed or not
	screenWidth = t.number,
	-- a callback that when fired should result in this component no longer being rendered
	-- this should probably relate to closeCentralOverlay in CI
	onDismiss = t.callback,

	showImages = t.optional(t.boolean),
	bottomGap = t.optional(t.number),
})

ModalBottomSheet.defaultProps = {
	bottomGap = 0,
	showImages = true,
}

function ModalBottomSheet:init()
	self.motor = Otter.createSingleMotor(0)
	self.ref = Roact.createRef()
	self.active = true
end

function ModalBottomSheet:render()
	assert(validateProps(self.props))
	self.sheetHeight = #self.props.buttonModels * ELEMENT_HEIGHT
	if #self.props.buttonModels >= MAXIMUM_SHEET_ELEMENTS then
		self.sheetHeight = MAXIMUM_SHEET_HEIGHT
	end
	local children = {}
	for index, buttonProps in ipairs(self.props.buttonModels) do
		local mergedProps = Cryo.Dictionary.join(buttonProps, {
			hasRoundTop = index == 1,
			hasRoundBottom = index == #self.props.buttonModels,
			isFixed = self.props.screenWidth > WIDTH_THRESHOLD,
			elementHeight = ELEMENT_HEIGHT,
			showImage = self.props.showImages,
			LayoutOrder = index,
			onActivatedAndDismissed = function(a)
				if buttonProps.onActivated then
					buttonProps.onActivated(a)
				end
				self.props.onDismiss()
			end,
		})

		children["button " .. index] = Roact.createElement(ModalBottomSheetButton, mergedProps)
	end

	children.layout = Roact.createElement("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return withStyle(function(stylePalette)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Background = Roact.createElement("TextButton", {
				ZIndex = 0,
				AutoButtonColor = false,
				BackgroundColor3 = stylePalette.Theme.Overlay.Color,
				BackgroundTransparency = stylePalette.Theme.Overlay.Transparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				[Roact.Event.Activated] = function()
					self.active = false
					self.motor:setGoal(Otter.spring(0, MOTOR_OPTIONS))
				end
			}),
			SheetContent = Roact.createElement("ScrollingFrame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, self.sheetHeight),
				Position = UDim2.new(0, 0, 1, 0),
				ScrollBarThickness = 0,
				CanvasSize = UDim2.new(1, 0, 0, #self.props.buttonModels * ELEMENT_HEIGHT),
				ClipsDescendants = true,
				[Roact.Ref] = self.ref,
			}, children),
		})
	end)
end

function ModalBottomSheet:didMount()
	self.motor:onStep(function(value)
		if self.ref.current then
			self.ref.current.Position = UDim2.new(0, 0, 1, -(self.sheetHeight + self.props.bottomGap) * value)
		end
	end)
	self.motor:setGoal(Otter.spring(1, MOTOR_OPTIONS))
	self.motor:onComplete(function()
		if not self.active then
			self.props.onDismiss()
		end
	end)
	self.motor:start()
end

function ModalBottomSheet:wilUnmount()
	self.motor:destroy()
end

return ModalBottomSheet