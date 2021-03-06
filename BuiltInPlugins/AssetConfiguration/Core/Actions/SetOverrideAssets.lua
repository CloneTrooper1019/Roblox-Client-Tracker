local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Util = require(Libs.Framework.Util)
local Action = Util.Action

local FFlagImproveAssetCreationsPageFetching2 = game:GetFastFlag("ImproveAssetCreationsPageFetching2")

if FFlagImproveAssetCreationsPageFetching2 then
	return Action(script.Name, function(resultsArray)
		assert(typeof(resultsArray) == "table", "SetOverrideAssets resultsArray must be a table")
		return {
			resultsArray = resultsArray,
		}
	end)
else
	return Action(script.Name, function(totalResults, resultsArray, filteredResultsArray)
		return {
			totalResults = totalResults,
			resultsArray = resultsArray,
			filteredResultsArray = filteredResultsArray,
		}
	end)
end