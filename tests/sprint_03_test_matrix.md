# S03-TV5 — Replay Regression Test Matrix

**Issue:** #20  
**Owner:** TV5  
**Engine:** Godot 4.7.2.stable  
**Test scene:** `res://scenes/tests/replay_regression_test.tscn`  
**Test runner:** `res://tests/replay_regression_test.gd`  
**Test type:** F6 manager/module-only deterministic fixture. F5 integrated Gameplay evidence is owned by Leader.

## 1. Scope and source baseline

The supplied project snapshot is based on `main` commit `86f573b` (`origin/main` at the time the ZIP was created). The snapshot contains `TimeLoopManager`, `TurnManager`, `PlayerController`, `PressureSwitch`, `Door` and `ExitPortal`.

The same project archive included the remote ref `origin/feature/EL-S03-TV2` at `7e92b03`, which adds `scenes/player/echo.tscn` and `scripts/player/echo_controller.gd`; those files were not part of `main` in the tested project snapshot. The tested `gameplay.gd` still does not execute the emitted `echo_actions` in integrated Gameplay, and the Sprint 02 End Loop path is not an integrated Echo flow.

`data/levels/level_01.tres` in the tested main snapshot has empty `switch_positions` and `door_configs`. It is the Sprint 02 no-Echo baseline, not the Sprint 03 Echo puzzle. The TV5 runner therefore uses a clearly labelled **synthetic, manager/module-only fixture**. It is not evidence that F5 Level 01 Echo gameplay is integrated.

## 2. Result legend

- `PASS`: the corresponding assertion was executed and passed in the F6 fixture.
- `PARTIAL`: the behavior is exercised or appears in the trace, but the runner has no dedicated assertion for the complete Expected condition.
- `NOT RUN`: dependency or runtime integration is unavailable, or the specific test was not executed.
- `WAIT`: blocked on another owner's unmerged change or the integrated build/approved fixture.
- `FAIL`: executed and did not meet Expected.

## 3. F6 execution record

**Observed result from the Godot game-window screenshot supplied by TV5:**

```text
S03 TV5 | PASS 19 | FAIL 0 | NOT RUN 1
Godot 4.7.2.stable
```

- 19 internal assertions passed; 0 failed; 1 item was reported as NOT RUN.
- The runner performs 10 synthetic fixture executions and compares runs 2–10 with the first run's canonical trace.
- The single NOT RUN item is the real `EchoController` scene/API check because `res://scenes/player/echo.tscn` was unavailable in the tested main snapshot.
- This total counts internal assertions, not 19 separate rows in the matrix.
- The screenshot confirms the summary counter. Keep the Output-panel log (including `REPLAY_RUN=01` through `REPLAY_RUN=10`) as additional PR evidence when available.
- F5 integrated Gameplay and the actual Level 01 Echo-puzzle solution have not been validated by this F6 run.

## 4. Test cases

| ID | Test / setup | Expected | Observed / evidence | Status |
|---|---|---|---|---|
| S03-01 | `TimeLoopManager`: record 12 valid actions, then attempt action 13 | Exactly 12 actions are stored; action 13 is rejected | Runner assertion passed: accepted 12 actions, count is 12, thirteenth action rejected | PASS |
| S03-02 | End Loop after one action | History is padded to 12 entries; entries 2–12 are `WAIT` | Runner assertion passed: first action is `LEFT`, remaining 11 entries are `WAIT` | PASS |
| S03-03 | End first, second and third loops | First and second End Loop succeed; third is rejected; Echo count never exceeds 2 | Runner assertion passed: results are `true`, `true`, `false`; `get_echo_count()` remains 2 | PASS |
| S03-04 | End the third loop without winning | `run_failed` fires and manager is finished; no third Echo is created | Runner assertion passed: third loop rejected, `run_failed` observed, `is_finished` true | PASS |
| S03-05 | Loop 2 tick 1: Player attempts to enter closed Door while the fixture Echo actor reaches Switch | Door snapshot starts closed; Player stays in place; blocked action still consumes one tick; Door opens only after actor movement/switch evaluation | Runner assertions passed for tick count, unchanged Player cell, `door_start=false` and `door_end=true` | PASS |
| S03-06 | Loop 2 tick 2: Player moves toward Door after Switch activation | Door snapshot is open at tick start and Player enters the Door cell | Tick 2 action is included in the generated trace and deterministic comparison, but runner has no separate assertion of the tick-2 Door snapshot and Player cell | PARTIAL |
| S03-07 | Player proceeds through Door to Exit | Only current Player reaching Exit returns success | Runner assertion passed: fixture Player reaches `(4, 2)` and `_player_won` is true | PASS |
| S03-08 | Put Echo actor on Exit while Player is elsewhere | Echo alone cannot win | Runner assertion passed using the PlayerController stand-in as the fixture Echo actor; this does not validate real EchoController integration | PASS — fixture only |
| S03-09 | Restart after a run containing Echo history | Manager history/tick/loop reset; fixture rebuild has Player at start, no Echo actors, Switch inactive and Door closed | Both runner restart assertions passed | PASS |
| S03-10 | Replay the exact same synthetic fixture 10 times | Canonical trace is identical in all 10 runs | Runner compared each of runs 2–10 with run 1; all comparisons passed | PASS |
| S03-11 | Execute the real `EchoController` scene/API | Use merged `scenes/player/echo.tscn` and `scripts/player/echo_controller.gd`; stand-in is not equivalent evidence | Runner reported the real Echo scene/API item as NOT RUN | NOT RUN |
| S03-12 | Execute actual Level 01 Echo-puzzle solution through Gameplay | Level data contains the final Switch/Door puzzle and integrated Gameplay replays real Echoes | Current tested `level_01.tres` has no Switch/Door configuration; no actual Echo-assisted Level 01 run | WAIT — TV3 / Leader |
| S03-13 | F5 MainMenu → integrated Level 01 → win/return flow | Leader confirms full integration and no runtime errors | Not covered by the F6 manager/module-only fixture | WAIT — Leader |

## 5. Synthetic fixture used by the current F6 runner

This is a **synthetic test-only fixture**, not the current `level_01.tres`:

- Start cell: `(2, 2)`
- Switch cell: `(1, 2)`
- Door cell: `(3, 2)`
- Exit cell: `(4, 2)`
- Loop 1: Player performs `LEFT`, then End Loop pads 11 `WAIT` actions.
- Loop 2, tick 1: Player performs `RIGHT` toward the still-closed Door while the fixture Echo actor performs `LEFT` onto the Switch. The Door snapshot at tick start remains closed, so Player is blocked. After actor movement and Switch evaluation, Door opens.
- Loop 2, tick 2: Player performs `RIGHT` toward the now-open Door.
- Loop 2, tick 3: Player performs `RIGHT` and reaches Exit.

When the TV2 Echo scene is absent, the runner uses `PlayerController` as a movement-only stand-in to exercise TimeLoopManager action history and fixture ordering. The real EchoController case remains `NOT RUN`; do not describe this stand-in as a test of Echo visuals/controller code.

## 6. Evidence to attach to PR #20

1. F6 game-window screenshot showing `PASS 19 | FAIL 0 | NOT RUN 1` (captured on Godot 4.7.2.stable).
2. Output-panel screenshot/log showing the individual `PASS` lines and `REPLAY_RUN=01` through `REPLAY_RUN=10` trace hashes.
3. After TV2 Echo and TV3 Level 01 changes are merged, repeat the relevant tests using the real Echo scene and approved LevelData/fixture; update S03-06 and S03-11/S03-12 accordingly.
4. F5 integrated Gameplay evidence must be supplied/confirmed by Leader. TV5 must not mark F5 as PASS based only on F6.

## 7. Acceptance note

The current F6 run is a **partial PASS for the independent synthetic fixture**, not a Sprint 03 Gate PASS. Do not mark Sprint 03 Gate PASS while S03-06 remains PARTIAL and S03-11, S03-12 or S03-13 remain NOT RUN/WAIT. Any change to Core, Gameplay, `project.godot`, or LevelData is outside TV5's file ownership and requires the responsible member/Leader to make the change.
