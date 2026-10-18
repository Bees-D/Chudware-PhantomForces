local Feature = {}
Feature.name = "Skeleton ESP"

local enabled = false
local maxDist = 800
local lineColor = Color3.fromRGB(255, 255, 255)
local lineThickness = 1.5
local bones = {}
local UPDATE_INTERVAL = 1/20
local lastUpdate = 0

local JOINTS_R6 = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"},
}

local JOINTS_R15 = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Skeleton ESP")
	tab:CreateToggle({ Name = "Skeleton ESP", CurrentValue = false, Flag = "pf_skel_esp", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "Max Distance", Range = {50, 2000}, Increment = 50, CurrentValue = 800, Flag = "pf_skel_dist", Callback = function(v) maxDist = v end })
	tab:CreateColorPicker({ Name = "Bone Color", Color = lineColor, Flag = "pf_skel_color", Callback = function(v) lineColor = v end })

	local function getJoints(char)
		if char:FindFirstChild("UpperTorso") then return JOINTS_R15 end
		return JOINTS_R6
	end

	local function ensureBones(key, count)
		if not bones[key] then bones[key] = {} end
		while #bones[key] < count do
			table.insert(bones[key], U.newDrawing("Line", { Thickness = lineThickness, Color = lineColor }))
		end
		return bones[key]
	end

	R.onRender("pf_skeleton_esp", function()
		if not enabled then
			for _, set in pairs(bones) do for _, l in ipairs(set) do U.hideDrawing(l) end end
			return
		end

		local now = tick()
		if now - lastUpdate < UPDATE_INTERVAL then return end
		lastUpdate = now

		local hrp = S.HRP()
		if not hrp then return end

		local seen = {}
		for _, player in ipairs(S.Players:GetPlayers()) do
			if U.isEnemy(player) then
				local char = player.Character
				local phrp = char and char:FindFirstChild("HumanoidRootPart")
				if phrp and (phrp.Position - hrp.Position).Magnitude <= maxDist then
					local joints = getJoints(char)
					local boneSet = ensureBones(player.Name, #joints)
					seen[player.Name] = true
					for i, joint in ipairs(joints) do
						local pA = char:FindFirstChild(joint[1])
						local pB = char:FindFirstChild(joint[2])
						if pA and pA:IsA("BasePart") and pB and pB:IsA("BasePart") then
							local vA, onA = U.worldToViewport(pA.Position)
							local vB, onB = U.worldToViewport(pB.Position)
							if onA and onB and boneSet[i] then
								boneSet[i].From = Vector2.new(vA.X, vA.Y)
								boneSet[i].To = Vector2.new(vB.X, vB.Y)
								boneSet[i].Color = lineColor
								boneSet[i].Visible = true
							elseif boneSet[i] then boneSet[i].Visible = false end
						elseif boneSet[i] then boneSet[i].Visible = false end
					end
				else
					if bones[player.Name] then
						for _, l in ipairs(bones[player.Name]) do U.hideDrawing(l) end
					end
				end
			end
		end

		for key, set in pairs(bones) do
			if not seen[key] then for _, l in ipairs(set) do U.hideDrawing(l) end end
		end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
