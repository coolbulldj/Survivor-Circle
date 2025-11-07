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

function Remote.new(object: RemoteEvent, ToServer: boolean, ParseList: ParseList)
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
		print(NewRemote)
		return NewRemote
	end

	--Receiver Methods
	NewRemote._RemoteConnections = {}
	setmetatable(NewRemote, Receiver)

	object.OnClientEvent:Connect(function(...)
		for _, callback in NewRemote._RemoteConnections do
			callback(...)
		end
	end)
	print(NewRemote)
	return NewRemote
end

local NetworkerAPI = {}
NetworkerAPI.__index = NetworkerAPI

function NetworkerAPI.new()
	local NetworkMethoder = {}
	setmetatable(NetworkMethoder, NetworkerAPI)

	NetworkMethoder.Methods = {}
	print(NetworkMethoder)

	return NetworkMethoder
end

function NetworkerAPI:AddEvent(Name, ToServer)
	local RemoteObject = RemotesFldr:WaitForChild(Name)

	local RemoteClass = Remote.new(RemoteObject, ToServer)

	self.Methods[Name] = RemoteClass
end

return NetworkerAPI
