local Workspace = game:GetService("Workspace")
local Plugin = script.Parent.Parent.Parent.Parent
local DraggerFramework = Plugin.Packages.DraggerFramework

local isValidJoint = function(rootInstance, joint)
	return joint:IsDescendantOf(rootInstance) and joint:IsA("BasePart")
end

return function(draggerContext, mouseRay, currentSelection)
	local hitItem, hitPosition = Workspace:FindPartOnRay(mouseRay)

	-- Selection favoring: If there is a selected object and a non-selected
	-- object almost exactly coincident underneath the mouse, then we should
	-- favor the selected one, even if due to floating point error the non
	-- selected one comes out slightly closer.
	-- Without this case, if you duplicate objects and try to drag them, you
	-- may end up dragging only one of the objects because you clicked on the
	-- old non-selected copy, as opposed to the selected one you meant to.
	if hitItem then
		local hitSelectedObject, hitSelectedPosition
			= Workspace:FindPartOnRayWithWhitelist(mouseRay, currentSelection)
		if hitSelectedObject and hitSelectedPosition:FuzzyEq(hitPosition) then
			hitItem = hitSelectedObject
		end
	end

	local hitDistance = (mouseRay.Origin - hitPosition).Magnitude

	local hitResult = draggerContext:gizmoRaycast(
		mouseRay.Origin, mouseRay.Direction, RaycastParams.new())
	if hitResult and
		(draggerContext:shouldDrawConstraintsOnTop() or (hitResult.Distance < hitDistance)) then
		hitDistance = hitResult.Distance
		hitItem = hitResult.Instance
	end

	if hitItem then
		local hitSelectable = hitItem
		if hitSelectable and isValidJoint(draggerContext.RootInstance, hitSelectable) then 
			return hitSelectable, hitItem, hitDistance
		end
	else
		return nil
	end
end