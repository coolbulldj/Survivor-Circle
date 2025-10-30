local MemoryStoreService = game:GetService("MemoryStoreService")

local Wrapper = {}
Wrapper.__index = Wrapper

local HashMapWrapper = {}
HashMapWrapper.__index = HashMapWrapper

function HashMapWrapper.new(Name: string)
	local NewHashMap = {}
	setmetatable(NewHashMap, Wrapper)

	NewHashMap.Name = Name
	NewHashMap._MemoryStore = MemoryStoreService:GetHashMap(Name)

	return NewHashMap
end

function HashMapWrapper:AddAsync() end

return Wrapper
