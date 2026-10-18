# Chudware Phantom Forces — Full Feature Plan (grounded + live-verified)

All mechanics verified via REPL bridge. See LIVE_MAP.md for raw evidence.
Executor caps (Xeno): hookfunction, newcclosure, setreadonly, checkcaller, getconnections,
getnilinstances, Drawing, require, buffer, request — YES.
getrawmetatable, getnamecallmethod, hookmetamethod, firesignal, getgc(tables), getreg — NO.

## ESP / VISUALS (roots + nametag + tracking)
- **Player ESP (through-wall)**: box + name + distance + tracer on every `workspace.Roots` part.
  WorldToViewportPoint for projection. Identity/team via tracker (below). [VERIFIED]
- **Team coloring**: visible body `NameTagGui.PlayerTag.Text` -> player -> TeamColor; match to
  nearest root; persist via frame-tracking (1.25 move vs 46.56 spacing = no swaps). [VERIFIED]
- **Health ESP**: visible body nametag `Percent` frame `Size.X.Scale` (0..1) = HP fraction. [verify@build, visible-only]
- **Chams**: Highlight on visible body Models (workspace.Players.<f>.Model). AlwaysOnTop. [visible-only]
- **Crosshair**: Drawing cross at viewport center. [VERIFIED Drawing works]
- **Fullbright**: Lighting override (Brightness/Ambient/ClockTime/FogEnd). [standard]
- **Loot/Drop ESP** (NEW): `workspace.Ignore.GunDrop` + `DeadBody` -> boxes/names. [found live]

## COMBAT
- **Aimbot (camera)**: lerp CurrentCamera to nearest-to-crosshair enemy root (+ (0,2.5,0) head
  offset). FOV circle. Team filter via tracker. [VERIFIED roots+cam]
- **Triggerbot**: raycast from camera; if hit a visible enemy body -> VirtualInputManager click. [standard]
- **Silent aim**: UNSUPPORTED (no getrawmetatable/namecall; fire packet is a buffer). Mark in UI.

## GUN MODS — data patch via require() on WeaponDatabase (ALL writable, PROVEN)
Find DB: game:GetChildren() -> FindFirstChild("Content").ProductionContent.WeaponDatabase.
require each weapon ModuleScript (cached=live), patch fields. Re-equip to apply.
- **No recoil**: `recoil` table (hip/aimTranslation/Rotation/CameraBody/CameraHead) -> 0.
- **No spread**: `hipfirespread` -> 0, `hipfirestability` -> 1.
- **No sway**: walksway*/idlesway* mults -> 0, `simpleswayparameters` damp.
- **Rapid fire**: `firerate` -> high (e.g. 2000).
- **Full auto**: `firemodes` -> include auto.
- **Infinite/huge ammo**: `magsize` + `sparerounds` -> large.
- **No overheat**: `heatfireratekick` -> 0 / `heatfireratecap` -> huge.
- **Instant ADS**: `aimspeed`/`unaimspeed` -> high.
- **Instant equip**: `equipspeed`/`equiptime`/`unequiptime` -> fast.
- **Hitscan / no drop**: `bulletspeed` -> 1e6. [VERIFIED writable]
- **Wallbang**: `penetrationdepth` -> huge.
- **Max damage / one-shot**: `damageGraph[*].damage` -> high; `multhead`/`multtorso` -> high.
- **Speed (NEW, now viable)**: `walkspeed`/`sprintspeed`/`aimwalkspeedmult` -> high
  (PF has no Humanoid; movement speed is a per-weapon data field).
- **Tighter crosshair**: `crosssize` -> small.
- **No flinch**: `suppression` -> 0.
- **Unlock all weapons**: `unlockrank` -> 0.

## UNLOCKS — data patch (PROVEN)
- **Unlock all attachments**: AttachmentDatabase `.unlockkills` -> 0. [VERIFIED read115->set0]
- **Unlock all camos**: CamoDatabase unlock field (nested per-camo; confirm field @build).

## MISC / LOCAL
- **Freecam**: CurrentCamera Scriptable + WASD. [standard]
- **FOV changer**: CurrentCamera.FieldOfView. [standard, NEW]

## UNSUPPORTED (engine deleted / sandbox)
- Silent aim (no namecall hook + buffer fire).
- Fly / noclip: no Humanoid/HRP to drive; movement engine-controlled. Investigate camera/root
  write at build; likely UNSUPPORTED or freecam-only.

## Architecture notes
- init.luau MUST call Runtime.start() (prior bug: loop features never ran).
- services: no Character/Humanoid; use GetService; Camera=workspace.CurrentCamera.
- util.isEnemy = p.TeamColor ~= LocalPlayer.TeamColor.
- Tracker module: maps root->{player,team}, updates each frame from visible bodies, persists by
  nearest-neighbor. Central to ESP + aimbot.
