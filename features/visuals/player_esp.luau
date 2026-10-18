local Feature = {}
Feature.name = "Player ESP"

local enabled = false
local showBox, showName, showDist, showTracer, showHealth = true, true, true, false, true
local teamCheck = true
local pool = {}

local COL_ENEMY = Color3.fromRGB(255, 60, 60)
local COL_TEAM = Color3.fromRGB(60, 200, 90)
local COL_UNK = Color3.fromRGB(230, 220, 90)

function Feature.init(tab, ctx)
	local S, U, R, T = ctx.services, ctx.util, ctx.runtime, ctx.tracker

	tab:CreateSection("Player ESP")
	tab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "pf_esp", Callback = function(v) enabled = v end })
	tab:CreateToggle({ Name = "Box", CurrentValue = true, Flag = "pf_esp_box", Callback = function(v) showBox = v end })
	tab:CreateToggle({ Name = "Name", CurrentValue = true, Flag = "pf_esp_name", Callback = function(v) showName = v end })
	tab:CreateToggle({ Name = "Distance", CurrentValue = true, Flag = "pf_esp_dist", Callback = function(v) showDist = v end })
	tab:CreateToggle({ Name = "Health bar", CurrentValue = true, Flag = "pf_esp_hp", Callback = function(v) showHealth = v end })
	tab:CreateToggle({ Name = "Tracers", CurrentValue = false, Flag = "pf_esp_tracer", Callback = function(v) showTracer = v end })
	tab:CreateToggle({ Name = "Team check (hide allies)", CurrentValue = true, Flag = "pf_esp_team", Callback = function(v) teamCheck = v end })

	local function slot(i)
		if pool[i] then return pool[i] end
		local s = {
			box = U.newDrawing("Square", { Thickness = 1, Filled = false, Color = COL_ENEMY, Transparency = 1 }),
			name = U.newDrawing("Text", { Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1) }),
			dist = U.newDrawing("Text", { Size = 12, Center = true, Outline = true, Color = Color3.new(1,1,1) }),
			tracer = U.newDrawing("Line", { Thickness = 1, Color = COL_ENEMY, Transparency = 1 }),
			hpbg = U.newDrawing("Square", { Thickness = 1, Filled = true, Color = Color3.new(0,0,0), Transparency = 0.6 }),
			hp = U.newDrawing("Square", { Thickness = 1, Filled = true, Color = Color3.fromRGB(60,220,90), Transparency = 1 }),
		}
		pool[i] = s
		return s
	end

	local function hideAll()
		for _, s in pairs(pool) do
			for _, d in pairs(s) do U.hideDrawing(d) end
		end
	end

	R.onRender("pf_esp", function()
		if not enabled then hideAll() return end
		local cam = S.Camera()
		if not cam then return end
		local vp = cam.ViewportSize
		local targets = T.targets
		local used = 0
		for _, tg in ipairs(targets) do
			local enemy = tg.isEnemy
			-- team check: skip known-allies; show enemies + unknowns
			if teamCheck and enemy == false then
				-- ally, skip
			else
				local headPos = tg.pos + Vector3.new(0, 2.5, 0)
				local footPos = tg.pos + Vector3.new(0, -2.5, 0)
				local hv, onH = cam:WorldToViewportPoint(headPos)
				local fv, onF = cam:WorldToViewportPoint(footPos)
				if onH or onF then
					used = used + 1
					local s = slot(used)
					local col = (enemy == true) and COL_ENEMY or (enemy == false and COL_TEAM or COL_UNK)
					local h = math.abs(hv.Y - fv.Y)
					local w = h * 0.5
					local cx = (hv.X + fv.X) / 2
					local top = math.min(hv.Y, fv.Y)
					-- box
					if showBox then
						s.box.Color = col; s.box.Size = Vector2.new(w, h)
						s.box.Position = Vector2.new(cx - w/2, top); s.box.Visible = true
					else U.hideDrawing(s.box) end
					-- name
					if showName and tg.name then
						s.name.Text = tg.name; s.name.Color = col
						s.name.Position = Vector2.new(cx, top - 15); s.name.Visible = true
					else U.hideDrawing(s.name) end
					-- distance
					if showDist then
						local d = U.distanceFromCam(tg.pos)
						s.dist.Text = string.format("%dm", math.floor(d))
						s.dist.Position = Vector2.new(cx, top + h + 2); s.dist.Visible = true
					else U.hideDrawing(s.dist) end
					-- tracer
					if showTracer then
						s.tracer.Color = col
						s.tracer.From = Vector2.new(vp.X/2, vp.Y)
						s.tracer.To = Vector2.new(cx, top + h); s.tracer.Visible = true
					else U.hideDrawing(s.tracer) end
					-- health bar (left of box)
					if showHealth and tg.hpFrac then
						local bx = cx - w/2 - 5
						s.hpbg.Size = Vector2.new(3, h); s.hpbg.Position = Vector2.new(bx, top); s.hpbg.Visible = true
						local hh = h * math.clamp(tg.hpFrac, 0, 1)
						s.hp.Size = Vector2.new(3, hh); s.hp.Position = Vector2.new(bx, top + (h - hh)); s.hp.Visible = true
					else U.hideDrawing(s.hpbg); U.hideDrawing(s.hp) end
				end
			end
		end
		-- hide unused slots
		for i = used + 1, #pool do
			for _, d in pairs(pool[i]) do U.hideDrawing(d) end
		end
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
