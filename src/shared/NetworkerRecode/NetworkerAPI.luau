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

	if IsClient == ToServer then
		--Means both values have to true or false, which means they fire in the right content,
		--eg (if is Client, and it's sending to the server) that is valid context
		NewRemote._Object = Object
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
		return IsClient and RemoteEvent.OnServerEvent:Connect(Callback) or RemoteEvent.OnClientEvent:Connect(Callback)
	end
end

function Remote:Once(Callback): RBXScriptConnection | nil
	local RemoteEvent = self._Object :: RemoteEvent
	return IsClient and RemoteEvent.OnServerEvent:Once(Callback) or RemoteEvent.OnClientEvent:Once(Callback)
end

function Remote:FireAll(...) end

function Remote:FireExcept(list, ...) end

function Remote:FireInclude(list, ...) end

function Remote:Fire(plr: Player?, ...)
	if IsClient then
		self._Object:Fire(...)
		return
	end

	if not plr then
		--Means there is no player when firing from server
		warn("Server Failed to pass player arguement")
		return
	end

	self._Object:Fire(plr, ...)
end

local ReplicatedTables = {}

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

function NetworkerMethods:CreateReplicatedTable(Name, SpeficePlayer:Player)

end

local NetworkerAPI = {}
NetworkerAPI.__index = NetworkerAPI

function NetworkerAPI.new()
	local NewNetworker = {}
	setmetatable(NewNetworker, NetworkerAPI)

	NewNetworker.Methods = {}

	return NewNetworker
end

function NetworkerAPI:AddRemoteEvent(Name: string, ToServer: boolean)
	local ProperName = Name .. "Event"

	local RemoteEvent = RemotesFldr:FindFirstChild(ProperName)

	if RemoteEvent then
		return Remote.new(RemoteEvent, ToServer)
	end

	if IsClient then
		RemoteEvent = RemotesFldr:WaitForChild(ProperName)
	else
		RemoteEvent = Instance.new("RemoteEvent")
		RemoteEvent.Name = ProperName
		RemoteEvent.Parent = RemotesFldr
	end

	return Remote.new(RemoteEvent, ToServer)
end

function NetworkerAPI:AddRemoteFunction(Name, ToServer: boolean))
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

	return Remote.new(RemoteFunction, ToServer)
end


return NetworkerAPI
