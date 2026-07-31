local Trove = {}
Trove.__index = Trove

local function cleanupItem(item)
	local t = typeof(item)
	if t == "function" then
		item()
	elseif t == "RBXScriptConnection" then
		item:Disconnect()
	elseif t == "Instance" then
		item:Destroy()
	elseif t == "table" then
		if item.Destroy then
			item:Destroy()
		elseif item.Disconnect then
			item:Disconnect()
		end
	end
end

function Trove.new()
	return setmetatable({ _items = {} }, Trove)
end

function Trove:Add(item, cleanupMethod)
	table.insert(self._items, { item = item, method = cleanupMethod })
	return item
end

function Trove:Remove(item)
	for i, entry in ipairs(self._items) do
		if entry.item == item then
			cleanupItem(item)
			table.remove(self._items, i)
			return true
		end
	end
	return false
end

function Trove:Clean()
	for i = #self._items, 1, -1 do
		local entry = self._items[i]
		if entry.method then
			entry.item[entry.method](entry.item)
		else
			cleanupItem(entry.item)
		end
		self._items[i] = nil
	end
end

function Trove:Extend()
	return self:Add(Trove.new())
end

function Trove:Destroy()
	self:Clean()
end

return Trove
