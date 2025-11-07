local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local MatchMakingAPI = {}

local MatchMaker = {}
MatchMaker.__index = MatchMaker

--Group method describes how partys are grouped, eg in squads, duos, etc

function MatchMaker.new(Name, MaxMembersPerMatch, GroupingMethod)
	local NewMatchMaker = {}
	setmetatable(NewMatchMaker, MatchMaker)

	return NewMatchMaker
end

function MatchMaker:QuenueParty(Party) end

local PartyClass = {}
PartyClass.__index = PartyClass

function PartyClass.new(Members)
	local NewParty = {}
	setmetatable(NewParty, PartyClass)

	NewParty._Members = Members
	NewParty._UUID = HttpService:GenerateGUID()

	return NewParty
end

function PartyClass:AddMember(userid: number)
	table.insert(self._Members, userid)
end

return MatchMakingAPI
