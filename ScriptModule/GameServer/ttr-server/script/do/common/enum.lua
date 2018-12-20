enum = {}

--[[
@file Enum type.
@brief In face, the enum type is a table in lua.
--]]

function enum.create(tbl, idx)
	local enumTable = {}
	local enumIdx = idx or 0

	for i, v in ipairs(tbl) do
		enumTable[v] = enumIdx + i
	end

	return enumTable
end
