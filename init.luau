-- Chudware — Phantom Forces loader. Public repo; simple HttpGet.
local REPO = "https://raw.githubusercontent.com/Bees-D/Chudware-PhantomForces/master/"

local function load(path)
	local url = REPO .. path
	local ok, content = pcall(function() return game:HttpGet(url) end)
	if not ok then error("fetch " .. path .. ": " .. tostring(content)) end
	if not content or content == "" then error("empty " .. path) end
	local fn, err = loadstring(content, "@" .. path)
	if not fn then error("parse " .. path .. ": " .. tostring(err)) end
	return fn()
end

_G._chud_modules = {}
local Services = load("core/services.luau")
local Util     = load("core/util.luau")
local Tracker  = load("core/tracker.luau")
local Runtime  = load("core/runtime.luau")
local Config   = (function() local ok, c = pcall(load, "core/config.luau"); return ok and c or nil end)()
local Notify   = load("ui/notify.luau")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
Notify.setRayfield(Rayfield)

local Window = Rayfield:CreateWindow({
	Name = "Chudware · Phantom Forces",
	LoadingTitle = "Chudware PF",
	LoadingSubtitle = "reversed + live-verified",
	Theme = "Amethyst",
	DisableRayfieldPrompts = true,
	DisableBuildWarnings = true,
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local ctx = {
	services = Services, util = Util, tracker = Tracker,
	runtime = Runtime, config = Config, notify = Notify,
}

-- Tracker runs FIRST each frame (connected before Runtime's loop) so features read fresh targets.
Services.RunService.RenderStepped:Connect(function()
	pcall(Tracker.update)
end)

local FEATURES = {
	{ tab = "Visuals",  files = {
		"features/visuals/player_esp.luau", "features/visuals/chams.luau",
		"features/visuals/crosshair.luau", "features/visuals/fullbright.luau",
		"features/visuals/loot_esp.luau" } },
	{ tab = "Combat",   files = {
		"features/combat/aimbot.luau", "features/combat/triggerbot.luau" } },
	{ tab = "Weapons",  files = { "features/weapons/gun_mods.luau" } },
	{ tab = "Unlocks",  files = { "features/misc/unlock_attachments.luau" } },
	{ tab = "Misc",     files = { "features/misc/freecam.luau", "features/misc/fov.luau" } },
}

local loaded, failed = 0, 0
for _, grp in ipairs(FEATURES) do
	local tabObj = Window:CreateTab(grp.tab)
	for _, file in ipairs(grp.files) do
		local ok, feat = pcall(load, file)
		if ok and feat and feat.init then
			local ok2, err = pcall(feat.init, tabObj, ctx)
			if ok2 then loaded = loaded + 1 else failed = failed + 1; warn("[ChudPF] init " .. file .. ": " .. tostring(err)) end
		else
			failed = failed + 1; warn("[ChudPF] load " .. file .. ": " .. tostring(feat))
		end
	end
end

Runtime.start()  -- CRITICAL: connects RenderStepped/Heartbeat so loop features actually run
Notify.ok("Loaded " .. loaded .. " features" .. (failed > 0 and (" (" .. failed .. " failed)") or ""))
