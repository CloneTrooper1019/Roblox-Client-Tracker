return function()
    local Root = script.Parent.Parent

    local CorePackages = game:GetService("CorePackages")
    local PurchasePromptDeps = require(CorePackages.PurchasePromptDeps)
    local Roact = PurchasePromptDeps.Roact
    local Rodux = PurchasePromptDeps.Rodux

    local PromptState = require(Root.Enums.PromptState)
    local Reducer = require(Root.Reducers.Reducer)
    local UnitTestContainer = require(Root.Test.UnitTestContainer)

    local PurchasePromptABTestContainer = require(script.Parent.PurchasePromptABTestContainer)
    PurchasePromptABTestContainer = PurchasePromptABTestContainer.getUnconnected()

    it("should create and destroy without errors", function()
        local element = Roact.createElement(UnitTestContainer, {
            overrideStore = Rodux.Store.new(Reducer, {
                promptState = PromptState.PromptPurchase,
                accountInfo = {
                    balance = 100,
                },
                productInfo = {
                    assetTypeId = 2, -- T-shirt
                    price = 10,
                    itemType = 2,
                },
            })
        }, {
            Roact.createElement(PurchasePromptABTestContainer)
        })

        local instance = Roact.mount(element)
        Roact.unmount(instance)
    end)
end
