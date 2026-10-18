local Services = _G._chud_modules and _G._chud_modules.services or require(script.Parent.services)

local Util = {}

function Util.try(fn)
	local ok, result = pcall(fn)
	if ok then return result end
	return nil
end

function Util.alive(inst)
	local ok, p = pcall(function() return inst.Parent end)
	return ok and p ~= nil
end

function Util.worldToViewport(pos)
	local cam = Services.Camera()
	if not cam then return Vector3.new(), false end
	return cam:WorldToViewportPoint(pos)
end

function Util.distanceFromLocal(pos)
	local hrp = Services.HRP()
	if not hrp then return math.huge end
	return (hrp.Position - pos).Magnitude
end

function Util.positionOf(inst)
	if inst:IsA("BasePart") then return inst.Position end
	if inst:IsA("Model") then
		local pp = inst.PrimaryPart
		if pp then return pp.Position end
		local part = inst:FindFirstChildWhichIsA("BasePart")
		if part then return part.Position end
	end
	return nil
end

function Util.hitPart(char, name)
	if not char then return nil end
	local part = char:FindFirstChild(name)
	if part and part:IsA("BasePart") then return part end
	return nil
end

function Util.getHead(char)
	return Util.hitPart(char, "Head")
end

function Util.isEnemy(player)
	if player == Services.LocalPlayer then return false end
	if not player.Team or not Services.LocalPlayer.Team then return true end
	return player.Team ~= Services.LocalPlayer.Team
end

local hasDrawing = pcall(function() return Drawing and Drawing.new end)
Util.hasDrawing = hasDrawing

function Util.newDrawing(kind, props)
	if not hasDrawing then return nil end
	local ok, d = pcall(function()
		local obj = Drawing.new(kind)
		if props then for k, v in pairs(props) do obj[k] = v end end
		return obj
	end)
	return ok and d or nil
end

function Util.hideDrawing(d)
	if d then pcall(function() d.Visible = false end) end
end

function Util.destroyDrawing(d)
	if d then pcall(function() d:Remove() end) end
end

local highlightRegistry = {}
function Util.setHighlight(inst, props)
	if not Util.alive(inst) then return end
	local existing = highlightRegistry[inst]
	if existing and Util.alive(existing) then
		for k, v in pairs(props) do pcall(function() existing[k] = v end) end
		return
	end
	local h = Instance.new("Highlight")
	h.Adornee = inst
	for k, v in pairs(props) do pcall(function() h[k] = v end) end
	h.Parent = inst
	highlightRegistry[inst] = h
end

function Util.clearHighlight(inst)
	local h = highlightRegistry[inst]
	if h then pcall(function() h:Destroy() end) end
	highlightRegistry[inst] = nil
end

function Util.clearAllHighlights()
	for inst in pairs(highlightRegistry) do Util.clearHighlight(inst) end
end

Util.hasHookfunction = pcall(function() return hookfunction end)
Util.hasGetrawmetatable = pcall(function() return getrawmetatable end)

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.util = Util
return Util
