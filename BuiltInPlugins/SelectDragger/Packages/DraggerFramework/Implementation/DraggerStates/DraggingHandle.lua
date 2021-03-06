local DraggerFramework = script.Parent.Parent.Parent
local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local getEngineFeatureModelPivotVisual = require(DraggerFramework.Flags.getEngineFeatureModelPivotVisual)

local DraggingHandle = {}
DraggingHandle.__index = DraggingHandle

function DraggingHandle.new(draggerToolModel, draggingHandles, draggingHandleId)
	local self = setmetatable({
		_draggerToolModel = draggerToolModel,
	}, DraggingHandle)
	self:_init(draggingHandles, draggingHandleId)
	return self
end

function DraggingHandle:enter()
end

function DraggingHandle:leave()
end

function DraggingHandle:_init(draggingHandles, draggingHandleId)
	assert(draggingHandleId, "Missing draggingHandleId")

	self._draggerToolModel._sessionAnalytics.handleDrags = self._draggerToolModel._sessionAnalytics.handleDrags + 1
	self._draggerToolModel._boundsChangedTracker:uninstall()
	draggingHandles:mouseDown(self._draggerToolModel._draggerContext:getMouseRay(), draggingHandleId)
	self._draggingHandleId = draggingHandleId
	self._draggingHandles = draggingHandles
end

function DraggingHandle:render()
	self._draggerToolModel:setMouseCursor(StandardCursor.getClosedHand())

	return self._draggingHandles:render(self._draggingHandleId)
end

function DraggingHandle:processSelectionChanged()
	-- Re-init the drag if the selection changes.
	self:_endHandleDrag()
	self:_init(self._draggingHandles, self._draggingHandleId)
end

function DraggingHandle:processMouseDown()
	error("Mouse should already be down while dragging handle.")
end

function DraggingHandle:processViewChanged()
	self._draggingHandles:mouseDrag(
		self._draggerToolModel._draggerContext:getMouseRay())
end

function DraggingHandle:processMouseUp()
	self:_endHandleDrag()
	self._draggerToolModel:transitionToState(DraggerStateType.Ready)
end

function DraggingHandle:processKeyDown(keyCode)
	if self._draggingHandles.keyDown then
		if self._draggingHandles:keyDown(keyCode) then
			-- Update the drag
			self:processViewChanged()
			if getEngineFeatureModelPivotVisual() then
				self._draggerToolModel:_scheduleRender()
			end
		end
	end
end

function DraggingHandle:processKeyUp(keyCode)
	if self._draggingHandles.keyUp then
		if self._draggingHandles:keyUp(keyCode) then
			-- Update the drag
			self:processViewChanged()
			if getEngineFeatureModelPivotVisual() then
				self._draggerToolModel:_scheduleRender()
			end
		end
	end
end

function DraggingHandle:_endHandleDrag()
	-- Commit the results of using the tool
	local newSelectionInfoHint = self._draggingHandles:mouseUp(
		self._draggerToolModel._draggerContext:getMouseRay())
	self._draggerToolModel:_updateSelectionInfo(newSelectionInfoHint) -- Since the selection has been edited by Implementation

	self._draggerToolModel._boundsChangedTracker:install()

	self._draggerToolModel:getSchema().setActivePoint(
		self._draggerToolModel._draggerContext,
		self._draggerToolModel._selectionInfo)

	self._draggerToolModel:_analyticsSendHandleDragged(self._draggingHandleId)
end

return DraggingHandle