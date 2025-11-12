local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local ProfileStore = require(Packages:WaitForChild("profilestore"))

local ProfileTemplate = require(script.Parent.ProfileTemplate)

local PlayerStore = ProfileStore.New("PlayerStore", ProfileTemplate)

local ProfileBaseKey = "Profile_"

local DataManager = {}

function DataManager.OnPlayerJoin(plr: Player)
	local FullProfileKey = ProfileBaseKey .. plr.UserId

	local Profile = PlayerStore:StartSessionAsync(FullProfileKey)
end

function DataManager.OnPlayerLeave() end

return DataManager
