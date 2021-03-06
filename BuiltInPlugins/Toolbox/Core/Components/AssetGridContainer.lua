--[[
	A grid of assets. Use Layouter.calculateAssetsHeight() to know how tall it will be when the assets are rendered.

	Props:
		UDim2 Position = UDim2.new(0, 0, 0, 0)
		UDim2 Size = UDim2.new(1, 0, 1, 0)

		{number -> Asset} idToAssetMap
		[number] assetIds

		number currentSoundId
		boolean isPlaying

		callback tryOpenAssetConfig, invoke assetConfig page with an assetId.
]]

local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Images = require(Plugin.Core.Util.Images)
local AssetAnalyticsContextItem = require(Plugin.Core.Util.Analytics.AssetAnalyticsContextItem)

local Util = Plugin.Core.Util
local InsertToolPromise = require(Util.InsertToolPromise)
local InsertAsset = require(Util.InsertAsset)
local ContextMenuHelper = require(Util.ContextMenuHelper)
local CreatorInfoHelper = require(Util.CreatorInfoHelper)
local Category = require(Plugin.Core.Types.Category)
local FlagsList = require(Util.FlagsList)
local getStartupAssetId = require(Util.getStartupAssetId)

local getModal = ContextGetter.getModal
local getNetwork = ContextGetter.getNetwork
local withModal = ContextHelper.withModal

local Asset = require(Plugin.Core.Components.Asset.Asset)
local AssetPreviewWrapper = require(Plugin.Core.Components.Asset.Preview.AssetPreviewWrapper)
local MessageBox = require(Plugin.Core.Components.MessageBox.MessageBox)

local PermissionsConstants = require(Plugin.Core.Components.AssetConfiguration.Permissions.PermissionsConstants)

local GetAssets = require(Plugin.Core.Actions.GetAssets)
local PlayPreviewSound = require(Plugin.Core.Actions.PlayPreviewSound)
local PausePreviewSound = require(Plugin.Core.Actions.PausePreviewSound)
local ResumePreviewSound = require(Plugin.Core.Actions.ResumePreviewSound)
local PostInsertAssetRequest = require(Plugin.Core.Networking.Requests.PostInsertAssetRequest)
local SetAssetPreview = require(Plugin.Core.Actions.SetAssetPreview)
local GetPackageHighestPermission = require(Plugin.Core.Networking.Requests.GetPackageHighestPermission)

local Analytics = require(Plugin.Core.Util.Analytics.Analytics)

local withLocalization = ContextHelper.withLocalization

local ContextServices = require(Libs.Framework.ContextServices)

local AssetGridContainer = Roact.PureComponent:extend("AssetGridContainer")

local function nameForValueInEnum(enum, value)
	local items = enum:GetEnumItems()

	for _, item in ipairs(items) do
		if item.Value == value then
			return item.Name
		end
	end
	return
end

function AssetGridContainer:init(props)
	self.state = {
		hoveredAssetId = 0,
		isShowingToolMessageBox = false,
	}

	--[[
		We need to track when the user last triggered an insertion, because inserting
		an asset can take several seconds depending on the asset's loading speed. This
		means throttling inserts via "onAssetInserted" does not work as intended
		because a user can queue up several inserts of an asset which is not loaded yet,
		and "onAssetInserted" does not fire and update the last inserted time until
		the asset in question has finished loading.
	]]
	self.lastInsertAttemptTime = 0

	self.canInsertAsset = function()
		return (tick() - self.lastInsertAttemptTime > Constants.TIME_BETWEEN_ASSET_INSERTION)
			and not self.insertToolPromise:isWaiting()
	end

	self.openAssetPreview = function(assetData)
		local modal = getModal(self)
		modal.onAssetPreviewToggled(true)
		self.props.onPreviewToggled(true)
		self:setState({
			previewAssetData = assetData,
			openAssetPreviewStartTime = tick(),
		})

		if self.props.isPlaying then
			self.props.pauseASound()
		end

		-- TODO STM-146: Remove this once we are happy with the new MarketplaceAssetPreview event
		Analytics.onAssetPreviewSelected(assetData.Asset.Id)

		self.props.AssetAnalytics:get():logPreview(assetData)
	end

	self.closeAssetPreview = function(assetData)
		local modal = getModal(self)
		modal.onAssetPreviewToggled(false)
		self.props.onPreviewToggled(false)

		local endTime = tick()
		local startTime = self.state.openAssetPreviewStartTime
		local deltaMs = (endTime - startTime) * 1000
		Analytics.onAssetPreviewEnded(assetData.Asset.Id, deltaMs)

		self:setState({
			previewAssetData = Roact.None,
			openAssetPreviewStartTime = Roact.None,
		})
	end

	self.onAssetHovered = function(assetId)
		local modal = getModal(self)
		if self.state.hoveredAssetId == 0 and modal.canHoverAsset() then
			self:setState({
				hoveredAssetId = assetId,
			})
		end
	end

	self.onAssetHoverEnded = function(assetId)
		if self.state.hoveredAssetId == assetId then
			self:setState({
				hoveredAssetId = 0,
			})
		end
	end

	self.onFocusLost = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.Focus then
			self.onAssetHoverEnded()
		end
	end

	self.onPreviewAudioButtonClicked = function(assetId)
		local currentSoundId = self.props.currentSoundId
		if currentSoundId == assetId then
			if self.props.isPlaying then
				self.props.pauseASound()

				Analytics.onSoundPaused()
				Analytics.onSoundPausedCounter()

			else
				self.props.resumeASound()

				Analytics.onSoundPlayed()
				Analytics.onSoundPlayedCounter()
			end
		else
			self.props.playASound(assetId)

			Analytics.onSoundPlayed()
			Analytics.onSoundPlayedCounter()
		end
	end

	self.onMessageBoxClosed = function()
		self:setState({
			isShowingToolMessageBox = false,
		})

		self.insertToolPromise:insertToWorkspace()
	end

	self.onMessageBoxButtonClicked = function(index, action)
		self:setState({
			isShowingToolMessageBox = false,
		})

		if action == "yes" then
			self.insertToolPromise:insertToStarterPack()
		elseif action == "no" then
			self.insertToolPromise:insertToWorkspace()
		end
	end

	self.onInsertToolPrompt = function()
		self:setState({
			isShowingToolMessageBox = true,
		})
	end

	self.onAssetGridContainerChanged = function()
		if self.props.onAssetGridContainerChanged then
			self.props.onAssetGridContainerChanged()
		end
	end

	self.insertToolPromise = InsertToolPromise.new(self.onInsertToolPrompt)

	self.onAssetInsertionSuccesful = function(assetId)
		self.props.onAssetInserted(getNetwork(self), assetId)
		self.props.onAssetInsertionSuccesful()
	end

	self.tryCreateContextMenu = function(assetData, showEditOption, localizedContent)
		local asset = assetData.Asset
		local assetId = asset.Id
		local assetTypeId = asset.TypeId
		local plugin = self.props.Plugin:get()

		local isPackageAsset = Category.categoryIsPackage(self.props.categoryName)
		if isPackageAsset then
			local canEditPackage = (self.props.currentUserPackagePermissions[assetId] == PermissionsConstants.EditKey or
				self.props.currentUserPackagePermissions[assetId] == PermissionsConstants.OwnKey)
			showEditOption = canEditPackage
		end

		local context = assetData.Context
		local creatorTypeEnumValue

		-- TODO STM-406: Refactor creator types to be stored as Enum.CreatorType in Toolbox Rodux 
		-- The data for Creations is stored as Enum.CreatorType Values, whereas for other tabs
		-- it is stored as backend enum values with range [1, 2] instead of [0, 1]
		-- We can address this by storing Enum.CreatorType instead of numeric Values and converting to/from backend [1, 2]
		-- values in the network interfacing code.
		if context.toolboxTab == Category.CREATIONS_KEY then
			creatorTypeEnumValue = assetData.Creator.Type
		else
			creatorTypeEnumValue = CreatorInfoHelper.backendToClient(assetData.Creator.Type)
		end

		local trackingAttributes = {
			Category = nameForValueInEnum(Enum.AssetType, assetTypeId),
			SortType = context.sort,
			CreatorId = assetData.Creator.Id,
			CreatorType = nameForValueInEnum(Enum.CreatorType, creatorTypeEnumValue),
			SearchKeyword = context.searchKeyword,
			Position = context.position,
			SearchId = context.searchId,
			ViewInBrowser = true,
		}

		ContextMenuHelper.tryCreateContextMenu(plugin, assetId, assetTypeId, showEditOption, localizedContent, props.tryOpenAssetConfig, isPackageAsset, trackingAttributes)
	end

	self.tryInsert = function(assetData, assetWasDragged, insertionMethod)
		self.lastInsertAttemptTime = tick()

		local asset = assetData.Asset
		local assetId = asset.Id
		local assetName = asset.Name
		local assetTypeId = asset.TypeId

		local currentProps = self.props
		local categoryName = currentProps.categoryName
		local searchTerm = currentProps.searchTerm or ""
		local assetIndex = currentProps.assetIndex

		local currentCategoryName = categoryName
		
		local plugin = self.props.Plugin:get()
		InsertAsset.tryInsert({
				plugin = plugin,
				assetId = assetId,
				assetName = assetName,
				assetTypeId = assetTypeId,
				onSuccess = function(assetId, insertedInstance)
					self.onAssetInsertionSuccesful(assetId)
					insertionMethod = insertionMethod or (assetWasDragged and "DragInsert" or "ClickInsert")
					self.props.AssetAnalytics:get():logInsert(assetData, insertionMethod, insertedInstance)
				end,
				currentCategoryName = currentCategoryName,
				categoryName = categoryName,
				searchTerm = searchTerm,
				assetIndex = assetIndex,
			},
			self.insertToolPromise,
			assetWasDragged
		)
	end
end

function AssetGridContainer:didMount()
	local assetIdStr = getStartupAssetId()
	local assetId = tonumber(assetIdStr)

	if assetId then
		local ok, result = pcall(function()
			local props = self.props
			local localization = props.Localization
			local api = props.API:get()

			-- There is no API to get individual Toolbox item details in the same format as that which
			-- we use for fetching the whole page of Toolbox assets, so we map the fields from this API
			-- to the expected format from the whole-page batch API (IDE/Toolbox/Items)
			api.ToolboxService.V1.Items.details({
				items = {
					{
						id = assetId,
						itemType = "Asset",
					}
				}
			}):makeRequest():andThen(function(response)
				local responseItem = response.responseBody.data[1]

				if not responseItem then
					-- TODO STM-135: Replace these warnings with Lumberyak logs
					warn("Could not find asset information in response for", assetIdStr)

					Analytics.onTryAssetFailure(assetId)
					return
				end

				local assetData = {
					Asset = {
						Id = responseItem.asset.id,
						TypeId = responseItem.asset.typeId,
						AssetGenres = responseItem.asset.assetGenres,
						Name = responseItem.asset.name,
						Description = responseItem.asset.description,

					},
					Creator = {
						Name = responseItem.creator.name,
						Id = responseItem.creator.id,
						TypeId = responseItem.creator.type,
					},
				}

				if FlagsList:get("FFlagToolboxUseDevFrameworkAssetPreview") then
					assetData.Asset = Cryo.Dictionary.join(assetData.Asset, {
						Created = responseItem.asset.createdUtc,
						Updated = responseItem.asset.updatedUtc,
					})
				else
					local localeId = localization.getLocale()
					local created = DateTime.fromIsoDate(responseItem.asset.createdUtc)
					local updated = DateTime.fromIsoDate(responseItem.asset.updatedUtc)

					assetData.Asset = Cryo.Dictionary.join(assetData.Asset, {
						Created = created:FormatLocalTime("LLL", localeId),
						CreatedRaw = created.UnixTimestamp,
						Updated = updated:FormatLocalTime("LLL", localeId),
						UpdatedRaw = updated.UnixTimestamp,
					})
				end

				-- Add the asset data to the store, so that we can open AssetPreview
				self.props.dispatchGetAssets({
					assetData,
				})

				self.openAssetPreview(assetData)

				self.tryInsert(assetData, false)

				Analytics.onTryAsset(assetId)
			end, function(err)
				-- TODO STM-135: Replace these warnings with Lumberyak logs
				warn("Could not load asset information for", assetIdStr, err)

				Analytics.onTryAssetFailure(assetId)
			end)
		end)

		if not ok then
			-- TODO STM-135: Replace these warnings with Lumberyak logs
			warn("Failed to try asset", assetIdStr, tostring(result))
			Analytics.onTryAssetFailure(assetId)
		end
	end
end

function AssetGridContainer:willUnmount()
	self.insertToolPromise:destroy()
end

function AssetGridContainer.getDerivedStateFromProps(nextProps, lastState)
	local lastHoveredAssetStillVisible = false
	for _, assetTable in ipairs(nextProps.assetIds) do
		local assetId = assetTable[1]
		if lastState.hoveredAssetId == assetId then
			lastHoveredAssetStillVisible = true
			break
		end
	end

	if not lastHoveredAssetStillVisible then
		return {
			hoveredAssetId = 0
		}
	end
end

function AssetGridContainer:render()
	return withModal(function(_, modalStatus)
		return withLocalization(function(_, localizedContent)
			local props = self.props
			local state = self.state

			local assetIds = props.assetIds

			local position = props.Position or UDim2.new(0, 0, 0, 0)
			local size = props.Size or UDim2.new(1, 0, 1, 0)

			local currentSoundId = props.currentSoundId
			local isPlaying = props.isPlaying

			local previewAssetData = state.previewAssetData

			local isPackages = Category.categoryIsPackage(props.categoryName)
			local hoveredAssetId = modalStatus:canHoverAsset() and state.hoveredAssetId or 0
			local isShowingToolMessageBox = state.isShowingToolMessageBox

			local showPrices = Category.shouldShowPrices(props.categoryName)
			
			local cellSize
			if showPrices then
				cellSize = UDim2.new(0, Constants.ASSET_WIDTH_NO_PADDING, 0,
					Constants.ASSET_HEIGHT + Constants.PRICE_HEIGHT)
			else
				cellSize = UDim2.new(0, Constants.ASSET_WIDTH_NO_PADDING, 0, Constants.ASSET_HEIGHT)
			end

			local assetElements = {
				UIGridLayout = Roact.createElement("UIGridLayout", {
					CellPadding = UDim2.new(0, Constants.BETWEEN_ASSETS_HORIZONTAL_PADDING,
						0, Constants.BETWEEN_ASSETS_VERTICAL_PADDING),
					CellSize = cellSize,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					[Roact.Event.Changed] = self.onAssetGridContainerChanged,
				})
			}
			if isPackages and #assetIds ~= 0 then
				local assetIdList = {}
				local index = 1
				while index < PermissionsConstants.MaxPackageAssetIdsForHighestPermissionsRequest and assetIds[index] ~= nil do
					local assetId = assetIds[index][1]
					if not self.props.currentUserPackagePermissions[assetId] then
						table.insert(assetIdList, assetId)
					end
					index = index + 1
				end

				if #assetIdList ~= 0 then
					self.props.dispatchGetPackageHighestPermission(getNetwork(self), assetIdList)
				end
			end

			local function tryCreateLocalizedContextMenu(assetData, showEditOption)
				self.tryCreateContextMenu(assetData, showEditOption, localizedContent)
			end

			local isGroupPackageAsset = Category.categoryIsGroupPackages(props.categoryName)
			
			for index, asset in ipairs(assetIds) do
				local assetId = asset[1]
				local assetIndex = asset[2]

				local canEditPackage = (self.props.currentUserPackagePermissions[assetId] == PermissionsConstants.EditKey or
					self.props.currentUserPackagePermissions[assetId] == PermissionsConstants.OwnKey)

				-- If the asset is a group packages, then we want to check only want to show it if we have permission.
				-- if the category is not group packages, then we always want to show.
				local showAsset = (isGroupPackageAsset and canEditPackage) or not isGroupPackageAsset

				if assetElements[tostring(assetId)] then
					-- If the asset is in the grid multiple times, show it in the position of the first occurrence
					continue
				end

				assetElements[tostring(assetId)] = showAsset and Roact.createElement(Asset, {
					assetId = assetId,
					LayoutOrder = index,
					assetIndex = assetIndex,

					isHovered = assetId == hoveredAssetId,
					hoveredAssetId = hoveredAssetId,

					currentSoundId = currentSoundId,
					isPlaying = isPlaying,

					categoryName = props.categoryName,

					onAssetHovered = self.onAssetHovered,
					onAssetHoverEnded = self.onAssetHoverEnded,

					onPreviewAudioButtonClicked = self.onPreviewAudioButtonClicked,
					onAssetPreviewButtonClicked = self.openAssetPreview,

					canInsertAsset = self.canInsertAsset,
					tryInsert = self.tryInsert,
					tryCreateContextMenu = tryCreateLocalizedContextMenu,
				})
			end

			assetElements.ToolMessageBox = isShowingToolMessageBox and Roact.createElement(MessageBox, {
				Name = "ToolboxToolMessageBox",

				Title = "Insert Tool",
				Text = "Put this tool into the starter pack?",
				Icon = Images.INFO_ICON,

				onClose = self.onMessageBoxClosed,
				onButtonClicked = self.onMessageBoxButtonClicked,

				buttons = {
					{
						Text = "Yes",
						action = "yes",
					}, {
						Text = "No",
						action = "no",
					}
				}
			})

			assetElements.AssetPreview = previewAssetData and Roact.createElement(AssetPreviewWrapper, {
				assetData = previewAssetData,

				canInsertAsset = self.canInsertAsset,
				tryInsert = self.tryInsert,
				tryCreateContextMenu = tryCreateLocalizedContextMenu,
				onClose = self.closeAssetPreview
			})

			return Roact.createElement("Frame", {
				Position = position,
				Size = size,
				BackgroundTransparency = 1,

				[Roact.Event.InputEnded] = self.onFocusLost,
			}, assetElements)
		end)
	end)
end

ContextServices.mapToProps(AssetGridContainer, {
	API = ContextServices.API,
	Localization = ContextServices.Localization,
	Plugin = ContextServices.Plugin,
	AssetAnalytics = AssetAnalyticsContextItem,
})

local function mapStateToProps(state, props)
	state = state or {}

	local sound = state.sound or {}
	local pageInfo = state.pageInfo or {}

	local categoryName = pageInfo.categoryName or Category.DEFAULT.name

	return {
		currentSoundId = sound.currentSoundId or 0,
		isPlaying = sound.isPlaying or false,
		categoryName = categoryName,
		currentUserPackagePermissions = state.packages.permissionsTable or {},
	}
end

local function mapDispatchToProps(dispatch)
	return {
		dispatchGetAssets = function(assets)
			dispatch(GetAssets(assets))
		end,

		playASound = function(currentSoundId)
			dispatch(PlayPreviewSound(currentSoundId))
		end,

		pauseASound = function()
			dispatch(PausePreviewSound())
		end,

		resumeASound = function()
			dispatch(ResumePreviewSound())
		end,

		onAssetInserted = function(networkInterface, assetId)
			dispatch(PostInsertAssetRequest(networkInterface, assetId))
		end,

		onPreviewToggled = function(isPreviewing)
			dispatch(SetAssetPreview(isPreviewing))
		end,

		dispatchGetPackageHighestPermission = function(networkInterface, assetIds)
			dispatch(GetPackageHighestPermission(networkInterface, assetIds))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(AssetGridContainer)
