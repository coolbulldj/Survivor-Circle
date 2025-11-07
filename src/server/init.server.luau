local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFldr = ReplicatedStorage.Shared
local ServerNetworker = require(SharedFldr.Networker.ServerNetworker)

print(ServerNetworker)
task.wait(4)
ServerNetworker.GetTest:FireAll("typehsit")
