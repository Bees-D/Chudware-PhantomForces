# 06 — Aimbot
**Spec:** "Automatically snaps crosshairs to visible or concealed enemy hitboxes (head, torso)."
**Dump:** Player characters with Head part. Camera is client-owned.
**Trust:** LOCAL (camera manipulation only).
**Approach:** Find nearest enemy head in FOV, lerp camera CFrame toward it. Hold key (C). Smoothing slider. FOV circle via Drawing. Team check via player.Team.
**Risks:** No AC detection for camera — PF AC focuses on movement/damage.
