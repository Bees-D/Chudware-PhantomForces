-- Phantom Forces is sandboxed: game.Players is blocked, use GetService. No Humanoid/Character.
local Services = {}

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.UIS = game:GetService("UserInputService")
Services.Lighting = game:GetService("Lighting")
Services.Workspace = workspace
Services.LocalPlayer = Services.Players.LocalPlayer
Services.VIM = (function() local ok, v = pcall(function() return game:GetService("VirtualInputManager") end); return ok and v or nil end)()

function Services.Camera() return workspace.CurrentCamera end
function Services.Mouse() return Services.LocalPlayer and Services.LocalPlayer:GetMouse() end

-- workspace.Roots = per-player physics roots (through-wall positions)
function Services.Roots()
	local r = workspace:FindFirstChild("Roots")
	return r
end

-- workspace.Players = rendered body folders (visible players only)
function Services.Bodies()
	return workspace:FindFirstChild("Players")
end

function Services.LocalTeamColor()
	local lp = Services.LocalPlayer
	return lp and lp.TeamColor
end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.services = Services
return Services
