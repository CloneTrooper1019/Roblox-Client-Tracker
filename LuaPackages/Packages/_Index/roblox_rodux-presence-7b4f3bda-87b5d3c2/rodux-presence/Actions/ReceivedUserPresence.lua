local Action = require(script.Parent.Action)

return Action(script.Name, function(presenceModel)
	return {
		payload = presenceModel,
	}
end)
