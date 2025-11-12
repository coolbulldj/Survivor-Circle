local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFldr = ReplicatedStorage.Shared
local ServerNetworker = require(SharedFldr.NetworkerRecode.ServerNetworker)

local function OnPlrJoin(plr: Player)
	print(plr)
	ServerNetworker:CreateReplicatedTable("Test", {
		["Empty"] = true,
	}, plr)
end

for _, plr in ipairs(Players:GetPlayers()) do
	OnPlrJoin(plr)
end

Players.PlayerAdded:Connect(OnPlrJoin)

print(ServerNetworker)
task.wait(4)
ServerNetworker.GetTest:FireAll("typehsit")
