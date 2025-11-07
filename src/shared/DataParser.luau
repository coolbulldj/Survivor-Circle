local Parser = {}

local TablePathSeperator = "%;."

function Parser.DecodeTablePath(RootTable, Path: string)
	local PathSplit = Path:gsub(TablePathSeperator, "")

	local DataSegement = RootTable

	for i = 1, #PathSplit - 1 do
		local PathSegment = PathSplit[i]
		if not DataSegement[PathSegment] then
			warn("Couldn't find path segment for path elem:" .. PathSegment)
			return
		end
	end

	return DataSegement, PathSplit[#PathSplit]
end

function Parser.EncodeTablePath(Table, PathList) end

return Parser
