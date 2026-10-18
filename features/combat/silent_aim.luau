local Feature = {}
Feature.name = "Silent Aim"

local enabled = false
local targetBone = "Head"

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Silent Aim")
	tab:CreateToggle({ Name = "Silent Aim", CurrentValue = false, Flag = "pf_silentaim", Callback = function(v) enabled = v end })
	tab:CreateDropdown({ Name = "Target Bone", Options = {"Head", "Torso"}, CurrentOption = {"Head"}, Flag = "pf_sa_bone", Callback = function(v) if type(v) == "table" then v = v[1] end; targetBone = v end })

	if not U.hasGetrawmetatable then
		tab:CreateParagraph({ Title = "UNAVAILABLE", Content = "Silent Aim requires getrawmetatable + setreadonly (not available in this executor)." })
		return
	end

	local function getNearestEnemy()
		local cam = S.Camera()
		if not cam then return nil end
		local closest = nil
		local closestDist = math.huge

		for _, player in ipairs(S.Players:GetPlayers()) do
			if U.isEnemy(player) then
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local bone = char and char:FindFirstChild(targetBone)
				if bone and hum and hum.Health > 0 then
					local dist = U.distanceFromLocal(bone.Position)
					if dist < closestDist then
						closestDist = dist
						closest = { part = bone, position = bone.Position }
					end
				end
			end
		end
		return closest
	end

	local mt = getrawmetatable(game)
	local oldNamecall = mt.__namecall
	local restoreReadonly = false

	pcall(function()
		if setreadonly then
			setreadonly(mt, false)
			restoreReadonly = true
		elseif make_writeable then
			make_writeable(mt)
		end
	end)

	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if enabled and method == "FireServer" and self:IsA("RemoteEvent") then
			local args = {...}
			if #args > 0 and type(args[1]) == "table" then
				local target = getNearestEnemy()
				if target then
					for _, entry in ipairs(args) do
						if type(entry) == "table" then
							if entry.p or entry.Part or entry.Position then
								entry.p = target.part
								entry.Part = target.part
								entry.Position = target.position
							end
						end
					end
				end
			end
			return oldNamecall(self, ...)
		end
		return oldNamecall(self, ...)
	end)

	if restoreReadonly then
		pcall(function() setreadonly(mt, true) end)
	end
end

function Feature.toggle(state) enabled = state end

return Feature
