-- getDeepValue.lua
-- getDeepValue(dictionary: table, keyPath: string) -> any?
--[[
	When given a deep dictionary and a keyPath, this will return the value within
	the dictionary at the keyPath. If the path is not valid, it will return nil.

	```
	local dictionary = {
		hello = {
			world = "foo",
		}
	}
	local result = getDeepValue(dictionary, "hello.world")
	print(result)
	> "foo"
	```
]]

return function(tab, keyPath)
	local currentNode = tab
	for _, key in ipairs(keyPath:split(".")) do
		if not currentNode[key] then
			return nil
		end

		currentNode = currentNode[key]
	end

	return currentNode
end
