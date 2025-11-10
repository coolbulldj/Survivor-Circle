local NetworkerAPI = require(script.Parent.Networker)

local ClientNetworker = NetworkerAPI.new()

ClientNetworker:AddEvent("GetTest", false)
ClientNetworker:CreateReplicatedTable("Test")

return ClientNetworker.Methods
