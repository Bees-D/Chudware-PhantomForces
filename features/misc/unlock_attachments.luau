local Feature = {}
Feature.name = "Unlock All Attachments"

local unlocked = false
local statusLabel = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util

	tab:CreateSection("Attachments")

	local function updateStatus(text)
		if statusLabel then
			pcall(function() statusLabel:Set({ Title = "Status", Content = text }) end)
		end
	end

	local function scanAndUnlock()
		if not getgc then
			updateStatus("FAILED: executor lacks getgc()")
			return 0
		end

		local patched = 0
		local gc = getgc(true)

		for _, obj in ipairs(gc) do
			if type(obj) == "table" then
				local ok, _ = pcall(function()
					-- Pattern 1: tables with numeric kill-requirement keys per attachment slot
					-- PF weapon data modules store {Name=..., KillRequirement=N} or {Kills=N}
					if rawget(obj, "KillRequirement") ~= nil then
						rawset(obj, "KillRequirement", 0)
						patched = patched + 1
					end
					if rawget(obj, "RequiredKills") ~= nil then
						rawset(obj, "RequiredKills", 0)
						patched = patched + 1
					end
					if rawget(obj, "killsRequired") ~= nil then
						rawset(obj, "killsRequired", 0)
						patched = patched + 1
					end
					if rawget(obj, "Requirement") ~= nil and type(rawget(obj, "Requirement")) == "number" then
						rawset(obj, "Requirement", 0)
						patched = patched + 1
					end
					if rawget(obj, "UnlockRequirement") ~= nil then
						rawset(obj, "UnlockRequirement", 0)
						patched = patched + 1
					end
					if rawget(obj, "UnlockKills") ~= nil then
						rawset(obj, "UnlockKills", 0)
						patched = patched + 1
					end
				end)
			end
		end

		-- Pattern 2: scan for upvalue tables in functions that contain attachment data
		for _, obj in ipairs(gc) do
			if type(obj) == "function" then
				pcall(function()
					local info = debug.getinfo(obj)
					if not info then return end
					for i = 1, 50 do
						local name, val = debug.getupvalue(obj, i)
						if not name then break end
						if type(val) == "table" then
							pcall(function()
								for k, v in pairs(val) do
									if type(v) == "table" then
										if rawget(v, "KillRequirement") ~= nil then
											rawset(v, "KillRequirement", 0)
											patched = patched + 1
										end
										if rawget(v, "RequiredKills") ~= nil then
											rawset(v, "RequiredKills", 0)
											patched = patched + 1
										end
										if rawget(v, "killsRequired") ~= nil then
											rawset(v, "killsRequired", 0)
											patched = patched + 1
										end
										if rawget(v, "Requirement") ~= nil and type(rawget(v, "Requirement")) == "number" then
											rawset(v, "Requirement", 0)
											patched = patched + 1
										end
										if rawget(v, "UnlockRequirement") ~= nil then
											rawset(v, "UnlockRequirement", 0)
											patched = patched + 1
										end
										if rawget(v, "UnlockKills") ~= nil then
											rawset(v, "UnlockKills", 0)
											patched = patched + 1
										end
									end
								end
							end)
						end
					end
				end)
			end
		end

		return patched
	end

	local function boostWeaponKills()
		if not getgc then return 0 end

		local boosted = 0
		local gc = getgc(true)

		-- Find player data tables that track per-weapon kill counts
		-- PF stores {weaponName = {kills = N, ...}} or similar structures
		for _, obj in ipairs(gc) do
			if type(obj) == "table" then
				pcall(function()
					-- Tables where keys are weapon names and values have a kills field
					for k, v in pairs(obj) do
						if type(k) == "string" and type(v) == "table" then
							if rawget(v, "Kills") ~= nil and type(rawget(v, "Kills")) == "number" then
								rawset(v, "Kills", 999999)
								boosted = boosted + 1
							end
							if rawget(v, "kills") ~= nil and type(rawget(v, "kills")) == "number" then
								rawset(v, "kills", 999999)
								boosted = boosted + 1
							end
						end
					end
				end)
			end
		end

		return boosted
	end

	tab:CreateButton({
		Name = "Unlock All Attachments",
		Callback = function()
			local p1 = scanAndUnlock()
			local p2 = boostWeaponKills()
			local total = p1 + p2
			if total > 0 then
				unlocked = true
				updateStatus("Patched " .. total .. " entries. Open loadout menu to see unlocked attachments.")
				if ctx.notify then ctx.notify.ok("Unlocked attachments (" .. total .. " patched)") end
			else
				updateStatus("No attachment data found in memory. Try opening the loadout menu first, then click again.")
				if ctx.notify then ctx.notify.warn("No data found — open loadout menu first, retry") end
			end
		end,
	})

	tab:CreateButton({
		Name = "Re-scan (after opening loadout menu)",
		Callback = function()
			local p1 = scanAndUnlock()
			local p2 = boostWeaponKills()
			local total = p1 + p2
			updateStatus("Re-scan: " .. total .. " entries patched.")
			if ctx.notify then ctx.notify.ok("Re-scan: " .. total .. " patched") end
		end,
	})

	statusLabel = tab:CreateParagraph({
		Title = "Status",
		Content = "Click 'Unlock All Attachments' to scan and patch. If 0 found, open the loadout menu in-game first (loads the modules into memory), then re-scan."
	})

	tab:CreateParagraph({
		Title = "NOTE",
		Content = "This is LOCAL only — patches the client's view of unlock requirements. The loadout menu will show all attachments available. Server may reject some on spawn."
	})
end

function Feature.toggle(state) end

return Feature
