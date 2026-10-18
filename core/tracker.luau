-- Identity tracker: workspace.Roots = anonymous through-wall positions for all players.
-- workspace.Players.<folder>.Model has NameTagGui.PlayerTag (username) but only when visible.
-- We map root Part -> {player, team} when a body is visible (nearest root), and persist it
-- keyed by the Part instance (PF reuses the same Part, only moving it).
local Services = _G._chud_modules.services
local Util = _G._chud_modules.util

local Tracker = {}
Tracker.targets = {} -- shared per-frame cache (populated by update())
local identity = setmetatable({}, { __mode = "k" }) -- rootPart -> {player, name, team, isEnemy, hpFrac}
local nameToPlayer = {}
local lastRoster = 0

local function refreshRoster()
	local now = tick()
	if now - lastRoster < 2 then return end
	lastRoster = now
	nameToPlayer = {}
	for _, p in ipairs(Services.Players:GetPlayers()) do
		nameToPlayer[p.Name] = p
	end
end

local function readBody(bodyFolder)
	local model = bodyFolder:FindFirstChildOfClass("Model")
	if not model then return nil end
	local name, hpFrac
	local part
	for _, x in ipairs(model:GetDescendants()) do
		if not name and x:IsA("TextLabel") and x.Name == "PlayerTag" then name = x.Text end
		if not hpFrac and x.Name == "Percent" and x:IsA("GuiObject") then
			hpFrac = x.Size.X.Scale
		end
		if not part and x:IsA("BasePart") then part = x end
	end
	if not part then return nil end
	return { name = name, pos = part.Position, hpFrac = hpFrac }
end

-- Call once per frame. Returns the list of live targets.
function Tracker.update()
	refreshRoster()
	local rootsFolder = Services.Roots()
	if not rootsFolder then return {} end

	local roots = {}
	for _, p in ipairs(rootsFolder:GetChildren()) do
		if p:IsA("BasePart") then roots[#roots + 1] = p end
	end

	-- refresh identity from visible bodies
	local bodies = Services.Bodies()
	if bodies then
		for _, bf in ipairs(bodies:GetChildren()) do
			local info = readBody(bf)
			if info then
				-- nearest root to this body
				local best, bestD = nil, 16 -- max 16 studs link
				for _, rp in ipairs(roots) do
					local d = (rp.Position - info.pos).Magnitude
					if d < bestD then bestD = d; best = rp end
				end
				if best then
					local player = info.name and nameToPlayer[info.name]
					identity[best] = {
						player = player,
						name = info.name,
						team = player and tostring(player.TeamColor) or nil,
						isEnemy = player and Util.isEnemy(player) or nil,
						hpFrac = info.hpFrac,
						seen = tick(),
					}
				end
			end
		end
	end

	-- build target list
	local targets = {}
	for _, rp in ipairs(roots) do
		local id = identity[rp]
		targets[#targets + 1] = {
			part = rp,
			pos = rp.Position,
			player = id and id.player or nil,
			name = id and id.name or nil,
			team = id and id.team or nil,
			isEnemy = id and id.isEnemy,      -- true/false/nil(unknown)
			hpFrac = id and id.hpFrac or nil,
			identified = id ~= nil,
		}
	end
	Tracker.targets = targets
	return targets
end

_G._chud_modules.tracker = Tracker
return Tracker
