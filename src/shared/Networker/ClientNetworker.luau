local NetworkerAPI = require(script.Parent.Networker)

local ClientNetworker = NetworkerAPI.new()

ClientNetworker:AddEvent("GetTest", false)

return ClientNetworker.Methods
