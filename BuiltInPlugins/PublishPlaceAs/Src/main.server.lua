if not plugin then
	return
end

-- Fast flags
require(script.Parent.Parent.TestRunner.defineLuaFlags)
local FFlagStudioAllowRemoteSaveBeforePublish = game:GetFastFlag("StudioAllowRemoteSaveBeforePublish")
local FFlagUpdatePublishPlacePluginToDevFrameworkContext = game:GetFastFlag("UpdatePublishPlacePluginToDevFrameworkContext")
local FFlagStudioPromptOnFirstPublish = game:GetFastFlag("StudioPromptOnFirstPublish")
local FFlagStudioNewGamesInCloudUI = game:GetFastFlag("StudioNewGamesInCloudUI")
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagLuobuDevPublishLuaTempOptIn = game:GetFastFlag("LuobuDevPublishLuaTempOptIn")

--Turn this on when debugging the store and actions
local LOG_STORE_STATE_AND_EVENTS = false

-- libraries
local Plugin = script.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)
local UILibrary = require(Plugin.Packages.UILibrary)
local Framework = require(Plugin.Packages.Framework)

-- context services
local ContextServices = Framework.ContextServices
local ServiceWrapper = require(Plugin.Src.Components.ServiceWrapper)
local UILibraryWrapper = ContextServices.UILibraryWrapper

-- components
local ScreenSelect = require(Plugin.Src.Components.ScreenSelect)

-- data
local MainReducer = require(Plugin.Src.Reducers.MainReducer)
local MainMiddleware = require(Plugin.Src.Middleware.MainMiddleware)
local ResetInfo = require(Plugin.Src.Actions.ResetInfo)

if LOG_STORE_STATE_AND_EVENTS then
	table.insert(MainMiddleware, Rodux.loggerMiddleware)
end

-- theme
local PluginTheme = require(Plugin.Src.Resources.PluginTheme)

-- localization
local TranslationDevelopmentTable = Plugin.Src.Resources.TranslationDevelopmentTable
local TranslationReferenceTable = Plugin.Src.Resources.TranslationReferenceTable
local Localization = UILibrary.Studio.Localization

-- Plugin Specific Globals
local StudioService = game:GetService("StudioService")
local dataStore = Rodux.Store.new(MainReducer, {}, MainMiddleware)
local theme = PluginTheme.new()
local localization = FFlagUpdatePublishPlacePluginToDevFrameworkContext and
	ContextServices.Localization.new({
		pluginName = "PublishPlaceAs",
		stringResourceTable = TranslationDevelopmentTable,
		translationResourceTable = TranslationReferenceTable,
	})
or Localization.new({
	stringResourceTable = TranslationDevelopmentTable,
	translationResourceTable = TranslationReferenceTable,
	pluginName = "PublishPlaceAs",
})

-- Widget Gui Elements
local pluginHandle
local pluginGui

local SetIsPublishing = require(Plugin.Src.Actions.SetIsPublishing)

local function closePlugin()
	if pluginHandle then
		Roact.unmount(pluginHandle)
	end
	pluginGui.Enabled = false
end

local initialWindowHeight = 650
if FFlagStudioAllowRemoteSaveBeforePublish then
	initialWindowHeight = 720
end

local function makePluginGui()
	pluginGui = plugin:CreateQWidgetPluginGui(plugin.Name, {
		Size = Vector2.new(960, initialWindowHeight),
		MinSize = Vector2.new(890, 550),
		MaxSize = Vector2.new(960, 750),
		Resizable = true,
		Modal = true,
		InitialEnabled = false,
	})
	pluginGui.Name = plugin.Name
	pluginGui.Title = plugin.Name
	pluginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	pluginGui:BindToClose(function()
		closePlugin()
	end)
end

--Initializes and populates the plugin popup window
local function openPluginWindow(showGameSelect, isPublish, closeMode, firstPublishContext)
	local servicesProvider = Roact.createElement(ServiceWrapper, {
		plugin = plugin,
		localization = localization,
		theme = theme,
		uiLibraryWrapper = FFlagUpdatePublishPlacePluginToDevFrameworkContext and UILibraryWrapper.new() or nil,
		focusGui = pluginGui,
		store = dataStore,
		mouse = (FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn) and plugin:getMouse() or nil,
	}, {
		Roact.createElement(ScreenSelect, {
			OnClose = closePlugin,
			IsPublish = isPublish,
			CloseMode = closeMode,
			FirstPublishContext = firstPublishContext,
			IsSaveOrPublishAs = showGameSelect,
		})
	})

	local isFirstPublish = firstPublishContext ~= nil
    dataStore:dispatch(ResetInfo(localization:getText("General", "UntitledGame"), showGameSelect))

	pluginHandle = Roact.mount(servicesProvider, pluginGui)
	pluginGui.Enabled = true
end

local function main()
	plugin.Name = localization:getText("General", "PublishPlace")
	makePluginGui()

	if FFlagStudioAllowRemoteSaveBeforePublish then
		StudioService.OnSaveOrPublishPlaceToRoblox:Connect(function(showGameSelect, isPublish, closeMode)
			if FFlagStudioNewGamesInCloudUI then
				if isPublish then
					pluginGui.Title = localization:getText("General", "PublishGame")
				else
					pluginGui.Title = localization:getText("General", "SaveGame")
				end
			else
				if isPublish then
					pluginGui.Title = localization:getText("General", "PublishPlace")
				else
					pluginGui.Title = localization:getText("General", "SavePlace")
				end
			end
			openPluginWindow(showGameSelect, isPublish, closeMode)
		end)
	else
		StudioService.OnPublishPlaceToRoblox:Connect(function(isOverwritePublish)
			openPluginWindow(isOverwritePublish)
		end)
	end

	if FFlagStudioPromptOnFirstPublish then
		StudioService.FirstPublishOfCloudPlace:Connect(function(universeId, placeId)
			local firstPublishContext = {
				universeId = universeId,
				placeId = placeId,
			}
			openPluginWindow(false, true, Enum.StudioCloseMode.None, firstPublishContext)
		end)
	end

	StudioService.GamePublishFinished:connect(function(success)
		dataStore:dispatch(SetIsPublishing(false))
	end)
end

main()
