# 11 — Speed
**Spec:** Speedhack via WalkSpeed override.
**Trust:** CLIENT-AUTH — Humanoid.WalkSpeed is client-writable. PF may validate extreme values.
**Approach:** Set Humanoid.WalkSpeed per Heartbeat. Slider 16-100. Default sprint is 16.
**Risks:** MEDIUM — values above ~25 may trigger AC.
