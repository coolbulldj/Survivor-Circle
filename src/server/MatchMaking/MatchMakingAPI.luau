local MemoryStoreService = game:GetService("MemoryStoreService")

local MatchMakingAPI = {}

local MatchMaker = {}
MatchMaker.__index = MatchMaker

function MatchMaker.new(Name)
	local NewMatch = {}
	setmetatable(NewMatch, MatchMaker)

	return NewMatch
end

return MatchMakingAPI
