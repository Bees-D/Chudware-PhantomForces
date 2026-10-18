# 07 — Silent Aim
**Spec:** "Redirects fired raycasts/bullet paths directly to targets without moving the player's camera."
**Dump:** `<K0Zp].RemoteEvent` — the main game remote (obfuscated single event, PF channels everything through it). `<K0Zp].UnreliableRemoteEvent` for high-freq data.
**Trust:** CLIENT-AUTH — PF uses client-side hit registration (the client tells the server "I hit this player at this position"). This is well-documented for PF.
**Approach:** __namecall hook on RemoteEvent:FireServer. Detect bullet/hit payloads by argument shape (table with position/part data). Rewrite hit target to nearest enemy head. Requires getrawmetatable + setreadonly.
**Risks:** Server may validate distance/angle. PF has had varying levels of server-side validation over its lifetime.
