-- Centralized Place for Keys used throughout the widget

local FFlagStudioEnableBadgesInMonetizationPage = game:GetFastFlag("StudioEnableBadgesInMonetizationPage")
local FFlagGameSettingsUseKeyProvider = game:GetFastFlag("GameSettingsUseKeyProvider")
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagLuobuDevPublishLuaTempOptIn = game:GetFastFlag("LuobuDevPublishLuaTempOptIn")

local KeyProvider = {}

function KeyProvider.getCopyIdKeyName()
    assert(FFlagStudioEnableBadgesInMonetizationPage or FFlagGameSettingsUseKeyProvider)

    return "CopyIDToClipboard"
end

function KeyProvider.getConfigureKeyName()
    assert(FFlagStudioEnableBadgesInMonetizationPage)

    return "Configure"
end

function KeyProvider.getIsFriendOnlyKeyName()
    return "isFriendsOnly"
end

function KeyProvider.getIsActiveKeyName()
    return "isActive"
end

function KeyProvider.getIsForSaleKeyName()
    return "isForSale"
end

function KeyProvider.getVipServersIsEnabledKeyName()
    return "vipServersIsEnabled"
end

function KeyProvider.getEditKeyName()
    assert(FFlagGameSettingsUseKeyProvider)

    return "Edit"
end

function KeyProvider.getVersionHistoryKeyName()
    assert(FFlagGameSettingsUseKeyProvider)

    return "VersionHistory"
end

function KeyProvider.getOptInLocationsKeyName()
    assert(FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn)

    return "OptInLocations"
end

function KeyProvider.getChinaKeyName()
    assert(FFlagLuobuDevPublishLua)

    return "China"
end

function KeyProvider.getSelectedKeyName()
    assert(FFlagLuobuDevPublishLua)

    return "selected"
end

return KeyProvider
