local SimpleAB = script;

local DataTable = require(SimpleAB.DataTable);
local DataStore = require(SimpleAB.DataStore);
local Cryptography = require(SimpleAB.Parent.cryptography);

local function getUserStore(
	testName: string
)
	return "user_store_" .. testName
end

local AB = {};
AB.__index = AB;

function AB.createTest(
	testName: string,
	hasControl: boolean
)
	local Users = DataTable.new(getUserStore(testName), {});

	return setmetatable({
		Users = Users,

		testName = testName,
		hasControl = hasControl
	}, AB)
end

function AB:__getUserBucket(
	userID: number
)
	local abTestSalt = self.testName;
	local userIDString = tostring(userID);

	local hashedValue = Cryptography.Hashing.MD5(
		buffer.fromstring(userIDString),
		buffer.fromstring(abTestSalt)
	);
	
	local hashSubstring = string.sub(hashedValue, 1, 5);
	local hashedValueNumber = tonumber(hashSubstring, 16);

	local bucketCount = 100
	local assignedBucket = hashedValueNumber % bucketCount;

	if self.hasControl then
		if assignedBucket < 50 then
			return -1
		elseif assignedBucket < 75 then
			return 0
		else
			return 1
		end
	else
		if assignedBucket < 50 then
			return 0
		else
			return 1
		end
	end
end

function AB:getUserData(
	userID: number
)
	local userBucket = self.Users:get(userID);

	if not userBucket then
		userBucket = self:__getUserBucket(userID);

		self.Users:set(userID, userBucket)
	end

	return userBucket;
end

function AB:getVariantLabel(
	fromVariant: number
): "ControlVariant" | "VariantA" | "VariantB"
	if fromVariant == -1 then
		return "ControlVariant"
	elseif fromVariant == 0 then
		return "VariantA"
	else
		return "VariantB"
	end
end

return AB