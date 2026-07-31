local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()

local Net = require(script.Parent.Net)

local Framework = {}
Framework._services = {}
Framework._controllers = {}
Framework._started = false

local function remoteName(serviceName, methodName)
	return serviceName .. "::" .. methodName
end

function Framework.CreateService(name, definition)
	assert(IS_SERVER, "Framework.CreateService can only be called from the server")
	assert(not Framework._services[name], "Service already exists: " .. name)
	definition = definition or {}
	definition.Name = name
	Framework._services[name] = definition
	return definition
end

function Framework.CreateController(name, definition)
	assert(not IS_SERVER, "Framework.CreateController can only be called from the client")
	assert(not Framework._controllers[name], "Controller already exists: " .. name)
	definition = definition or {}
	definition.Name = name
	Framework._controllers[name] = definition
	return definition
end

function Framework.GetService(name)
	assert(not IS_SERVER, "Framework.GetService can only be called from the client")
	local proxy = {}
	proxy.Name = name
	setmetatable(proxy, {
		__index = function(_, methodName)
			return function(_, ...)
				return Net.Invoke(remoteName(name, methodName), ...)
			end
		end,
	})
	return proxy
end

function Framework.GetController(name)
	assert(not IS_SERVER, "Framework.GetController can only be called from the client")
	return Framework._controllers[name]
end

local function exposeServiceClient(service)
	if not service.Client then
		return
	end
	for methodName, fn in pairs(service.Client) do
		if type(fn) == "function" then
			Net.Handle(remoteName(service.Name, methodName), function(player, ...)
				return fn(service.Client, player, ...)
			end)
		end
	end
end

function Framework.Start()
	if Framework._started then
		return
	end
	Framework._started = true

	if IS_SERVER then
		for _, service in pairs(Framework._services) do
			exposeServiceClient(service)
		end
		for _, service in pairs(Framework._services) do
			if service.Init then
				service:Init()
			end
		end
		for _, service in pairs(Framework._services) do
			if service.Start then
				task.spawn(service.Start, service)
			end
		end
	else
		for _, controller in pairs(Framework._controllers) do
			if controller.Init then
				controller:Init()
			end
		end
		for _, controller in pairs(Framework._controllers) do
			if controller.Start then
				task.spawn(controller.Start, controller)
			end
		end
	end
end

return Framework
