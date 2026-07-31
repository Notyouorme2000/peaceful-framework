local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
	local self = setmetatable({}, Connection)
	self._signal = signal
	self._fn = fn
	self.Connected = true
	return self
end

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local list = self._signal._connections
	for i, conn in ipairs(list) do
		if conn == self then
			table.remove(list, i)
			break
		end
	end
end

function Signal.new()
	return setmetatable({ _connections = {} }, Signal)
end

function Signal:Connect(fn)
	local conn = Connection.new(self, fn)
	conn._fn = fn
	table.insert(self._connections, conn)
	return conn
end

function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Wait()
	local thread = coroutine.running()
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:Fire(...)
	for _, conn in ipairs(table.clone(self._connections)) do
		if conn.Connected then
			task.spawn(conn._fn, ...)
		end
	end
end

function Signal:DisconnectAll()
	for _, conn in ipairs(table.clone(self._connections)) do
		conn:Disconnect()
	end
end

function Signal:Destroy()
	self:DisconnectAll()
end

return Signal
