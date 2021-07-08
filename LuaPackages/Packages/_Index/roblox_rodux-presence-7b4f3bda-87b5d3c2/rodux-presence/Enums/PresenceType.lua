local Packages = script:FindFirstAncestor("rodux-presence").Parent
local enumerate = require(Packages.enumerate)

return enumerate(script.Name, {
	Offline = 0,
	Online = 1,
	InGame = 2,
	InStudio = 3,
})
