local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFldr = ReplicatedStorage.Shared
local DataParser = require(SharedFldr.DataParser)

local SharedValue = {}
SharedValue.__index = {}

function SharedValue.new(Data)
	local NewSharedValue = {}
	setmetatable(NewSharedValue, SharedValue)

	NewSharedValue.Data = Data
	NewSharedValue._DataType = typeof(Data)

	NewSharedValue._LastUpdated = os.clock()
end

--Setting a value will set the data type, and updating a value will ensure the value follows the type

function SharedValue:UpdateValue(NewValue, TablePath)
	if typeof(NewValue) ~= self._DataType then
		warn(
			"Attempted to update data value with type "
				.. typeof(NewValue)
				.. " value must be of type "
				.. self._DataType
		)
		return
	end

	if self._DataType == "table" then
		return
	end

	self.Data = NewValue
end

function SharedValue:SetValue() end

function SharedValue:AddValue() end

return SharedValue
