local CollectionService = game:GetService("CollectionService")

local Component = {}
local registry = {}

function Component.new(tag, class)
	if registry[tag] then
		return registry[tag]
	end

	local entry = {
		Tag = tag,
		Class = class,
		Instances = {},
	}
	registry[tag] = entry

	local function onAdded(instance)
		if entry.Instances[instance] then
			return
		end
		local ok, obj = pcall(class.new, instance)
		if not ok then
			warn("Component " .. tag .. " failed to construct on " .. instance:GetFullName() .. ": " .. tostring(obj))
			return
		end
		entry.Instances[instance] = obj
		if obj.Init then
			task.spawn(obj.Init, obj)
		end
	end

	local function onRemoved(instance)
		local obj = entry.Instances[instance]
		if not obj then
			return
		end
		entry.Instances[instance] = nil
		if obj.Destroy then
			obj:Destroy()
		end
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(onAdded)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(onRemoved)

	for _, instance in ipairs(CollectionService:GetTagged(tag)) do
		onAdded(instance)
	end

	return entry
end

function Component.GetInstances(tag)
	local entry = registry[tag]
	if not entry then
		return {}
	end
	local list = {}
	for _, obj in pairs(entry.Instances) do
		table.insert(list, obj)
	end
	return list
end

function Component.FromInstance(tag, instance)
	local entry = registry[tag]
	if not entry then
		return nil
	end
	return entry.Instances[instance]
end

return Component
