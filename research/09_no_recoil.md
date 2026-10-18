# 09 — No Recoil
**Spec:** "Forces camera kick, rotational displacement, and translational values to 0."
**Dump:** No decompiled recoil module. But PF's recoil is applied client-side (camera CFrame manipulation). The dump confirms `ClientModules` folder exists at `4DY;hBIU.ClientModules`.
**Trust:** LOCAL.
**Approach:** Two methods:
1. Per-frame camera compensation: record CFrame before recoil, restore after (RenderStepped).
2. hookfunction scan: iterate getgc() for recoil functions, hook to return zero vectors. Requires hookfunction.
Method 1 is the reliable fallback. Store camera rotation pre-shot, snap back post-shot.
**Risks:** Camera compensation may feel jittery. hookfunction approach is cleaner but requires the executor to support getgc.
