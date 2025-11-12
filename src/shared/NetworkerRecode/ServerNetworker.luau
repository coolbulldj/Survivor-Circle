local NetworkerAPI = require(script.Parent.NetworkerAPI)

local ServerNetworker = NetworkerAPI.new()

ServerNetworker:AddEvent("GetTest", false)

return ServerNetworker.Methods
