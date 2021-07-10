return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ScreenFlow = require(script.Parent.ScreenFlow)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(ScreenFlow, {
			Screens = {"Frame"},
			OnScreenChanged = function() end
		}))
	end)

	it("should render correctly", function()
		runComponentTest(
			Roact.createElement(ScreenFlow, {
				Screens = {"Frame"},
			}),
			function(container)
				local frame = container:FindFirstChild("Frame")
				expect(frame).to.be.ok()
			end
		)
	end)
end