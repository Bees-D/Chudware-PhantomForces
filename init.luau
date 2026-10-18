local PAT = "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"
local REPO = "https://" .. PAT .. "@raw.githubusercontent.com/Bees-D/Chudware-PhantomForces/master/"

local function load(path)
	local url = REPO .. path
	local ok, content = pcall(function() return game:HttpGet(url) end)
	if not ok then error("Cannot fetch " .. path .. ": " .. tostring(content)) end
	if not content or content == "" then error("Empty response for " .. path) end
	local fn, err = loadstring(content, "@" .. path)
	if not fn then error("Parse error in " .. path .. ": " .. tostring(err)) end
	return fn()
end

local Services = load("core/services.luau")
local Util     = load("core/util.luau")
local Config   = load("core/config.luau")
local Runtime  = load("core/runtime.luau")
local Notify   = load("ui/notify.luau")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

Notify.setRayfield(Rayfield)

local Window = Rayfield:CreateWindow({
	Name = "Chudware - Phantom Forces",
	Icon = 0,
	LoadingTitle = "Chudware PF",
	LoadingSubtitle = "Loading...",
	Theme = "Amethyst",
	DisableRayfieldPrompts = true,
	DisableBuildWarnings = true,
	ConfigurationSaving = { Enabled = true, FolderName = "ChudwarePF", FileName = "config" },
	KeySystem = false,
})

local ctx = {
	services = Services,
	util     = Util,
	config   = Config,
	runtime  = Runtime,
	notify   = Notify,
}

local FEATURES = {
	{ tab = "Combat",   files = { "features/combat/aimbot.luau", "features/combat/silent_aim.luau", "features/combat/triggerbot.luau", "features/combat/no_recoil.luau" } },
	{ tab = "Visuals",  files = { "features/visuals/player_esp.luau", "features/visuals/skeleton_esp.luau", "features/visuals/chams.luau", "features/visuals/crosshair.luau", "features/visuals/fullbright.luau" } },
	{ tab = "Movement", files = { "features/movement/fly_noclip.luau", "features/movement/speed.luau" } },
	{ tab = "Misc",     files = { "features/visuals/freecam.luau" } },
}

local loaded = 0
local failed = 0

for _, group in ipairs(FEATURES) do
	local tab = Window:CreateTab(group.tab, nil)
	for _, file in ipairs(group.files) do
		local ok2, feature = pcall(load, file)
		if ok2 and feature and feature.init then
			local ok3, err3 = pcall(feature.init, tab, ctx)
			if ok3 then
				loaded = loaded + 1
			else
				failed = failed + 1
				warn("[ChudwarePF] init failed: " .. file .. " - " .. tostring(err3))
			end
		else
			failed = failed + 1
			warn("[ChudwarePF] load failed: " .. file .. " - " .. tostring(feature))
		end
	end
end

Notify.ok("Loaded " .. loaded .. " features" .. (failed > 0 and (" (" .. failed .. " failed)") or ""))
