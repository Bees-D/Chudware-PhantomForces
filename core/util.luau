local Services = _G._chud_modules and _G._chud_modules.services

local Util = {}

function Util.try(fn) local ok, r = pcall(fn); if ok then return r end; return nil end
function Util.alive(inst) local ok, p = pcall(function() return inst.Parent end); return ok and p ~= nil end

function Util.worldToViewport(pos)
	local cam = Services.Camera()
	if not cam then return Vector3.new(), false end
	return cam:WorldToViewportPoint(pos)
end

function Util.distanceFromCam(pos)
	local cam = Services.Camera()
	if not cam then return math.huge end
	return (cam.CFrame.Position - pos).Magnitude
end

-- team: PF uses TeamColor (no Team objects)
function Util.isEnemy(player)
	local lp = Services.LocalPlayer
	if player == lp then return false end
	local lt = lp and lp.TeamColor
	local pt = player and player.TeamColor
	if not lt or not pt then return true end
	return tostring(pt) ~= tostring(lt)
end

-- ===== DB patch helpers (require is cached => mutates the live table) =====
function Util.findProductionContent()
	for _, c in ipairs(game:GetChildren()) do
		local pc = Util.try(function()
			local content = c:FindFirstChild("Content")
			return content and content:FindFirstChild("ProductionContent")
		end)
		if pc then return pc end
	end
	return nil
end

function Util.patchTableKey(tbl, keyName, value, depth, seen)
	depth = depth or 0; seen = seen or {}
	if type(tbl) ~= "table" or depth > 8 or seen[tbl] then return 0 end
	seen[tbl] = true
	if setreadonly then pcall(setreadonly, tbl, false) end
	local n = 0
	for k, v in pairs(tbl) do
		if k == keyName then
			if pcall(function() tbl[k] = value end) then n = n + 1 end
		elseif type(v) == "table" then
			n = n + Util.patchTableKey(v, keyName, value, depth + 1, seen)
		end
	end
	return n
end

-- set EVERY numeric leaf inside a named subtable to `value` (for recoil/sway zeroing)
function Util.zeroSubtable(tbl, subName, value, depth, seen)
	depth = depth or 0; seen = seen or {}
	if type(tbl) ~= "table" or depth > 8 or seen[tbl] then return 0 end
	seen[tbl] = true
	local n = 0
	for k, v in pairs(tbl) do
		if k == subName and type(v) == "table" then
			n = n + Util.setAllNumbers(v, value)
		elseif type(v) == "table" then
			n = n + Util.zeroSubtable(v, subName, value, depth + 1, seen)
		end
	end
	return n
end

function Util.setAllNumbers(tbl, value, depth, seen)
	depth = depth or 0; seen = seen or {}
	if type(tbl) ~= "table" or depth > 8 or seen[tbl] then return 0 end
	seen[tbl] = true
	if setreadonly then pcall(setreadonly, tbl, false) end
	local n = 0
	for k, v in pairs(tbl) do
		if type(v) == "number" then
			if pcall(function() tbl[k] = value end) then n = n + 1 end
		elseif type(v) == "table" then
			n = n + Util.setAllNumbers(v, value, depth + 1, seen)
		end
	end
	return n
end

function Util.forEachWeapon(fn)
	local pc = Util.findProductionContent()
	if not pc then return 0 end
	local wdb = pc:FindFirstChild("WeaponDatabase")
	if not wdb then return 0 end
	local count = 0
	for _, d in ipairs(wdb:GetDescendants()) do
		if Util.try(function() return d:IsA("ModuleScript") end) then
			local ok, m = pcall(require, d)
			if ok and type(m) == "table" then
				if pcall(fn, m) then count = count + 1 end
			end
		end
	end
	return count
end

function Util.forEachAttachment(fn)
	local pc = Util.findProductionContent()
	if not pc then return 0 end
	local adb = pc:FindFirstChild("AttachmentDatabase")
	if not adb then return 0 end
	local count = 0
	for _, d in ipairs(adb:GetDescendants()) do
		if Util.try(function() return d:IsA("ModuleScript") end) then
			local ok, m = pcall(require, d)
			if ok and type(m) == "table" then
				if pcall(fn, m) then count = count + 1 end
			end
		end
	end
	return count
end

-- ===== Drawing =====
local hasDrawing = pcall(function() return Drawing and Drawing.new end)
Util.hasDrawing = hasDrawing
function Util.newDrawing(kind, props)
	if not hasDrawing then return nil end
	local ok, d = pcall(function()
		local o = Drawing.new(kind)
		if props then for k, v in pairs(props) do o[k] = v end end
		return o
	end)
	return ok and d or nil
end
function Util.hideDrawing(d) if d then pcall(function() d.Visible = false end) end end
function Util.removeDrawing(d) if d then pcall(function() d:Remove() end) end end

-- ===== Highlight registry (chams) =====
local hl = {}
function Util.setHighlight(inst, props)
	if not Util.alive(inst) then return end
	local h = hl[inst]
	if h and Util.alive(h) then
		for k, v in pairs(props) do pcall(function() h[k] = v end) end
		return
	end
	h = Instance.new("Highlight")
	for k, v in pairs(props) do pcall(function() h[k] = v end) end
	h.Adornee = inst
	h.Parent = inst
	hl[inst] = h
end
function Util.clearHighlight(inst)
	local h = hl[inst]
	if h then pcall(function() h:Destroy() end) end
	hl[inst] = nil
end
function Util.clearAllHighlights() for i in pairs(hl) do Util.clearHighlight(i) end end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.util = Util
return Util
