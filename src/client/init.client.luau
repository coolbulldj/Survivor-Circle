local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFldr = ReplicatedStorage:WaitForChild("Shared")
local ClientNetworker = require(SharedFldr:WaitForChild("Networker"):WaitForChild("ClientNetworker"))

ClientNetworker.GetTest:On(function(text)
	print(text)
end)

print(ClientNetworker)
