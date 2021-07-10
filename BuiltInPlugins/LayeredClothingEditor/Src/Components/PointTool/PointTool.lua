-- libraries
local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Constants = require(Plugin.Src.Util.Constants)

local Point = require(Plugin.Src.Components.PointTool.Point)

local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local TableUtil = require(Plugin.Src.Util.TableUtil)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local Workspace = game.Workspace

local PointTool = Roact.PureComponent:extend("PointTool")

function PointTool:isHovered(deformer, pointIndex)
	local hoveredPoint = self.props.HoveredPoint
	return hoveredPoint ~= nil and hoveredPoint.Deformer == deformer and hoveredPoint.Index == pointIndex
end

function PointTool:isSelected(deformer, pointIndex)
	local selectedPoints = self.props.SelectedPoints
	if selectedPoints[deformer] then
		if selectedPoints[deformer][pointIndex] then
			return true
		end
	end
	return false
end

function PointTool:renderPoints()
	local props = self.props

	local pointData = props.PointData
	local seamData = props.SeamData
	local selectedPoints = props.SelectedPoints
	local editingCage = props.EditingCage

	local transparency = ModelUtil.transparencyFromLCEditorToProperty(props.CagesTransparency[editingCage])

	local theme = props.Stylizer

	local deformers = {}
	local adorns = {}

	local markedSeamPoints = {}
	if editingCage and pointData and pointData[editingCage] then
		for deformer, pointsPerDeformer in pairs(pointData[editingCage]) do
			local points = {}
			for pointIndex, point in pairs(pointsPerDeformer) do
				if not markedSeamPoints[deformer] or not markedSeamPoints[deformer][pointIndex] then
					local linkedPoints = seamData[editingCage] and seamData[editingCage][deformer] and seamData[editingCage][deformer][pointIndex]
					if linkedPoints then
						for _, linkPoint in ipairs(linkedPoints) do
							TableUtil:setNested(markedSeamPoints, {linkPoint.Deformer, linkPoint.Index}, true)
						end
					end
					TableUtil:setNested(markedSeamPoints, {deformer, pointIndex}, true)

					local selected = self:isSelected(deformer, pointIndex)
					local partCFrame = ModelUtil:getPartCFrame(deformer, editingCage)
					points[pointIndex] = Roact.createElement("Part", {
						Position = partCFrame * point.Position,
						Size = Vector3.new(theme.DefaultPointSize, theme.DefaultPointSize, theme.DefaultPointSize),
						Transparency = 1,
						CanCollide = false,
						Archivable = false,
					}, {
						[Constants.LCE_POINT_TAG] = Roact.createElement("BoolValue", {
							Archivable = false,
						}),
					})

					local adornee = ModelUtil:getPartFromDeformer(deformer)
					local toWorld = adornee.CFrame:inverse() * partCFrame
					table.insert(adorns, Roact.createElement(Point, {
						Position = toWorld * point.Position,
						Adornee = adornee,
						Selected = selected,
						Weight = selected and selectedPoints[deformer][pointIndex],
						Hovered = self:isHovered(deformer, pointIndex),
						Transparency = transparency
					}))
				end
			end
			deformers[deformer] = Roact.createElement("Folder", {
				Archivable = false,
			}, points)
		end
	end

	return deformers, adorns
end

function PointTool:render()
	local points, adorns = self:renderPoints()

	return Roact.createFragment({
		WSP = Roact.createElement(Roact.Portal, {
			target = Workspace,
		}, {
			RbfPoints = Roact.createElement("Folder", {
				Archivable = false,
			}, points),
		}),

		CG = Roact.createElement(Roact.Portal, {
			target = game:GetService("CoreGui"),
		}, {
			AdornPoints = Roact.createElement("Folder", {
				Archivable = false,
			}, adorns),
		}),
	})
end

ContextServices.mapToProps(PointTool,{
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
    local pointTool = state.pointTool
    local cageData = state.cageData
    local status = state.status
    local selectItem = state.selectItem

	return {
		SelectedPoints = pointTool.selectedPoints,
		HoveredPoint = status.hoveredPoint,
		PointData = cageData.pointData,
		PolyData = cageData.polyData,
		SeamData = cageData.seamData,
		ToolMode = status.toolMode,
		EditingCage = selectItem.editingCage,
		CagesTransparency = selectItem.cagesTransparency,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SelectRbfPoint = function(deformer, pointIndex, multiselect)
			dispatch(SelectRbfPoint(deformer, pointIndex, multiselect))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(PointTool)