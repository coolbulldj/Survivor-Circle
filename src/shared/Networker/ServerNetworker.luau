local NetworkerAPI = require(script.Parent.Networker)

local ServerNetworker = NetworkerAPI.new()

ServerNetworker:AddEvent("GetTest", false)

return ServerNetworker.Methods
