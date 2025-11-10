local NetworkerAPI = require(script.Parent.Networker)

local ClientNetworker = NetworkerAPI.new()

ClientNetworker:AddEvent("GetTest", false)
ClientNetworker:AddReplicatedTable("")

return ClientNetworker.Methods
