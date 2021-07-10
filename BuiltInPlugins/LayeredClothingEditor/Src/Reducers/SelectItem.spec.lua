return function()
	local Plugin = script.Parent.Parent.Parent

	local Constants = require(Plugin.Src.Util.Constants)
	local SetEditingItem = require(Plugin.Src.Actions.SetEditingItem)
	local SetSelectorMode = require(Plugin.Src.Actions.SetSelectorMode)
	local SetLayeredClothingItemsInList = require(Plugin.Src.Actions.SetLayeredClothingItemsInList)
	local SetManuallyHiddenLayeredClothingItems = require(Plugin.Src.Actions.SetManuallyHiddenLayeredClothingItems)
	local SetEditingCage = require(Plugin.Src.Actions.SetEditingCage)
	local SetCagesTransparency = require(Plugin.Src.Actions.SetCagesTransparency)

	local SelectItem = require(Plugin.Src.Reducers.SelectItem)

	local function createDefaultState()
		return SelectItem(nil,{})
	end

	it("should return a table", function()
		local state = createDefaultState()

		expect(type(state)).to.equal("table")
		expect(state.editingItem).to.equal(nil)
		expect(state.layeredClothingItemsInList).to.be.a("table")
		expect(state.manuallyHiddenLayeredClothingItems).to.be.a("table")
		expect(state.selectorMode).to.equal(Constants.SELECTOR_MODE.None)
		expect(state.editingCage).to.equal(nil)
		expect(state.cagesTransparency).to.be.a("table")
	end)

	describe("SetEditingItem action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local lcItem = Instance.new("MeshPart")
			state = SelectItem(state, SetEditingItem(lcItem))

			expect(state.editingItem).to.be.ok()
			expect(state.editingItem).to.equal(lcItem)
		end)
	end)

	describe("SetLayeredClothingItemsInList action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local lcItem = Instance.new("MeshPart")
			local handler = lcItem:GetPropertyChangedSignal("Name"):Connect(function(property)
			end)
			local layeredClothingItemsList = {
				[lcItem] = handler
			}
			state = SelectItem(state, SetLayeredClothingItemsInList(layeredClothingItemsList))

			expect(state.layeredClothingItemsInList).to.be.ok()
			expect(state.layeredClothingItemsInList).to.be.a("table")
			expect(state.layeredClothingItemsInList[lcItem]).to.equal(handler)
			handler:Disconnect()
		end)
	end)

	describe("SetManuallyHiddenLayeredClothingItems action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local lcItem = Instance.new("MeshPart")
			local manuallyHiddenLayeredClothingItems = {
				[lcItem] = lcItem
			}
			state = SelectItem(state, SetManuallyHiddenLayeredClothingItems(manuallyHiddenLayeredClothingItems))

			expect(state.manuallyHiddenLayeredClothingItems).to.be.ok()
			expect(state.manuallyHiddenLayeredClothingItems).to.be.a("table")
			expect(state.manuallyHiddenLayeredClothingItems[lcItem]).to.equal(lcItem)
		end)
	end)

	describe("SetSelectorMode action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = SelectItem(state, SetSelectorMode(Constants.SELECTOR_MODE.EditingItem))

			expect(state.selectorMode).to.be.ok()
			expect(state.selectorMode).to.equal(Constants.SELECTOR_MODE.EditingItem)
		end)
	end)

	describe("SetEditingCage action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = SelectItem(state, SetEditingCage(Enum.CageType.Inner))

			expect(state.editingCage).to.be.ok()
			expect(state.editingCage).to.equal(Enum.CageType.Inner)
		end)
	end)

	describe("SetCagesTransparency action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = SelectItem(state, SetCagesTransparency({Inner = 10}))

			expect(state.cagesTransparency).to.be.ok()
			expect(state.cagesTransparency).to.be.a("table")
			expect(state.cagesTransparency["Inner"]).to.equal(10)
		end)
	end)
end