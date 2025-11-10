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

function Remote.new(object: RemoteEvent|RemoteFunction, ToServer: boolean, ParseList: ParseList?)
	
	local NewRemote = {}

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
		local event = object::RemoteEvent
		event.OnClientEvent:Connect(function(...)
			for _, callback in NewRemote._RemoteConnections do
				callback(...)
			end
		end)
	elseif object.ClassName == "RemoteFunction" then
		local func = object::RemoteFunction

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

	if IsClient then
		--Creates a shared table automatically

	return NetworkMethoder
end

function NetworkerAPI:AddEvent(Name, ToServer)
	local RemoteObject = RemotesFldr:WaitForChild(Name)

	local RemoteClass = Remote.new(RemoteObject, ToServer)

	self.Methods[Name] = RemoteClass

	return RemoteClass
end

local ReplicatedTableConstructor = require(script.Parent.ReplicatedTable)

<<<<<<< HEAD
local ReplicatedTables = {}

--This method is reserve for the client for getting data
function NetworkerAPI:GetReplicatedTable(Name:string)
	local ReplicatedTable = ReplicatedTables[Name]

	if not ReplicatedTable then
		warn("No Replicated Table with Name:"..Name.." exists")
		return
	end

	return ReplicatedTable
end

--Replicated Table Methods
=======
--Replicated Table Methods
local ReplicatedTables = {}

function NetworkerAPI:AddTable(Name:string)
	local TableObject = ReplicatedTables[Name]

	if not TableObject then
		warn("Failed to find Replicated Table for Name:"..Name)
		return
	end	

	return TableObject
end


>>>>>>> f7759a5aa4d675e8be9dd337c78e18fe9f6ee7f7
local function SetupTableRemote(Name)
	local RemoteEvent
	if IsClient then
		RemoteEvent = RemotesFldr:WaitForChild("ReplicatedTableRemote")
	else
		RemoteEvent = Instance.new("RemoteEvent")
		RemoteEvent.Name = "ReplicatedTableRemote"
		RemoteEvent.Parent = RemotesFldr
	end
	local RemoteClass = Remote.new(RemoteEvent, not IsClient)

	return RemoteClass
end

local UpdateRepTableValRemote = SetupTableRemote("UpdateRepTableValRemote")
local AddRepTableValRemote = SetupTableRemote("AddRepTableValRemote")
local SetRepTableRemote = SetupTableRemote("SetRepTableRemote")

--Events/Remotes for Replicated Table
UpdateRepTableValRemote:On(function(Name, NewValue, TablePath)
	local ReplicatedTable = ReplicatedTables[Name]

	if not ReplicatedTable then
		warn("Failed to Update Value in Replicated Table because can't find Table with Name:"..Name)
		return
	end

	ReplicatedTable:UpdateValue(NewValue, TablePath)
end)

AddRepTableValRemote:On(function(Name)
	local ReplicatedTable = ReplicatedTables[Name]

	if not ReplicatedTable then
		--Create a new Table, if not found.
		ReplicatedTable = ReplicatedTableConstructor.new(Value)

		ReplicatedTables[Name] = ReplicatedTable
		return
	end
end)

SetRepTableRemote:On(function(Name, Value)
	local ReplicatedTable = ReplicatedTables[Name]

	if not ReplicatedTable then
		--Create a new Table, if not found.
		ReplicatedTable = ReplicatedTableConstructor.new(Value)

		ReplicatedTables[Name] = ReplicatedTable
		return
	end

	ReplicatedTable:SetTable(Value)
end)

<<<<<<< HEAD
=======
if IsClient then

	return NetworkerAPI
end

>>>>>>> f7759a5aa4d675e8be9dd337c78e18fe9f6ee7f7
return NetworkerAPI