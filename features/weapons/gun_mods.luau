local Feature = {}
Feature.name = "Gun Mods"

-- Toggles mutate the live WeaponDatabase (require cached) and restore originals on OFF.
-- Re-equip the weapon in-game to apply a freshly-toggled mod.
function Feature.init(tab, ctx)
	local U, N = ctx.util, ctx.notify

	tab:CreateSection("Gun Mods (re-equip to apply)")

	local mods = {
		{ id = "norecoil", name = "No Recoil", apply = function(w, log) return U.zeroSubtableLogged(w, "recoil", 0, log) end },
		{ id = "nospread", name = "No Spread", apply = function(w, log)
			local n = U.patchKeyLogged(w, "hipfirespread", 0, log)
			return n + U.patchKeyLogged(w, "hipfirestability", 1, log) end },
		{ id = "nosway", name = "No Sway", apply = function(w, log)
			local n = 0
			for _, k in ipairs({"walkswayamphipmult","walkswayampaimmult","walkswayrothipmult","walkswayrotaimmult","idleswayamphipmult","idleswayampaimmult"}) do
				n = n + U.patchKeyLogged(w, k, 0, log) end
			return n end },
		{ id = "rapid", name = "Rapid Fire", apply = function(w, log) return U.patchKeyLogged(w, "firerate", 2400, log) end },
		{ id = "ammo", name = "Infinite Ammo", apply = function(w, log)
			local n = U.patchKeyLogged(w, "magsize", 9999, log)
			return n + U.patchKeyLogged(w, "sparerounds", 9999, log) end },
		{ id = "noheat", name = "No Overheat", apply = function(w, log)
			local n = U.patchKeyLogged(w, "heatfireratekick", 0, log)
			return n + U.patchKeyLogged(w, "heatfireratecap", 99999, log) end },
		{ id = "ads", name = "Instant ADS", apply = function(w, log)
			local n = U.patchKeyLogged(w, "aimspeed", 40, log)
			return n + U.patchKeyLogged(w, "unaimspeed", 40, log) end },
		{ id = "equip", name = "Instant Equip", apply = function(w, log)
			local n = U.patchKeyLogged(w, "equipspeed", 40, log)
			return n + U.patchKeyLogged(w, "unequipspeed", 40, log) end },
		{ id = "hitscan", name = "Hitscan (no drop)", apply = function(w, log) return U.patchKeyLogged(w, "bulletspeed", 1e6, log) end },
		{ id = "wallbang", name = "Wallbang", apply = function(w, log) return U.patchKeyLogged(w, "penetrationdepth", 100, log) end },
		{ id = "dmg", name = "Max Damage", apply = function(w, log)
			local n = U.patchKeyLogged(w, "damage", 1000, log)
			n = n + U.patchKeyLogged(w, "multhead", 10, log)
			return n + U.patchKeyLogged(w, "multtorso", 10, log) end },
		{ id = "speed", name = "Speed (walk+sprint)", apply = function(w, log)
			local n = U.patchKeyLogged(w, "walkspeed", 40, log)
			return n + U.patchKeyLogged(w, "sprintspeed", 60, log) end },
		{ id = "unlockguns", name = "Unlock All Weapons", apply = function(w, log) return U.patchKeyLogged(w, "unlockrank", 0, log) end },
	}

	for _, m in ipairs(mods) do
		m.log = {}
		tab:CreateToggle({ Name = m.name, CurrentValue = false, Flag = "pf_gm_" .. m.id, Callback = function(on)
			if on then
				local guns, patched = 0, 0
				U.forEachWeapon(function(w) guns = guns + 1; patched = patched + (m.apply(w, m.log) or 0) end)
				if N then N.ok(m.name .. " ON: " .. patched .. " fields") end
			else
				U.restoreLog(m.log)
				if N then N.ok(m.name .. " OFF") end
			end
		end })
	end
end

function Feature.toggle(state) end
return Feature
