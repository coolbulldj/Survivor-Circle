local NetworkerAPI = require(script.Parent.Networker)

local ServerNetworker = NetworkerAPI.new()

ServerNetworker:AddEvent("GetTest", false)

local TestShared = {}

return ServerNetworker.Methods
