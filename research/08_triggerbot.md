# 08 — Triggerbot
**Spec:** "Automatically fires the weapon the instant an enemy hitbox enters the crosshair."
**Trust:** LOCAL (raycast) + CLIENT-AUTH (mouse click simulation).
**Approach:** Per-frame raycast from camera. If hits an enemy character part, simulate mouse1 down via VirtualInputManager or mouse1Click. Team check. Configurable delay.
**Risks:** Rapid fire patterns may be detectable.
