local Root = script:FindFirstAncestor("rodux-presence")
local Packages = Root.Parent
local Cryo = require(Packages.Cryo)
local t = require(Packages.t)

local Enums = require(Root.Enums)

local PresenceModel = {}

function PresenceModel.new(presence)
	assert(PresenceModel.isValid(presence))

	PresenceModel.__index = PresenceModel

	local self = presence

	setmetatable(self, PresenceModel)

	return self
end

function PresenceModel.mock(mergeTable)
	mergeTable = mergeTable or {}

	local self = PresenceModel.new({
		userPresenceType = mergeTable.userPresenceType or 0,
		lastLocation = mergeTable.lastLocation or "LastLocation",
		placeId = mergeTable.placeId or 123,
		rootPlaceId = mergeTable.rootPlaceId or 234,
		gameId = mergeTable.gameId or "Game-OoooOO-Id",
		universeId = mergeTable.universeId or 345,
		userId = mergeTable.userId or 456,
		lastOnline = mergeTable.lastOnline or "LastOnline-OOOoOO",
	})

	return self
end

function PresenceModel.format(presenceModel)
	return Cryo.Dictionary.join(presenceModel, {
		userPresenceType = Enums.PresenceType.fromRawValue(presenceModel.userPresenceType),
	})
end

PresenceModel.isValid = t.interface({
	userPresenceType = t.numberConstrained(0, 3),
	lastLocation = t.string,
	placeId = t.optional(t.union(t.numberPositive, t.string)),
	rootPlaceId = t.optional(t.union(t.numberPositive, t.string)),
	gameId = t.optional(t.string),
	universeId = t.optional(t.union(t.numberPositive, t.string)),
	userId = t.union(t.numberPositive, t.string),
	lastOnline = t.string,
})

return PresenceModel
