# Level 01 — Solution Record (S03-TV5)

**Issue:** #20  
**Owner:** TV5 (verification and evidence only)  
**Source baseline:** `main` commit `86f573b` from the supplied project ZIP  
**Status:** `WAIT` for Sprint 03 Echo-puzzle acceptance

## 1. Current merged Level 01 data

The supplied `res://data/levels/level_01.tres` currently defines:

- Level: `First Step`
- Grid: `7 × 5`
- Player start: `(1, 2)`
- Exit: `(5, 2)`
- Wall cells: boundary walls and obstacle `(3, 2)`
- `switch_positions`: empty
- `door_configs`: empty

This is the Sprint 02 baseline. It does not contain a Switch or Door and does not require an Echo. Therefore it cannot, in its current form, prove the Sprint 03 requirement of a real Echo-assisted puzzle.

## 2. Existing no-Echo route (Sprint 02 baseline only)

The route already present in `scenes/tests/level_01_test.gd` is:

| Tick | Action | Player cell after action | Expected |
|---:|---|---|---|
| Start | — | `(1, 2)` | Player at start |
| 1 | `RIGHT` | `(2, 2)` | Valid floor cell |
| 2 | `UP` | `(2, 1)` | Valid floor cell |
| 3 | `RIGHT` | `(3, 1)` | Goes around wall `(3, 2)` |
| 4 | `RIGHT` | `(4, 1)` | Valid floor cell |
| 5 | `DOWN` | `(4, 2)` | Valid floor cell |
| 6 | `RIGHT` | `(5, 2)` | Player reaches Exit |

Action sequence:

```text
RIGHT, UP, RIGHT, RIGHT, DOWN, RIGHT
```

This route demonstrates Player-only arrival at the current Exit. It is not a Sprint 03 Echo puzzle solution and must not be used as evidence that Echo replay is integrated.

## 3. Synthetic fixture sequence used by the TV5 regression runner

The F6 regression runner uses a separate manager/module-only fixture to test deterministic action history and tick ordering without changing `level_01.tres`:

- Start `(2, 2)`
- Switch `(1, 2)`
- Door `(3, 2)`
- Exit `(4, 2)`

| Loop | Tick | Player action | Fixture Echo action | Expected result |
|---:|---:|---|---|---|
| 1 | 1 | `LEFT` | — | Player reaches Switch cell; action is recorded |
| 1 | End Loop | — | — | 11 `WAIT` actions pad the history to 12 |
| 2 | 1 | `RIGHT` | Echo 1: `LEFT` | Door is closed in the start-of-tick snapshot; Player is blocked; fixture Echo reaches Switch; Door opens after actor movement and switch evaluation |
| 2 | 2 | `RIGHT` | Echo 1: `WAIT` | Player moves toward the Door using the now-open state |
| 2 | 3 | `RIGHT` | Echo 1: `WAIT` | Current Player reaches Exit and fixture records a win |

This sequence is a deterministic test fixture, not a claim about the actual Level 01 Resource. When the TV2 Echo scene is absent from the tested main branch, the runner uses a `PlayerController` stand-in for fixture Echo movement and marks the real EchoController item `NOT RUN`.

## 4. F6 regression result recorded on 2026-11-14

TV5 ran `res://scenes/tests/replay_regression_test.tscn` in Godot 4.7.2.stable. The supplied game-window screenshot displayed:

```text
S03 TV5 | PASS 19 | FAIL 0 | NOT RUN 1
```

Interpretation:

- The synthetic manager/module fixture completed with 19 internal assertions passed and 0 failed.
- The same fixture was executed 10 times; the runner compared the trace from runs 2–10 against run 1.
- One real EchoController scene/API item was reported `NOT RUN` because `scenes/player/echo.tscn` was not available on the tested main snapshot.
- This result is evidence for the independent synthetic fixture only. It does not prove the actual Level 01 puzzle has a solution, nor that F5 integrated Echo gameplay works.
- The current screenshot shows the summary label. Attach the Output-panel log with the individual PASS lines and `REPLAY_RUN=01` through `REPLAY_RUN=10` to PR #20 when available.

**Current conclusion:** F6 synthetic regression fixture = partial PASS; actual Sprint 03 Level 01 Echo-puzzle solution = `WAIT`.

## 5. Required update from TV3 / Leader before final S03 sign-off

To convert this record into the actual Level 01 solution:

1. TV3 must provide/merge the final Level 01 Switch and Door data, including the approved door-to-switch mapping.
2. Leader must merge the Echo/TimeLoop integration and confirm the final API/fixture contract.
3. TV5 then records the actual action list by loop and tick, expected Player/Echo cells, door snapshot/state and win result from F5 gameplay.
4. Confirm that only the current Player reaching Exit triggers victory; Echo standing on Exit alone must not win.

Until these conditions are met, retain this file's status as `WAIT`. TV5 must not invent LevelData or change the puzzle data owned by TV3.
