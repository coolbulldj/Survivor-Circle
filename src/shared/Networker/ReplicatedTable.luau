local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFldr = ReplicatedStorage.Shared
local DataParser = require(SharedFldr.DataParser)

local ReplicatedTable = {}
ReplicatedTable.__index = {}

function ReplicatedTable.new()
	local NewReplicatedTable = {}
	setmetatable(NewReplicatedTable, ReplicatedTable)

	NewReplicatedTable.Data = {}
	NewReplicatedTable.MetaData = {}

	NewReplicatedTable.MetaData.LastUpdated = os.time()

	return NewReplicatedTable
end

--Setting a value will rewrite the entire variable, and updating a value will only update a certain scope base on the table path

function ReplicatedTable:UpdateValue(NewValue, TablePath: string)
	if not TablePath then
		warn("Failed to provide table path while updating a shared table")
		return
	end
	local TableScope, IndexVal = DataParser.DecodeTablePath(self.Data, TablePath)

	TableScope[IndexVal] = NewValue
	return
end

function ReplicatedTable:SetTable(Value)
	self.Data = Value
end

function ReplicatedTable:AddValue(Key, Value, TablePath: string)
	local TableScope, IndexVal = DataParser.DecodeTablePath(self.Data, TablePath)

	if not TableScope[IndexVal] then
		warn("Failed to Add Value to Replicated Table; Provided table path leads to a nil value")
		return
	end

	if typeof(TableScope[IndexVal]) ~= "table" then
		warn("Failed to Add Value to Replicated Table; Provided table path leads to a non table value")
		return
	end

	TableScope[IndexVal][Key] = Value
end

return ReplicatedTable
