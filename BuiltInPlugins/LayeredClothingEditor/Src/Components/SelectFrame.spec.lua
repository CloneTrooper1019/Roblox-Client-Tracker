return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SelectFrame = require(script.Parent.SelectFrame)

	local function createSelectFrame()
		return Roact.createElement(SelectFrame, {
			Size = UDim2.new(1, 0, 1, 0),
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createSelectFrame())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createSelectFrame(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local viewArea = frame.ViewArea

				local content = viewArea.Content
				local selectPartFrame = content.SelectPartFrame
				local selectPartFrameLayout = selectPartFrame.Layout
				local textBoxLabel = selectPartFrame.TextBoxLabel
				local selectedPartBox = selectPartFrame.SelectedPartLabel

				expect(frame).to.be.ok()
				expect(viewArea).to.be.ok()
				expect(content).to.be.ok()
				expect(selectPartFrame).to.be.ok()
				expect(selectPartFrameLayout).to.be.ok()
				expect(selectedPartBox).to.be.ok()
				expect(textBoxLabel).to.be.ok()
			end
		)
	end)

end