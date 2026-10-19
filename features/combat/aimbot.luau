local Feature = {}
Feature.name = "Aimbot"

local enabled = false
local fov = 150
local smooth = 6
local headOffset = 2.5
local showFov = true
local teamCheck = true
local wallCheck = false
local fovCircle

function Feature.init(tab, ctx)
	local S, U, R, T = ctx.services, ctx.util, ctx.runtime, ctx.tracker

	tab:CreateSection("Aimbot")
	tab:CreateToggle({ Name = "Aimbot (hold RMB/ADS)", CurrentValue = false, Flag = "pf_aim", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "FOV", Range = {30, 600}, Increment = 10, CurrentValue = 150, Flag = "pf_aim_fov", Callback = function(v) fov = v end })
	tab:CreateSlider({ Name = "Smoothing", Range = {1, 20}, Increment = 1, CurrentValue = 6, Flag = "pf_aim_smooth", Callback = function(v) smooth = v end })
	tab:CreateSlider({ Name = "Head offset (studs)", Range = {0, 5}, Increment = 0.1, CurrentValue = 2.5, Flag = "pf_aim_head", Callback = function(v) headOffset = v end })
	tab:CreateToggle({ Name = "Team check", CurrentValue = true, Flag = "pf_aim_team", Callback = function(v) teamCheck = v end })
	tab:CreateToggle({ Name = "Wall check (visible only)", CurrentValue = false, Flag = "pf_aim_wall", Callback = function(v) wallCheck = v end })
	tab:CreateToggle({ Name = "Show FOV circle", CurrentValue = true, Flag = "pf_aim_showfov", Callback = function(v) showFov = v end })

	fovCircle = U.newDrawing("Circle", { Thickness = 1, Filled = false, Color = Color3.fromRGB(255,255,255), Transparency = 0.5, NumSides = 48 })

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local function visible(cam, aimPos)
		local origin = cam.CFrame.Position
		local dir = aimPos - origin
		local dist = dir.Magnitude
		if dist < 1 then return true end
		-- ignore the Roots folder (invisible markers) + rendered player bodies so only MAP blocks LoS
		local ignore = {}
		local r = S.Roots(); if r then ignore[#ignore+1] = r end
		local b = S.Bodies(); if b then ignore[#ignore+1] = b end
		rayParams.FilterDescendantsInstances = ignore
		local hit = workspace:Raycast(origin, dir, rayParams)
		if not hit then return true end
		-- blocked if geometry sits clearly before the target
		return (hit.Position - origin).Magnitude >= dist - 4
	end

	local function pickTarget(cam)
		local vpc = cam.ViewportSize / 2
		local best, bestD = nil, fov
		for _, tg in ipairs(T.targets) do
			if not (teamCheck and tg.isEnemy == false) then
				local aimPos = tg.pos + Vector3.new(0, headOffset, 0)
				local v, on = cam:WorldToViewportPoint(aimPos)
				if on then
					local sd = (Vector2.new(v.X, v.Y) - vpc).Magnitude
					if sd < bestD and (not wallCheck or visible(cam, aimPos)) then
						bestD = sd; best = aimPos
					end
				end
			end
		end
		return best
	end

	R.onRender("pf_aim", function()
		local cam = S.Camera()
		if not cam then return end
		if fovCircle then
			fovCircle.Position = cam.ViewportSize / 2
			fovCircle.Radius = fov
			fovCircle.Visible = enabled and showFov
		end
		if not enabled then return end
		if not S.UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
		local aimPos = pickTarget(cam)
		if not aimPos then return end
		local goal = CFrame.lookAt(cam.CFrame.Position, aimPos)
		cam.CFrame = cam.CFrame:Lerp(goal, 1 / smooth)
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
