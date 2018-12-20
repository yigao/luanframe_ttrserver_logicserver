require ("math")
module('bit', package.seeall) -- 实现按位运算

--默认按32位
local __bitNum = 32

--设置位数
function setBitNum(bitNum)
	__bitNum = bitNum
end

--按位同或
function bxnor(int1, int2)
	return __operaByBit(__bitxnor, int1, int2)
end

--按位异或
function bxor(int1, int2)
	return __operaByBit(__bitxor, int1, int2)
end

--按位与
function band(int1, int2)
	return __operaByBit(__bitand, int1, int2)
end

--按位或
function bor(int1, int2)
	return __operaByBit(__bitor, int1, int2)
end

--按位非
function bnot(integer)
	return __operaByBit(__bitnot, integer)
end

--按位操作
function __operaByBit(bitFunc, ...)
	local bDataLst = {}

	for i = 1, select("#", ...) do
		local bData = itob(select(i, ...))
		table.insert(bDataLst, bData)
	end

	for _, bData in ipairs(bDataLst) do
		for i = #bData + 1, __bitNum do
			table.insert(bData, 1, 0)
		end
	end

	local resData = {}
	for i = 1, __bitNum do
		local args = {}
		for _, bData in ipairs(bDataLst) do
			table.insert(args, bData[i])
		end
		table.insert(resData, bitFunc(unpack(args)))
	end

	return btoi(resData)
end

--按位同或
function __bitxnor(bit1, bit2)
	return (bit1 == bit2) and 1 or 0
end

--按位异或
function __bitxor(bit1, bit2)
	return (bit1 == bit2) and 0 or 1
end

--按位与
function __bitand(bit1, bit2)
	return (bit1 == 1 and bit2 == 1) and 1 or 0
end

--按位或
function __bitor(bit1, bit2)
	return (bit1 == 1 or bit2 == 1) and 1 or 0
end

--按位非
function __bitnot(bit)
	return 1 - bit
end

--2进制转换成10进制
function btoi(bData)
	return __ntoi(bData, 2)
end

--10进制转换成2进制
function itob(integer)
	return __iton(integer, 2)
end

--10进制转换成N进制
function __iton(integer, num)
	assert(type(integer) == "number")
	
	if integer == 0 then
		return {0}
	end

	local bNeg = integer < 0
	local ci = math.abs(integer)

	local nData = {}
	while ci > 0 do
		table.insert(nData, 1, ci % num)
		ci = math.floor(ci / num)
	end

	if bNeg then
		for i = #nData + 1, __bitNum do
			table.insert(nData, 1, num - 1)
		end
	end

	return nData
end

--N进制转换成10进制
function __ntoi(nData, num)
	assert(type(nData) == "table")

	local integer = 0
	for i, data in ipairs(nData) do
		integer = integer + data * math.pow(num, #nData - i) 
	end

	return integer
end

