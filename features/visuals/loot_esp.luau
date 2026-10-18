local Feature = {}
Feature.name = "Drop ESP"

-- workspace.Ignore.GunDrop + DeadBody (verified live).
local enabled = false
local pool = {}

function Feature.init(tab, ctx)
	local S, U, R = ctx.services, ctx.util, ctx.runtime
	tab:CreateSection("Gun/Drop ESP")
	tab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "pf_drop", Callback = function(v) enabled = v end })

	local function txt(i)
		if pool[i] then return pool[i] end
		pool[i] = U.newDrawing("Text", { Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(255,200,60) })
		return pool[i]
	end

	R.onRender("pf_drop", function()
		if not enabled then for _, d in pairs(pool) do U.hideDrawing(d) end return end
		local cam = S.Camera(); if not cam then return end
		local ignore = workspace:FindFirstChild("Ignore")
		if not ignore then return end
		local used = 0
		for _, folderName in ipairs({ "GunDrop", "DeadBody" }) do
			local f = ignore:FindFirstChild(folderName)
			if f then
				for _, drop in ipairs(f:GetChildren()) do
					local part = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart")
					if part then
						local v, on = cam:WorldToViewportPoint(part.Position)
						if on then
							used = used + 1
							local t = txt(used)
							t.Text = (folderName == "GunDrop") and "[gun]" or "[body]"
							t.Position = Vector2.new(v.X, v.Y); t.Visible = true
						end
					end
				end
			end
		end
		for i = used + 1, #pool do U.hideDrawing(pool[i]) end
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
