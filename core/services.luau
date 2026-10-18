local Services = {}

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.UIS = game:GetService("UserInputService")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Lighting = game:GetService("Lighting")
Services.Workspace = workspace
Services.TweenService = game:GetService("TweenService")
Services.LocalPlayer = Services.Players.LocalPlayer

function Services.Character()
	return Services.LocalPlayer and Services.LocalPlayer.Character
end

function Services.HRP()
	local char = Services.Character()
	return char and char:FindFirstChild("HumanoidRootPart")
end

function Services.Humanoid()
	local char = Services.Character()
	return char and char:FindFirstChildOfClass("Humanoid")
end

function Services.Camera()
	return workspace.CurrentCamera
end

function Services.Mouse()
	return Services.LocalPlayer and Services.LocalPlayer:GetMouse()
end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.services = Services
return Services
