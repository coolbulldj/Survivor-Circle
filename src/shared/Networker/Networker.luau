local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFldr = ReplicatedStorage:WaitForChild("Remotes")
local IsClient = game:GetService("RunService"):IsClient()

local ClientSender = {}
ClientSender.__index = ClientSender

function ClientSender.Fire() end

local ServerSender = {}
ServerSender.__index = ServerSender

function ServerSender:Fire(plr: Player, ...)
	self._object:Fire(plr, ...)
end

function ServerSender:FireAll(...)
	self._object:FireAllClients(...)
end

function ServerSender:FireInclude(ClientList, ...)
	for _, plr in ClientList do
		self._object:Fire(plr, ...)
	end
end

function ServerSender:FireExclude(ExcludeList, ...)
	for _, plr in ipairs(Players:GetPlayers()) do
		if table.find(ExcludeList, plr) then
			continue
		end
		self._object:Fire(plr, ...)
	end
end

local Receiver = {}
Receiver.__index = Receiver

function Receiver:On(callback)
	table.insert(self._RemoteConnections, callback)
end

local Remote = {}
Remote.__index = Remote

type ParseList = {
	[string]: (any) -> any,
}

function Remote.new(object: RemoteEvent | RemoteFunction, ToServer: boolean, ParseList: ParseList?)
	local NewRemote = {}
	print(IsClient, ToServer)
	--Firing Methods
	if IsClient == ToServer then
		--Means both values have to true or false, which means they fire in the right content,
		--eg (if is Client, and it's sending to the server) that is valid context

		if ToServer then
			setmetatable(NewRemote, ClientSender)
			NewRemote._object = object
		else
			setmetatable(NewRemote, ServerSender)
			NewRemote._object = object
		end
		return NewRemote
	end

	--Receiver Methods
	NewRemote._RemoteConnections = {}
	setmetatable(NewRemote, Receiver)

	if object.ClassName == "RemoteEvent" then
		local event = object :: RemoteEvent
		event.OnClientEvent:Connect(function(...)
			for _, callback in NewRemote._RemoteConnections do
				callback(...)
			end
		end)
	elseif object.ClassName == "RemoteFunction" then
		local func = object :: RemoteFunction

		func.OnClientInvoke(function(...)
			for _, callback in NewRemote._RemoteConnections do
				callback(...)
			end
		end)
	end

	return NewRemote
end

local NetworkerAPI = {}
NetworkerAPI.__index = NetworkerAPI

function NetworkerAPI.new()
	local NetworkMethoder = {}
	setmetatable(NetworkMethoder, NetworkerAPI)

	NetworkMethoder.Methods = {}

	return NetworkMethoder
end

function NetworkerAPI:AddEvent(Name, ToServer)
	local RemoteObject = RemotesFldr:WaitForChild(Name)

	local RemoteClass = Remote.new(RemoteObject, ToServer)

	self.Methods[Name] = RemoteClass

	return RemoteClass
end

local ReplicatedTableConstructor = require(script.Parent.ReplicatedTable)

local ReplicatedTables = {}

--Replicated Table Methods
local function SetupTableRemote(Name)
	local RemoteEvent
	if IsClient then
		RemoteEvent = RemotesFldr:WaitForChild(Name)
	else
		RemoteEvent = Instance.new("RemoteEvent")
		RemoteEvent.Name = Name
		RemoteEvent.Parent = RemotesFldr
	end
	local RemoteClass = Remote.new(RemoteEvent, false)

	return RemoteClass
end

local UpdateRepTableValRemote = SetupTableRemote("UpdateRepTableValRemote")
local AddRepTableValRemote = SetupTableRemote("AddRepTableValRemote")
local SetRepTableRemote = SetupTableRemote("SetRepTableRemote")

--Add Replicated Table to Methods
--[[
function NetworkerAPI:AddReplicatedTable(Name: string)
	local ReplicatedTable = ReplicatedTables[Name]

	if not ReplicatedTable then
		warn("No Replicated Table with Name:" .. Name .. " exists")
		return
	end

	return ReplicatedTable
end
--]]

function NetworkerAPI:CreateReplicatedTable(Name, Value, SpecificPlayer: Player?) --Reserved for Server, as this is an OOP method, Client Replicated Tables get created via a remote event
	local ReplicatedTable = ReplicatedTableConstructor.new() :: typeof(ReplicatedTableConstructor)

	ReplicatedTables[Name] = ReplicatedTable

	--Add Replicated Tables to Methods
	self.Methods[Name] = ReplicatedTable

	if IsClient then
		--The client doesn't write data so we don't fire data
		return
	end

	if not SpecificPlayer then
		--Must Add the table everytime a player joins
		Players.PlayerAdded:Connect(function(a0: Player)
			SetRepTableRemote(a0, ReplicatedTable.Data)
		end)
	end

	ReplicatedTable:OnAddValue(function(...)
		if SpecificPlayer then
			UpdateRepTableValRemote:Fire(SpecificPlayer)
			return
		end
		UpdateRepTableValRemote:FireAll(...)
	end)

	ReplicatedTable:OnAddValue(function(...)
		if SpecificPlayer then
			AddRepTableValRemote:Fire(SpecificPlayer, ...)
			return
		end
		AddRepTableValRemote:FireAll(...)
	end)

	ReplicatedTable:OnSetTable(function(...)
		if SpecificPlayer then
			SetRepTableRemote:Fire(SpecificPlayer, ...)
			return
		end
		SetRepTableRemote:FireAll(...)
	end)

	ReplicatedTable:SetTable(Value)
end

if IsClient then
	--Events/Remotes for Replicated Table
	UpdateRepTableValRemote:On(function(TableName, NewValue, TablePath)
		print("Updating Value")
		local ReplicatedTable = ReplicatedTables[TableName]

		if not ReplicatedTable then
			warn("Failed to Update Value in Replicated Table because can't find Table with Name:" .. TableName)
			return
		end

		ReplicatedTable:UpdateValue(NewValue, TablePath)
	end)

	AddRepTableValRemote:On(function(TableName, Key, Value, TablePath: string)
		local ReplicatedTable = ReplicatedTables[TableName]

		if not ReplicatedTable then
			warn("Failed to Add Value in Replicated Table because can't find Table with Name:" .. TableName)
			return
		end

		ReplicatedTable:AddValue(Key, Value, TablePath)
	end)

	SetRepTableRemote:On(function(TableName, Value)
		print("Setting value", Value)
		local ReplicatedTable = ReplicatedTables[TableName]

		if not ReplicatedTable then
			--Create a new Table, if not found.
			warn("Failed to Set Replicated table Value because can't find Table with Name:" .. TableName)
			return
		end

		ReplicatedTable:SetTable(Value)
	end)
end

return NetworkerAPI
