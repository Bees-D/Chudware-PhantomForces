# Phantom Forces — Live-Verified Map (via REPL bridge)

All facts below were confirmed at runtime through the headless REPL bridge
(`repl_relay.py` + `repl_bridge.luau`), executor = Xeno. This supersedes guesses
in the per-feature research notes.

## Environment / sandbox
- `game` is sandboxed: `.Name` == "Ugc", `game.Players` indexing is BLOCKED.
  **Use `game:GetService("Players")`** — GetService works fine.
- Instance `.Name` values are scrambled per session (Players service = `E[ADkd3\@`,
  LocalPlayer.Name shown as `999Time999_999`). Container names regenerate each session.
- `player.Name` on a Player object IS the real username. `player.DisplayName` real too.

## Players / teams
- `player.Team` is **nil** — PF does NOT use Team objects.
- **Team = `player.TeamColor`** (BrickColor). Observed "Bright orange" vs "Bright blue".
  Enemy test: `p.TeamColor ~= LocalPlayer.TeamColor`.
- `player.Character` is **nil** — PF uses NO standard character / NO Humanoid / NO HumanoidRootPart.
  (workspace has 0 Humanoids, 0 HumanoidRootParts.)

## THROUGH-WALL POSITIONS  ← the key find
- **`workspace.Roots`** holds ~8 transparent 1x1x1 Parts (CanCollide=false, name "Part").
- Their `.Position` **tracks live players through walls** (7/8 moved up to 38 studs over 2s).
- Count ≈ players with an active body (subset of roster; dead/unspawned excluded).
- Parts are ANONYMOUS: no attributes, no children, no tags, no team color, no player link.
  → ESP can draw all roots; root→player/team mapping is NOT directly available.
- `WorldToViewportPoint(root.Position)` works for screen projection + aimbot.

## Rendered bodies (visible only)
- `workspace.Players.<obf-id>` = per-player folders (e.g. "DtylTW"). **Empty unless the
  enemy is visible** (PF occlusion-culls rigs). Folder-id does not map to player cleanly.
- Dead bodies / gun drops: `workspace.Ignore.{DeadBody,GunDrop,Blood,Bullets,Misc}`.

## Replication protocol
- Busy remotes (top-level children of the data container `EADz0?fdJ>n`):
  `RemoteEvent` ~24/s, `UnreliableRemoteEvent` ~37/s.
- URE OnClientEvent payload = a single **binary `buffer`** (variable 122–142 B),
  quantized/compressed — NOT raw float32. No schema available (engine deleted). Do not decode.
- URE handler = C-closure wrapper; `debug.getupvalue` returns nil. `getconnections` works.

## Executor capability (Xeno) — verified
- WORKS: `game:GetService`, `getconnections`, `debug.getupvalue` (singular),
  `getnilinstances` (18k nils), `Drawing.new` (Square/Text confirmed render), `require`,
  `buffer.*`, `request`/`http_request`.
- CRIPPLED/ABSENT: `getgc(true)` returns **Instances only** (no Lua tables/functions);
  `getreg`/`debug.getregistry` ABSENT; `debug.getupvalues` (plural) nil.
- ⇒ Cannot reach engine Lua tables. Engine runs in-memory; PlayerScripts holds only
  default Roblox scripts (RbxCharacterSounds, ControlScript, CameraScript) — PF deleted its own.

## DATA PATCH FEATURES — proven writable live
Databases live at `<obf>.Content.ProductionContent.{WeaponDatabase, AttachmentDatabase}`.
Find container: iterate `game:GetChildren()`, `FindFirstChild("Content").ProductionContent`.
`require(moduleInstance)` returns the cached live table; fields are writable (not read-only).
- **Unlock attachments**: AttachmentData module `.unlockkills` → set 0 (read 115 → set 0 OK).
- **Hitscan / no drop**: weapon module `.bulletspeed` → set huge (e.g. 1e6). (Read 2800.)
- **No recoil**: weapon module `.recoil` table (hip/aim Translation/Rotation subtables) → zero.
- **No spread**: weapon module `.hipfirespread` → 0 (also `hipfirestability` etc.).
Weapon data keys (top-level `t1.*`): firerate, damage/damageGraph, bulletspeed, penetrationdepth,
hipfirespread, suppression, recoil{...}, walksway*, idlesway*, aimspeed, zoom.

## SOLVED: through-wall identity + team (/reverse result)
Decode of the quantized URE buffer is NOT needed. Full solution:
- **Positions (all active players, through walls):** `workspace.Roots` children = per-player
  physics roots (1x1x1, transparent). Count ≈ active players. Positions update live.
- **Identity + team (visible players only):** `workspace.Players.<folderId>` → child `Model`
  → descendant `TextLabel` named **`PlayerTag`** (inside `BillboardGui "NameTagGui"`) = the
  player's **real username**. Map username → `Players:GetPlayers()` → `.TeamColor`
  (Bright orange vs Bright blue). Bodies populate ONLY for visible/near players.
- **Root ↔ player link:** a rendered body's part position matches its root within ~2 studs
  (verified: jumpylolzmaster→root#3 @1.5, laujop2→root#4 @2.0). Nearest-root match = that
  root's player/team.
- **Persist through walls:** once a root is identified via a visible body, keep its identity
  by frame-to-frame nearest-neighbor tracking of the Roots parts (they move continuously).
  Unidentified roots = draw as neutral/unknown.
- Body folderId (e.g. "DtylTW") is stable per player for the session (persists when rig culled)
  but does NOT map to username without the rendered nametag.

Tracking is reliable (verified @30Hz): max per-frame root movement 1.25 studs vs min
inter-root spacing 46.56 studs → nearest-neighbor identity tracking never swaps. Works
down to ~10Hz (≈3.75 studs/frame). Root count stable (11–12 of 23 roster = alive players).

Buffer decode status: ABANDONED (not needed). The URE buffer carries NO userids (records use
internal slot ids), positions are quantized/delta-encoded, structure is 78-byte periodic.
Full decode = many hours + fragile + slots still need a position match to identify a player.
The roots+nametag+tracking route gives the same result reliably. Stable buffer offsets (len 278):
[2,3,4, 8,9,10, 28,29, 47, 105,106,107, 125, 183,184,185, 203, 261,262,263, 277].

Aimbot head offset: root ≈ torso/center (matched body within 2 studs). For headshots through
walls, aim root.Position + Vector3(0, ~2.5, 0); when body visible, use the real head part.

Implementation for ESP/aimbot:
1. Build name→TeamColor table from Players:GetPlayers() (refresh on roster change).
2. Each frame: snapshot Roots positions. For each visible body, read PlayerTag, find nearest
   root, tag {player, team}. Maintain a tracker mapping root→identity across frames by proximity.
3. ESP: draw every root (box/tracer/dist via WorldToViewportPoint); color by team if known.
4. Aimbot: target nearest-to-crosshair root whose team≠local (or any if unknown), aim camera.

## Feature viability (grounded)
- WORKS now: ESP (roots, through-wall, no team color), Aimbot (roots, nearest-to-crosshair),
  Triggerbot (raycast to a visible rig / or root-screen check), Fullbright, Crosshair, Freecam,
  Unlock-attachments, Hitscan, No-recoil, No-spread.
- LIMITED: team-colored ESP / enemy-only aimbot — no root→team link (would need rendered-body
  nametag correlation, best-effort).
- UNSUPPORTED without engine: Speed / Fly (no Humanoid; movement is engine-controlled),
  Silent-aim (fire remote arg shape is in the deleted engine), Skeleton ESP / Chams
  (no persistent rig; only visible rigs exist, obfuscated).
