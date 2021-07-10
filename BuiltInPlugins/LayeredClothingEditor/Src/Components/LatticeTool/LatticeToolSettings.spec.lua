return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local LatticeToolSettings = require(script.Parent.LatticeToolSettings)

	local function render()
		return Roact.createElement(LatticeToolSettings, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
		})
	end

	it("should create and destroy without errors", function()
		runComponentTest(render())
	end)

	it("should render correctly", function ()
		runComponentTest(
			render(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local layout = frame.Layout
				local dropdownMenu = frame.DropdownMenu
				local dropdownMenuPadding = dropdownMenu.UIPadding
				local subdivisions = frame.Subdivisions
				local subdivisonsPadding = subdivisions.UIPadding
				local generateButtonContainer = frame.GenerateButtonContainer
				local generateButtonPadding = generateButtonContainer.UIPadding
				local generateButton = generateButtonContainer.GenerateButton

				expect(frame).to.be.ok()
				expect(layout).to.be.ok()
				expect(dropdownMenu).to.be.ok()
				expect(subdivisions).to.be.ok()
				expect(generateButtonContainer).to.be.ok()
				expect(generateButton).to.be.ok()

				expect(dropdownMenuPadding).to.be.ok()
				expect(subdivisonsPadding).to.be.ok()
				expect(generateButtonPadding).to.be.ok()
			end
		)
	end)
end