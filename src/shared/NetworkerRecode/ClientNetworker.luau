local NetworkerAPI = require(script.Parent.NetworkerAPI)

local ClientNetworker = NetworkerAPI.new()

ClientNetworker:AddEvent("GetTest", false)
ClientNetworker:InitReplicatedTable("Test")

return ClientNetworker.Methods
