local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()

local RemotesFldr = ReplicatedStorage:WaitForChild("Remotes")

local Remote = {}
Remote.__index = Remote

type SerializedRemote = {
	["_Object"]: RemoteFunction | RemoteEvent,
	["_RemoteFunctionCB"]: (any) -> any?,
	["IsRemoteFunction"]: boolean,
}

type CombinedRemote = typeof(Remote) & SerializedRemote

function Remote.new(Object: RemoteEvent | RemoteFunction | UnreliableRemoteEvent, ToServer: boolean)
	local NewRemote = {}
	setmetatable(NewRemote, Remote)
	NewRemote.IsRemoteFunction = Object.ClassName == "RemoteFunction"
	NewRemote._Object = Object
	if IsClient == ToServer then
		--Means both values have to true or false, which means they fire in the right content,
		--eg (if is Client, and it's sending to the server) that is valid context
		return NewRemote
	end

	return NewRemote
end

function Remote:On(Callback): RBXScriptConnection | nil
	if self.IsRemoteFunction then
		self._RemoteFunctionCB = Callback
		return
	else
		local RemoteEvent = self._Object :: RemoteEvent
		return IsClient and RemoteEvent.OnClientEvent:Connect(Callback) or RemoteEvent.OnServerEvent:Connect(Callback)
	end
end

function Remote:Once(Callback): RBXScriptConnection
	local RemoteEvent = self._Object :: RemoteEvent
	return IsClient and RemoteEvent.OnClientEvent:Once(Callback) or RemoteEvent.OnServerEvent:Once(Callback)
end

function Remote:FireAll(...) end

function Remote:FireExcept(list, ...) end

function Remote:FireInclude(list, ...) end

function Remote:Fire(plr: Player?, ...)
	if IsClient then
		if self.IsRemoteFunction then
			local RemoteFunction = self._Object :: RemoteFunction

			RemoteFunction:InvokeServer(...)
			return
		end

		local RemoteEvent = self._Object :: RemoteEvent

		RemoteEvent:FireServer(...)

		return
	end

	if not plr then
		--Means there is no player when firing from server
		warn("Server Failed to pass player arguement")
		return
	end

	if self.IsRemoteFunction then
		local RemoteFunction = self._Object :: RemoteFunction

		RemoteFunction:InvokeClient(plr, ...)
		return
	end

	local RemoteEvent = self._Object :: RemoteEvent

	RemoteEvent:FireClient(plr, ...)
end

local ReplicatedTableConstructor = require(script.Parent.ReplicatedTable)
local ReplicatedTables = {}

local function SetupReplicatedEvent(Name)
	local ProperName = Name .. "Event"

	local RemoteEvent = RemotesFldr:FindFirstChild(ProperName)

	if RemoteEvent then
		return Remote.new(RemoteEvent, false)
	end

	if IsClient then
		RemoteEvent = RemotesFldr:WaitForChild(ProperName)
	else
		RemoteEvent = Instance.new("RemoteEvent")
		RemoteEvent.Name = ProperName
		RemoteEvent.Parent = RemotesFldr
	end

	return Remote.new(RemoteEvent, false)
end

local TableUpdate = SetupReplicatedEvent("TableUpdate")
local TableAdd = SetupReplicatedEvent("TableAdd")
local TableSet = SetupReplicatedEvent("TableSet")

local NetworkerMethods = {} --This are functions associated with the methods, tied to the Networker's methods
NetworkerMethods.__index = NetworkerMethods

function NetworkerMethods:GetReplicatedTable(Name: string)
	local ReplicatedTable = ReplicatedTables[Name]

	if not ReplicatedTable then
		warn("Failed to get Replicated Table for Name:" .. Name)
		return
	end

	return ReplicatedTable
end

function NetworkerMethods:CreateReplicatedTable(Name, Value, SpeficePlayer) --Reserved for server
	local NewReplicatedTable = ReplicatedTableConstructor.new()

	NewReplicatedTable:OnAddValue(function(...)
		if SpeficePlayer then
			TableAdd:Fire(SpeficePlayer, Name, ...)
		else
			TableAdd:FireAll(Name, ...)
		end
	end)

	NewReplicatedTable:OnSetTable(function(...)
		if SpeficePlayer then
			TableSet:Fire(SpeficePlayer, Name, ...)
		else
			TableSet:FireAll(Name, ...)
		end
	end)

	NewReplicatedTable:OnUpdateValue(function(...)
		if SpeficePlayer then
			TableUpdate:Fire(SpeficePlayer, Name, ...)
		else
			TableUpdate:FireAll(Name, ...)
		end
	end)

	ReplicatedTables[Name] = NewReplicatedTable

	NewReplicatedTable:SetTable(Value)
end

if IsClient then
	--Link Replicated Table Events to update the table
	TableUpdate:On(function(TableName, NewValue, TablePath)
		print("Updating Value")
		local ReplicatedTable = ReplicatedTables[TableName]

		if not ReplicatedTable then
			warn("Failed to Update Value in Replicated Table because can't find Table with Name:" .. TableName)
			return
		end

		ReplicatedTable:UpdateValue(NewValue, TablePath)
	end)

	TableAdd:On(function(TableName, Key, Value, TablePath: string)
		local ReplicatedTable = ReplicatedTables[TableName]

		if not ReplicatedTable then
			warn("Failed to Add Value in Replicated Table because can't find Table with Name:" .. TableName)
			return
		end

		ReplicatedTable:AddValue(Key, Value, TablePath)
	end)

	TableSet:On(function(TableName, Value)
		local ReplicatedTable = ReplicatedTables[TableName]

		if not ReplicatedTable then
			--Create a new Table, if not found.
			warn("Failed to Set Replicated table Value because can't find Table with Name:" .. TableName)
			return
		end

		ReplicatedTable:SetTable(Value)
	end)
end

local NetworkerAPI = {}
NetworkerAPI.__index = NetworkerAPI

function NetworkerAPI.new()
	local NewNetworker = {}
	setmetatable(NewNetworker, NetworkerAPI)

	NewNetworker.Methods = {}
	setmetatable(NewNetworker.Methods, NetworkerMethods)

	return NewNetworker
end

function NetworkerAPI:AddEvent(Name: string, ToServer: boolean)
	local ProperName = Name .. "Event"

	local RemoteEvent = RemotesFldr:FindFirstChild(ProperName)

	if RemoteEvent then
		local RemoteClass = Remote.new(RemoteEvent, ToServer)

		self.Methods[Name] = RemoteClass
	end

	if IsClient then
		RemoteEvent = RemotesFldr:WaitForChild(ProperName)
	else
		RemoteEvent = Instance.new("RemoteEvent")
		RemoteEvent.Name = ProperName
		RemoteEvent.Parent = RemotesFldr
	end

	local RemoteClass = Remote.new(RemoteEvent, ToServer)

	self.Methods[Name] = RemoteClass

	return
end

function NetworkerAPI:AddFunction(Name, ToServer: boolean)
	local ProperName = Name .. "Function"
	local RemoteFunction = RemotesFldr:FindFirstChild(ProperName)

	if RemoteFunction then
		return Remote.new(RemoteFunction, ToServer)
	end

	if IsClient then
		RemoteFunction = RemotesFldr:WaitForChild(ProperName)
	else
		RemoteFunction = Instance.new("RemoteEvent")
		RemoteFunction.Name = ProperName
		RemoteFunction.Parent = RemotesFldr
	end

	local RemoteClass = Remote.new(RemoteFunction, ToServer)

	self.Methods[Name] = RemoteClass

	return
end

function NetworkerAPI:InitReplicatedTable(Name) --Reservered for client
	local NewReplicatedTable = ReplicatedTableConstructor.new()

	ReplicatedTables[Name] = NewReplicatedTable
end

return NetworkerAPI
