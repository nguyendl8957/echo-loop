# Echo Loop — Module Integration Contract

**Version:** Sprint 05 integration baseline  
**Engine:** Godot 4.7.2 stable  
**Language:** GDScript  
**Owner:** Leader — Game Core and Integration  
**Status:** Integrated source contract; final Android release acceptance pending

This document describes the public interfaces, ownership boundaries, and gameplay invariants used by the integrated five-level game. For implementation details, the approved repository source is authoritative.

## 1. Immutable Gameplay Rules

- Each Time Loop contains exactly 12 ticks.
- A maximum of two Echoes may replay earlier loops.
- Supported actions are UP, DOWN, LEFT, RIGHT, and WAIT.
- WAIT and blocked movement consume one tick.
- Early End Loop pads remaining replay actions with WAIT.
- Player and Echo actors may occupy the same grid cell.
- All actors use the same beginning-of-tick door snapshot.
- Actor movement occurs before switch and door updates.
- Only the current Player can trigger Exit completion.
- A run fails when the third loop is exhausted without victory.
- Restart resets run state without deleting unlocked progress.

No visual, UI, or level-balancing change may silently modify these rules.

## 2. Tick Processing Order

1. Capture the initial door and blocker states.
2. Collect the current Player action and Echo replay actions.
3. Validate movement against the initial snapshot.
4. Resolve Player and Echo positions for the tick.
5. Recalculate pressure-switch activation.
6. Recalculate linked-door states.
7. Check Player victory at Exit.
8. Finalize the tick and synchronize the HUD and loop state.

A door opened at the end of a tick cannot be entered retroactively during the same tick. An actor already occupying a door cell may leave even if that door closes.

TurnManager and TimeLoopManager own tick and loop state. Individual actors and HUD controls must not increment ticks independently.

## 3. Grid Coordinate Contract

- Logical coordinates use `Vector2i`.
- Current cell size is 48 x 48 logical pixels.
- Grid origin is the top-left corner.
- X increases to the right; Y increases downward.
- Cell center: `Vector2(x * 48 + 24, y * 48 + 24)`.
- Valid cell bounds: `0 <= x < grid_width` and `0 <= y < grid_height`.

Core supplies blocked cells, including walls, out-of-bounds targets, and closed doors from the tick snapshot.

## 4. LevelData

Script: `res://scripts/core/level_data.gd`  
Class: `LevelData extends Resource`  
Owner: Leader (schema), TV3 (level resources)

Important fields:

| Field | Type | Purpose |
|---|---|---|
| `level_id` | `int` | Level identifier |
| `level_name` | `String` | Level display name |
| `grid_width` | `int` | Grid width |
| `grid_height` | `int` | Grid height |
| `player_start` | `Vector2i` | Starting position |
| `exit_position` | `Vector2i` | Exit position |
| `wall_cells` | `Array[Vector2i]` | Wall locations |
| `switch_positions` | `Array[Vector2i]` | Switch locations |
| `door_configs` | `Array[Dictionary]` | Door configurations |

Methods:
- `is_in_bounds(cell: Vector2i) -> bool`
- `validate_level() -> PackedStringArray`

Door configurations used by the integrated Gameplay contain a `position` (`Vector2i`) and `switch_indices` (`Array` of integer switch indices). Each configured door requires one or two valid linked switches.

Level resource paths:
- `res://data/levels/level_01.tres`
- `res://data/levels/level_02.tres`
- `res://data/levels/level_03.tres`
- `res://data/levels/level_04.tres`
- `res://data/levels/level_05.tres`

Changing the LevelData schema requires Leader approval and regression testing.

## 5. LevelManager

Script: `res://scripts/core/level_manager.gd`

Public interface:
- `LevelManager.MIN_LEVEL = 1`
- `LevelManager.MAX_LEVEL = 5`
- `LevelManager.load_level(level_id: int) -> LevelData`

Invalid or unavailable levels must not be loaded as playable levels. Completing Level 05 must not unlock Level 06.

## 6. Player Controller

Script: `res://scripts/player/player_controller.gd`  
Scene: `res://scenes/player/player.tscn`  
Class: `PlayerController`  
Owner: TV2

Public methods:
- `reset_position(start_cell: Vector2i) -> void`
- `apply_action(action: String, blocked_cells: Array[Vector2i]) -> bool`

State:
- `grid_position: Vector2i`

`apply_action()` returns true when the Player changes cells and false when no movement occurs. A false return does not mean a valid WAIT or blocked action should be refunded a tick.

The Player Controller does not own the game clock, switch updates, or Echo histories.

## 7. Echo Controller

Script: `res://scripts/player/echo_controller.gd`  
Scene: `res://scenes/player/echo.tscn`  
Owner: TV2

Gameplay creates Echo instances from recorded histories and supplies the starting position, action history, and visual tint.

Relevant integration methods:
- `setup_echo(start_cell, action_history, tint)`
- `apply_echo_action(tick_index, blocked_cells)`

Echo actors replay previously recorded actions. They do not read current Player input, increment ticks, or trigger victory at Exit.

## 8. Puzzle Objects

Owner: TV3

### PressureSwitch

Script: `res://scripts/puzzle/pressure_switch.gd`

State:
- `grid_position: Vector2i`
- `is_active: bool`

Methods:
- `update_state(actor_positions: Array[Vector2i]) -> bool`
- `reset_state() -> void`

A switch is active while at least one actor occupies its cell.

### Door

Script: `res://scripts/puzzle/door.gd`

State:
- `grid_position: Vector2i`
- `linked_switches: Array[PressureSwitch]`
- `is_open: bool`

Methods:
- `evaluate_state() -> bool`
- `can_enter() -> bool`
- `is_blocking() -> bool`
- `is_blocking_for_tick(snapshot_is_open)`
- `reset_state() -> void`

A linked door opens only when all required switches are active. Core must evaluate entry using the beginning-of-tick snapshot.

### ExitPortal

Script: `res://scripts/puzzle/exit_portal.gd`  
Scene: `res://scenes/puzzle/exit_portal.tscn`

Relevant methods:
- `is_at(cell: Vector2i) -> bool`
- `check_player_reached(player_grid_pos: Vector2i) -> bool`

Only the current Player's position is passed to the victory check.

## 9. TimeLoopManager and TurnManager

Time Loop script:
`res://scripts/timeloop/time_loop_manager.gd`

Turn script:
`res://scripts/core/turn_manager.gd`

Constants:
- `TimeLoopManager.MAX_TICKS = 12`
- `TimeLoopManager.MAX_ECHOES = 2`

TurnManager methods:
- `setup(loop_manager: TimeLoopManager) -> void`
- `submit_player_action(action: String) -> void`
- `end_current_loop() -> void`
- `restart_run() -> void`

Relevant signals:
- `tick_actions_requested(...)`
- `tick_finished(tick_number: int)`
- `input_rejected(action: String)`

Core must prevent concurrent or duplicated action processing. Input is locked when a run is finished or when the Gameplay controller requires it.

## 10. HUD Contract

Script: `res://scripts/ui/hud.gd`  
Scene: `res://scenes/ui/hud.tscn`  
Owner: TV4

Signals:
- `action_requested(action: String)`
- `end_loop_requested`
- `restart_requested`

Methods:
- `update_hud(level, tick, max_tick, echo_count) -> void`
- `update_loop_status(loop_number, echo_count, is_finished) -> void`
- `set_input_locked(locked) -> void`

HUD responsibilities:
- Display LEVEL, TICK, LOOP, and ECHO.
- Emit input requests.
- Present directional, WAIT, ENDLOOP, and RESTART controls.
- Reflect disabled and pressed states.
- Remain usable in Android landscape mode.

HUD must not independently execute turns, control Player movement, or change Time Loop state.

## 11. GameManager

Script: `res://scripts/core/game_manager.gd`  
Autoload: `GameManager`  
Owner: Leader

Navigation and progress methods:
- `start_new_game() -> void`
- `open_gameplay() -> void`
- `back_to_menu() -> void`
- `complete_level() -> void`
- `get_unlocked_level() -> int`
- `can_play_level(level_id: int) -> bool`
- `select_level(level_id: int) -> bool`
- `open_level_select() -> void`

Audio preference methods:
- `is_sound_enabled() -> bool`
- `set_sound_enabled(enabled: bool) -> bool`

GameManager manages level progression, navigation, audio initialization, and persistence integration. It does not change the established actor movement or door-snapshot rules.

`complete_level()` must only apply once for a single completed run and must preserve unrelated save preferences.

## 12. SaveManager and Audio

SaveManager script:
`res://scripts/data/save_manager.gd`

AudioManager script:
`res://scripts/data/audio_manager.gd`

Owner: TV5

SaveManager is instantiated from its script; it is not a separate Autoload.

Methods:
- `load_progress() -> Dictionary`
- `save_progress(data: Dictionary) -> bool`
- `reset_progress() -> bool`

Persisted data:
- `unlocked_level`
- `sound_enabled`

Not persisted:
- Current Player position
- Tick or loop in progress
- Echo histories
- Unfinished run state

Main Menu SoundButton calls GameManager to change the saved sound preference. Audio behavior must follow that preference.

## 13. UI Navigation Contract

### Main Menu

Scene: `res://scenes/menus/main_menu.tscn`  
Script: `res://scripts/core/main_menu.gd`

Controls:
- New Game
- Continue
- How to play
- Sound: ON/OFF
- Exit

Continue opens Level Select. It does not restore an unfinished run.

### Level Select

Scene: `res://scenes/ui/level_select.tscn`  
Script: `res://scripts/ui/level_select.gd`

Signals:
- `level_selected(level_id: int)`
- `back_requested`

Method:
- `set_unlocked_levels(unlocked_count: int) -> void`

Locked levels must not be selectable.

### Level Complete

Scene: `res://scenes/ui/level_complete.tscn`

Signals:
- `result_next_requested`
- `result_replay_requested`
- `result_level_select_requested`

Method:
- `set_completed_level(level_id: int) -> void`

Next Level requires explicit Player input. Level 05 must not advance to Level 06.

### Pause Menu

Scene: `res://scenes/ui/pause_menu.tscn`

Signals:
- `pause_resume_requested`
- `pause_restart_requested`
- `pause_menu_requested`

Gameplay owns the pause state. Pause must not consume ticks or append replay actions. Restart begins a fresh run.

## 14. Back Navigation

The integrated source defines:

| Screen | Back Behavior |
|---|---|
| Main Menu | Exit |
| Tutorial | Return to Main Menu |
| Level Select | Return to Main Menu |
| Gameplay | Open Pause |
| Pause Menu | Resume Gameplay |
| Level Complete | Open Level Select |

Android Back is handled through `NOTIFICATION_WM_GO_BACK_REQUEST`. PC Escape is used for desktop navigation regression.

Automatic quit on Android Back is disabled in project settings. Physical-device behavior remains subject to final Android QA.

## 15. Source Ownership

| Role | Owned Scope |
|---|---|
| Leader | `scripts/core/`, `scripts/timeloop/`, central Gameplay, integration contract, release configuration |
| TV2 | `scripts/player/`, `scenes/player/`, actor visuals |
| TV3 | `scripts/puzzle/`, `scenes/puzzle/`, `data/levels/` |
| TV4 | `scripts/ui/`, `scenes/ui/`, UI test documentation |
| TV5 | `scripts/data/`, audio, assigned QA and release reports |

Shared API and ownership changes require review. Tests and documentation must reference the actual commit used.

## 16. Testing and Integration Gates

### Source and PC verification

- Clean project import.
- Relevant F6 module tests.
- F5 Main Menu and Gameplay smoke tests.
- Five-level data validation.
- Tick, WAIT, blocked movement, and Echo replay regression.
- Door snapshot and switch/door state verification.
- Pause, Restart, and Level Complete navigation.
- Level unlock and Save/Load verification.
- Sound ON/OFF persistence.
- Escape navigation and Back behavior.
- No new parser or runtime errors.

### Android release verification

- Exported APK linked to an exact source commit.
- APK SHA-256 recorded.
- Real Android device and OS recorded.
- Five levels completed on the final build.
- Touch input, Back, orientation, and UI layout tested.
- Offline, background/resume, and reopen behavior tested.
- Save and sound preferences verified.
- No unresolved blocking defects.
- Final QA report and Leader approval.

Leader-reported PC tests are recorded as PC results, not physical Android acceptance.

## 17. Future Level and Visual Polish

Subsequent changes may refine level difficulty, environment graphics, sprites, and user experience.

Such work must:
- Preserve immutable gameplay rules.
- Preserve public module interfaces unless separately approved.
- Update documented action sequences and expected outcomes for changed levels.
- Re-run affected F6/F5 tests.
- Rebuild and re-test the final Android APK if runtime or packaged assets change.

## 18. Release State

Sprint 05 source integration and documentation are in progress toward final acceptance.

The project must not be declared fully released until its final source, APK, physical-device tests, evidence, and QA approvals are consistent.

Earlier Sprint 02–04 design and implementation records remain available in Git history and historical project documents.
