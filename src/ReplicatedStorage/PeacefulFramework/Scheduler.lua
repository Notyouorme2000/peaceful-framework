local Scheduler = {}

function Scheduler.Every(interval, fn)
	local running = true
	task.spawn(function()
		while running do
			task.wait(interval)
			if running then
				fn()
			end
		end
	end)
	return function()
		running = false
	end
end

function Scheduler.Delay(seconds, fn)
	local cancelled = false
	task.delay(seconds, function()
		if not cancelled then
			fn()
		end
	end)
	return function()
		cancelled = true
	end
end

function Scheduler.Debounce(fn, cooldown)
	local lastCall = 0
	return function(...)
		local now = os.clock()
		if now - lastCall < cooldown then
			return
		end
		lastCall = now
		return fn(...)
	end
end

function Scheduler.Throttle(fn, interval)
	local queued = false
	return function(...)
		if queued then
			return
		end
		queued = true
		local args = { ... }
		task.delay(interval, function()
			queued = false
			fn(table.unpack(args))
		end)
	end
end

return Scheduler
