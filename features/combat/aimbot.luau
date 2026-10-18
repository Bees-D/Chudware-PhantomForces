local Feature = {}
Feature.name = "Aimbot"

local enabled = false
local fov = 200
local smoothing = 5
local targetBone = "Head"
local showFOV = true
local fovCircle = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Aimbot")
	tab:CreateToggle({ Name = "Aimbot (Hold C)", CurrentValue = false, Flag = "pf_aimbot", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "FOV", Range = {50, 800}, Increment = 10, CurrentValue = 200, Flag = "pf_aim_fov", Callback = function(v) fov = v end })
	tab:CreateSlider({ Name = "Smoothing", Range = {1, 20}, Increment = 1, CurrentValue = 5, Flag = "pf_aim_smooth", Callback = function(v) smoothing = v end })
	tab:CreateDropdown({ Name = "Target Bone", Options = {"Head", "Torso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Flag = "pf_aim_bone", Callback = function(v) if type(v) == "table" then v = v[1] end; targetBone = v end })
	tab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = true, Flag = "pf_aim_showfov", Callback = function(v) showFOV = v end })

	fovCircle = U.newDrawing("Circle", { Thickness = 1, Filled = false, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5 })

	local function getTarget()
		local cam = S.Camera()
		local hrp = S.HRP()
		if not cam or not hrp then return nil end

		local vpCenter = cam.ViewportSize / 2
		local closest = nil
		local closestDist = fov

		for _, player in ipairs(S.Players:GetPlayers()) do
			if U.isEnemy(player) then
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local bone = char and char:FindFirstChild(targetBone)
				if bone and hum and hum.Health > 0 then
					local v, onScreen = U.worldToViewport(bone.Position)
					if onScreen then
						local screenDist = (Vector2.new(v.X, v.Y) - vpCenter).Magnitude
						if screenDist < closestDist then
							closestDist = screenDist
							closest = bone
						end
					end
				end
			end
		end
		return closest
	end

	R.onRender("pf_aimbot", function(dt)
		local cam = S.Camera()
		if not cam then return end

		if fovCircle then
			fovCircle.Position = cam.ViewportSize / 2
			fovCircle.Radius = fov
			fovCircle.Visible = enabled and showFOV
		end

		if not enabled then return end
		if not S.UIS:IsKeyDown(Enum.KeyCode.C) then return end

		local target = getTarget()
		if not target then return end

		local targetCF = CFrame.lookAt(cam.CFrame.Position, target.Position)
		cam.CFrame = cam.CFrame:Lerp(targetCF, 1 / smoothing)
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
