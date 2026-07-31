--[[
PEACEFUL FRAMEWORK - heres some usage examples!


FRAMEWORK (server)

local Framework = require(ReplicatedStorage.PeacefulFramework.Framework)

local MyService = Framework.CreateService("MyService", {
	Client = {},
})

function MyService:Init() end
function MyService:Start() end
function MyService.Client:Ping(player) return "pong" end

Framework.Start()


FRAMEWORK (client)

local Framework = require(ReplicatedStorage.PeacefulFramework.Framework)

local MyController = Framework.CreateController("MyController", {})
function MyController:Init() end
function MyController:Start() end

Framework.Start()

local MyService = Framework.GetService("MyService")
print(MyService:Ping())


SIGNAL

local Signal = require(ReplicatedStorage.PeacefulFramework.Signal)

local mySignal = Signal.new()
local conn = mySignal:Connect(function(x) print(x) end)
mySignal:Fire(5)
conn:Disconnect()


TROVE

local Trove = require(ReplicatedStorage.PeacefulFramework.Trove)

local trove = Trove.new()
trove:Add(part)
trove:Add(connection)
trove:Add(function() end)
trove:Clean()


NET (server)

local Net = require(ReplicatedStorage.PeacefulFramework.Net)

Net.Handle("Damage", function(player, amount) end)
Net.Listen("Ready", function(player) end)
Net.Fire(player, "Notify", "hello")
Net.FireAll("Announce", "server restart")


NET (client)

local Net = require(ReplicatedStorage.PeacefulFramework.Net)

local result = Net.Invoke("Damage", 10)
Net.Fire("Ready")
Net.Listen("Notify", function(msg) print(msg) end)


SCHEDULER

local Scheduler = require(ReplicatedStorage.PeacefulFramework.Scheduler)

local stop = Scheduler.Every(5, function() end)
stop()

Scheduler.Delay(2, function() end)

local debounced = Scheduler.Debounce(function() end, 1)
local throttled = Scheduler.Throttle(function() end, 1)


COMPONENT

local Component = require(ReplicatedStorage.PeacefulFramework.Component)

local Killbrick = {}
Killbrick.__index = Killbrick

function Killbrick.new(instance)
	local self = setmetatable({}, Killbrick)
	self.Instance = instance
	return self
end

function Killbrick:Init() end
function Killbrick:Destroy() end

Component.new("Killbrick", Killbrick)


STORE (server only)

local Store = require(ReplicatedStorage.PeacefulFramework.Store)

local PlayerData = Store.new("PlayerData_v1", { Coins = 0, Level = 1 })

game.Players.PlayerAdded:Connect(function(player)
	local profile = PlayerData:Load(player)
	profile.Data.Coins += 10
end)

game.Players.PlayerRemoving:Connect(function(player)
	PlayerData:Release(player)
end)
]]

return nil
