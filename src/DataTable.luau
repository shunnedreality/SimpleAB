local SimpleAB = script.Parent;

local DataStore = require(SimpleAB.DataStore);

local UPDATE_INTERVAL_S = 5;

local function getDataStoreName(
	storeName: string
)
	return "store_" .. storeName
end

local DataTable = {};
DataTable.__index = DataTable;

export type DataTable = typeof(setmetatable({}, DataTable))

function DataTable.new<K, V>(
    storeName: string,
    props: { [K]: V }
)
	local self = setmetatable({
		storeName = storeName,
		props = props,
		dirty = false,
		fullyLoaded = false
	}, DataTable);
	
	task.spawn(self.__init, self);
	
	self:__bindToGameClose();
	
	return self;
end

function DataTable:__bindToGameClose()
	game:BindToClose(function()
		if self.dirty then
			self:__saveData(true);
		end
	end)
end

function DataTable:__init()
	while task.wait(UPDATE_INTERVAL_S) do
		if self.dirty then
			self:__saveData();
		end
	end
end

function DataTable:get(
	index
)
	if self.props[index] ~= nil then
		return self.props[index];
	elseif not self.fullyLoaded then
		local remoteData =
			DataStore:GetAsync(getDataStoreName(self.storeName));
		
		self.fullyLoaded = true;
		
		if remoteData then
			for key, value in pairs(remoteData) do
				if self.props[key] == nil then
					self.props[key] = value
				end
			end
		end

		return self.props[index];
	else
		return nil;
	end
end

function DataTable:set(
	index,
	value
)
	self.props[index] = value;
	
	self.dirty = true;
end

function DataTable:__saveData(
	isBlocking: boolean?
)
	self.dirty = false

	if isBlocking then
		DataStore:SetAsync(
			getDataStoreName(self.storeName),
			self.props
		)
	else
		task.spawn(
			DataStore.SetAsync,
			DataStore,
			getDataStoreName(self.storeName),
			self.props
		)
	end
end

function DataTable:append(
	data: any
)
	self:set(#self.props + 1, data)
end

return DataTable;