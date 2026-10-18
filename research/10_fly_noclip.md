# 10 — Fly & Noclip
**Spec:** "Overrides local character root part velocities or collision masks to pass through walls or move infinitely fast."
**Trust:** SERVER-AUTH (movement validated, but PF is lenient on short bursts).
**Approach:** BodyVelocity+BodyGyro on HRP for flight. Per-frame CanCollide=false on all character parts for noclip. WASD+QE movement in camera direction.
**Risks:** HIGH — PF has anti-fly detection. Mark in UI.
