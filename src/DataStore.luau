local DataStoreService = game:GetService("DataStoreService");

local DATASTORE_KEY = "$SIMPLEAB_DATA";

local DataStore: DataStore = DataStoreService:GetDataStore(DATASTORE_KEY);

return DataStore;