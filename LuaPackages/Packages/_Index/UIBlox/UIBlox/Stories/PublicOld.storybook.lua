local Packages = script.Parent.Parent.Parent

local Roact = require(Packages.Roact)
local StoryMiddleware = require(script.Parent.StoryMiddleware)

return {
	storyRoots = {script.Parent.Parent.Parent.PublicOldStories},
	group = "/UIBlox",
	roact = Roact,
	mapStory = StoryMiddleware,
	fixedSize = true,
}
