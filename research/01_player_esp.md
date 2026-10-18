# 01 — Player ESP

**Spec:** "ESP / Wallhacks: Draws 2D/3D boxes, distance markers, snaplines, and health bars over enemy players through walls."

**Dump evidence:**
- `instances_flat.json:50830` — HumanoidRootPart in `<K0Zp].Character`
- `instances_flat.json:50866` — Torso, `instances_flat.json:50902` — Head
- `instances_flat.json:52493` — NameTagGuiOlf, `instances_flat.json:52523` — NameTagGui
- PF uses R6 rigs (Torso, not UpperTorso)

**Trust model:** LOCAL — reads workspace player positions, no remote needed.

**Approach:** Drawing API for 2D boxes, names, health bars, distance, snaplines. Team detection via `player.Team` or `player.TeamColor`. Per-frame RenderStepped with 20fps throttle.

**UI controls:** Toggle, show boxes/names/health/distance/snaplines, max distance slider, team color toggle.

**Risks:** None — purely visual, no network traffic.
