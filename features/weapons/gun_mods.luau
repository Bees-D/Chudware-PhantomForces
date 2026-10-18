local Feature = {}
Feature.name = "Gun Mods"

-- All of these mutate the live WeaponDatabase tables (require is cached). Re-equip the weapon
-- in-game to apply; use "Apply" after changing loadout. Verified writable via REPL.
function Feature.init(tab, ctx)
	local U, N = ctx.util, ctx.notify

	tab:CreateSection("Gun Mods (apply, then re-equip)")

	local mods = {
		{ name = "No Recoil", fn = function(w) return U.zeroSubtable(w, "recoil", 0) end },
		{ name = "No Spread", fn = function(w)
			local n = U.patchTableKey(w, "hipfirespread", 0)
			n = n + U.patchTableKey(w, "hipfirestability", 1)
			return n end },
		{ name = "No Sway", fn = function(w)
			local n = 0
			for _, k in ipairs({"walkswayamphipmult","walkswayampaimmult","walkswayrothipmult","walkswayrotaimmult","idleswayamphipmult","idleswayampaimmult"}) do
				n = n + U.patchTableKey(w, k, 0)
			end
			return n end },
		{ name = "Rapid Fire", fn = function(w) return U.patchTableKey(w, "firerate", 2400) end },
		{ name = "Infinite Ammo (huge mag)", fn = function(w)
			local n = U.patchTableKey(w, "magsize", 9999)
			n = n + U.patchTableKey(w, "sparerounds", 9999)
			return n end },
		{ name = "No Overheat", fn = function(w)
			local n = U.patchTableKey(w, "heatfireratekick", 0)
			n = n + U.patchTableKey(w, "heatfireratecap", 99999)
			return n end },
		{ name = "Instant ADS", fn = function(w)
			local n = U.patchTableKey(w, "aimspeed", 40)
			n = n + U.patchTableKey(w, "unaimspeed", 40)
			return n end },
		{ name = "Instant Equip", fn = function(w)
			local n = U.patchTableKey(w, "equipspeed", 40)
			n = n + U.patchTableKey(w, "unequipspeed", 40)
			return n end },
		{ name = "Hitscan (no drop)", fn = function(w) return U.patchTableKey(w, "bulletspeed", 1e6) end },
		{ name = "Wallbang (max penetration)", fn = function(w) return U.patchTableKey(w, "penetrationdepth", 100) end },
		{ name = "Max Damage", fn = function(w)
			local n = U.patchTableKey(w, "damage", 1000)
			n = n + U.patchTableKey(w, "multhead", 10)
			n = n + U.patchTableKey(w, "multtorso", 10)
			return n end },
		{ name = "Speed (walk+sprint)", fn = function(w)
			local n = U.patchTableKey(w, "walkspeed", 40)
			n = n + U.patchTableKey(w, "sprintspeed", 60)
			return n end },
		{ name = "Unlock All Weapons", fn = function(w) return U.patchTableKey(w, "unlockrank", 0) end },
	}

	for _, m in ipairs(mods) do
		tab:CreateButton({ Name = m.name, Callback = function()
			local guns, patched = 0, 0
			U.forEachWeapon(function(w) guns = guns + 1; patched = patched + (m.fn(w) or 0) end)
			if N then N.ok(m.name .. ": " .. patched .. " fields on " .. guns .. " guns") end
		end })
	end

	tab:CreateButton({ Name = "APPLY ALL", Callback = function()
		local guns, total = 0, 0
		U.forEachWeapon(function(w)
			guns = guns + 1
			for _, m in ipairs(mods) do total = total + (m.fn(w) or 0) end
		end)
		if N then N.ok("Applied all: " .. total .. " fields on " .. guns .. " guns") end
	end })
end

function Feature.toggle(state) end
return Feature
