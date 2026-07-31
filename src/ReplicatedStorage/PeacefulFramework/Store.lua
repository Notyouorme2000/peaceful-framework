local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Store = {}
Store.__index = Store

local Profile = {}
Profile.__index = Profile

local function deepCopy(t)
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function reconcile(data, template)
	for k, v in pairs(template) do
		if data[k] == nil then
			if type(v) == "table" then
				data[k] = deepCopy(v)
			else
				data[k] = v
			end
		elseif type(v) == "table" and type(data[k]) == "table" then
			reconcile(data[k], v)
		end
	end
end

local function retry(fn, attempts)
	attempts = attempts or 5
	local lastErr
	for i = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		task.wait(1.5 * i)
	end
	return false, lastErr
end

function Store.new(name, template, autosaveInterval)
	local self = setmetatable({}, Store)
	self._name = name
	self._template = template
	self._dataStore = DataStoreService:GetDataStore(name)
	self._profiles = {}
	self._autosaveInterval = autosaveInterval or 120

	task.spawn(function()
		while true do
			task.wait(self._autosaveInterval)
			for player, profile in pairs(self._profiles) do
				self:Save(player)
			end
		end
	end)

	game:BindToClose(function()
		for player, profile in pairs(self._profiles) do
			self:Save(player)
		end
		if not RunService:IsStudio() then
			task.wait(1)
		end
	end)

	return self
end

function Store:Load(player)
	if self._profiles[player] then
		return self._profiles[player]
	end

	local key = "Player_" .. tostring(player.UserId)
	local ok, result = retry(function()
		return self._dataStore:GetAsync(key)
	end)

	local data = (ok and result) or {}
	reconcile(data, self._template)

	local profile = setmetatable({
		Player = player,
		Data = data,
		Key = key,
		Loaded = ok,
	}, Profile)

	self._profiles[player] = profile
	return profile
end

function Store:Get(player)
	return self._profiles[player]
end

function Store:Save(player)
	local profile = self._profiles[player]
	if not profile then
		return false
	end

	local key = profile.Key
	local data = profile.Data
	local ok = retry(function()
		self._dataStore:SetAsync(key, data)
	end)
	return ok
end

function Store:Release(player)
	self:Save(player)
	self._profiles[player] = nil
end

return Store
