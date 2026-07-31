local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RunService:IsServer()

local remotesFolder = ReplicatedStorage:FindFirstChild("PeacefulFrameworkRemotes")
if not remotesFolder then
	if IS_SERVER then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "PeacefulFrameworkRemotes"
		remotesFolder.Parent = ReplicatedStorage
	else
		remotesFolder = ReplicatedStorage:WaitForChild("PeacefulFrameworkRemotes")
	end
end

local Net = {}

local function getOrCreateEvent(name)
	local remote = remotesFolder:FindFirstChild(name)
	if remote then
		return remote
	end
	if IS_SERVER then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
		return remote
	end
	return remotesFolder:WaitForChild(name)
end

local function getOrCreateFunction(name)
	local remote = remotesFolder:FindFirstChild(name)
	if remote then
		return remote
	end
	if IS_SERVER then
		remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = remotesFolder
		return remote
	end
	return remotesFolder:WaitForChild(name)
end

function Net.Fire(a, b, ...)
	if IS_SERVER then
		local player, name = a, b
		local remote = getOrCreateEvent(name)
		remote:FireClient(player, ...)
	else
		local name = a
		local remote = getOrCreateEvent(name)
		remote:FireServer(b, ...)
	end
end

function Net.FireAll(name, ...)
	assert(IS_SERVER, "Net.FireAll can only be called from the server")
	local remote = getOrCreateEvent(name)
	remote:FireAllClients(...)
end

function Net.Listen(name, fn)
	local remote = getOrCreateEvent(name)
	if IS_SERVER then
		return remote.OnServerEvent:Connect(fn)
	else
		return remote.OnClientEvent:Connect(fn)
	end
end

function Net.Invoke(name, ...)
	assert(not IS_SERVER, "Net.Invoke can only be called from the client")
	local remote = getOrCreateFunction(name)
	return remote:InvokeServer(...)
end

function Net.Handle(name, fn)
	assert(IS_SERVER, "Net.Handle can only be called from the server")
	local remote = getOrCreateFunction(name)
	remote.OnServerInvoke = fn
end

return Net
