# Platformer Build Plan — Unit 1 (Godot Game Design)

A build spec for a 5-lesson introductory platformer, written to hand off for implementation. This is the "quick and easy" version deliberately — simpler mechanics are chosen over more precise ones at every decision point, with more advanced approaches noted as optional homework/challenge extensions rather than built into the core path.

## Current teaching decisions

- **Platforms:** plain `StaticBody2D` rectangles, not TileMap. TileMap is a homework/video rabbit hole for interested students, not core content.
- **Moving obstacles:** horizontal and vertical patrols reverse direction with a `Timer`; rotating obstacles change `rotation_degrees` continuously. Use `Area2D` for contact hazards and `AnimatableBody2D` for moving solid blocks. No Tween, AnimationPlayer, or waypoints required.
- **Player movement:** instant velocity on left/right — no acceleration/deceleration curve.
- **Continuity with prior material:** everything reuses the gravity/flap pattern already established — `_physics_process`, `delta`, `move_and_slide()` — so the abstraction transfers instead of being retaught from zero.

## Suggested lesson sequence

| Lesson | Build | Checkpoint |
|---|---|---|
| 1 | Player movement, gravity, jump | Character walks and jumps around an empty test room |
| 2 | Real level, platforms, camera | A level with gaps to jump across; camera follows the player |
| 3 | Coins, score, UI | Touching a coin removes it and updates a score label |
| 4 | Respawning, horizontal/vertical hazards, moving gates, rotation | Hazards respawn the player; solid obstacles block movement; students configure motion |
| 5 | Goal, win/lose screens, persistence | Reaching the flag shows a win screen; best score/time is saved across restarts |

---

## Project structure

```text
World (Node2D, world.gd)
├── Player (instance of player.tscn)
├── Camera2D
├── Platforms (Node2D — holds StaticBody2D rectangles)
├── Coins (Node2D — holds Coin instances)
├── Obstacles (Node2D — holds hazard and solid obstacle instances)
├── Goal (Area2D)
└── UILayer (CanvasLayer)
    ├── ScoreLabel
    ├── StartScreen
    ├── WinScreen
    └── GameOverScreen

Player (CharacterBody2D, player.gd)
├── CollisionShape2D
└── Sprite2D

Coin (Area2D, coin.gd)
├── CollisionShape2D
└── Sprite2D

Hazard (Area2D, hazard.gd)
├── CollisionShape2D
├── Sprite2D
└── FlipTimer (Timer)

MovingBlock (AnimatableBody2D, moving_block.gd)
├── CollisionShape2D
├── Sprite2D
└── FlipTimer (Timer)

RotatingHazard (Area2D, rotating_hazard.gd)
├── CollisionShape2D
└── Sprite2D

RotatingBlock (AnimatableBody2D — optional solid variant)
├── CollisionShape2D
└── Sprite2D
```

An **Autoload singleton** (`GameState.gd`) holds score and best-score/time — the same role the Sync node played in the Flappy Bird + AI project: something that survives scene reloads.

---

## Lesson 1 — Move & Jump

**Nodes touched:** Player only, in an empty test scene.

**Mechanics:**

1. Script goes **directly on the `CharacterBody2D`**, not on a wrapper `Node2D` parent (unlike Bird in the Flappy Bird project). There's no separate stationary visual layer to protect here, so the extra indirection isn't needed. *(Open question if consistency across units matters more than simplicity: could instead mirror the Bird pattern exactly — wrapper Node2D + child CharacterBody2D — call this during implementation.)*
2. Read `Input.get_axis("ui_left", "ui_right")` for horizontal direction — one line replaces a left/right if-chain.
3. `velocity.x = direction * speed`
4. Apply gravity every tick, same pattern as the Flappy Bird flap script (`ProjectSettings.get_setting("physics/2d/default_gravity")`, applied `* delta`).
5. Jump: `Input.is_action_just_pressed("ui_accept")`, gated by `is_on_floor()` so there's no infinite/double jump. This is the one genuinely new concept beyond what Flappy Bird already covered.
6. `move_and_slide()` last, same as before.

**Checkpoint:** walk left/right, jump, land, can't double-jump.

**Deferred (not core):** coyote time, variable jump height (holding jump = higher), acceleration/deceleration easing.

---

## Lesson 2 — Level & Camera

**Nodes touched:** Platforms, Camera2D.

**Mechanics:**

1. Place several `StaticBody2D` rectangles at varying heights and gaps — this *is* the level design, no code required.
2. Camera2D as a **child of Player** (free tracking, zero code) rather than a separately scripted camera that copies the player's position each tick. Simpler by default; a standalone camera is a fine thing to try later if more control is wanted (e.g. camera lag, dead zones).
3. Optional polish: camera limits (`limit_left/right/top/bottom`) so it doesn't show past the level edges.

**Checkpoint:** a real level exists with jumpable gaps; camera follows without extra code.

---

## Lesson 3 — Coins, Score, UI

**Nodes touched:** `Coin.tscn`, `ScoreLabel`.

**Mechanics:**

1. Coin is an `Area2D`, not a body — there's nothing solid to collide with, only overlap to detect.
2. Connect Coin's `body_entered` signal → check if the entering body is the player → `queue_free()` the coin, increment score.
3. Score lives in the `GameState.gd` autoload, not in the World script directly, so it can survive scene reloads later.
4. `ScoreLabel.text = "Score: %d" % GameState.score`

**Checkpoint:** touching a coin removes it and the score label updates.

**Open design question to resolve during build:** should Coin call a `GameState` function directly to update score, or should Coin emit a signal that World listens for and relays? Both are reasonable at this scale — worth trying both approaches and picking whichever feels clearer to teach.

---

## Lesson 4 — Obstacle Behavior & Respawning

**Goal:** build and compare obstacles that detect contact versus obstacles that physically block the player, then customize their motion.

**Nodes touched:** Player, Area2D, AnimatableBody2D, Sprite2D, CollisionShape2D, Timer.

### 1. Falling recovery and shared respawn behavior

- Store the player's starting `global_position` in `_ready()`.
- Add `respawn()` to restore that position and set `velocity = Vector2.ZERO`.
- After `move_and_slide()`, respawn when `global_position.y > 900` for the current course. Adjust this boundary if the level extends farther downward.
- Respawning repositions the player; it does not reload World. Collected coins remain collected and the score stays unchanged.

### 2. Horizontal and vertical contact hazards

- Use an `Area2D` with a visible sprite, collision shape, and repeating FlipTimer (Autostart on, One Shot off).
- Export `speed = 80.0` and `direction = Vector2.RIGHT` so each instance can be configured in the Inspector.
- Move with `position += direction * speed * delta` in `_physics_process()`.
- Connect Timer's `timeout` signal to a function containing `direction *= -1`.
- Use `(1, 0)` for rightward motion and `(0, -1)` for upward motion. The same scene supports horizontal and vertical hazards.
- Connect Area2D's `body_entered` signal; if `body.is_in_group("player")`, call `body.respawn()`.
- A two-second timer at 80 pixels/second gives 160 pixels of travel before each reversal. Changing timer duration changes patrol distance; changing speed changes both speed and distance for a fixed duration.
- These areas pass through terrain. Place their patrols intentionally.

### 3. Solid block and rising gate

- Create an `AnimatableBody2D` with Sprite2D and CollisionShape2D; leave Sync to Physics enabled and node scales at `(1, 1)`.
- First test it without movement: it physically blocks the player without a contact signal or respawn call.
- Add a repeating FlipTimer and the same exported speed/direction pattern. Use `speed = 60.0`, `direction = Vector2.UP`, and a two-second timer for a gate that rises 120 pixels and returns.
- Move it through `_physics_process()` by updating `position`; do not combine this with `move_and_slide()` or `move_and_collide()`.
- Suggested gate dimensions: 40 × 100 pixels. Match texture and collision dimensions.
- Test passing below the raised gate. Place it where its route is clear and the player has room to move away as it descends; crushing behavior is not part of this lesson.

### 4. Rotating obstacle

- Create an `Area2D` with a 160 × 20 pixel sprite and matching rectangular collision shape.
- Export `rotation_speed = 90.0` and update `rotation_degrees += rotation_speed * delta` in `_physics_process()`.
- No Timer is needed for continuous rotation. At 90 degrees/second, a full turn takes four seconds; a negative value reverses the direction.
- Connect `body_entered` to the same player-group check and respawn behavior as the other contact hazards.
- Keep both children at `(0, 0)` to rotate around the bar's center. Move both to `(80, 0)` to rotate around one end. This demonstrates the parent pivot and child positions.
- **Solid variant:** use an `AnimatableBody2D` root instead, change the script's `extends` accordingly, keep Sync to Physics enabled, and remove the contact signal connection and respawn handler. This rotating block physically interacts with the player.

### Important distinction and troubleshooting

An `Area2D` collision shape defines an overlap-detection region; it does not make the object solid. Walking through a hazard is expected, but contact should trigger respawning. `AnimatableBody2D` provides the moving solid version.

If a contact hazard does not respawn the player, check the `body_entered` connection, membership of the lowercase `player` group, that the collision shape is not disabled, and that the hazard's collision mask includes the player's collision layer. Use a temporary print in the handler and Debug > Visible Collision Shapes to investigate.

### Suggested one-hour pacing

- 0–10 minutes: falling recovery and respawn.
- 10–25 minutes: horizontal hazard, Timer, exported variables, vertical variant.
- 25–40 minutes: stationary solid block, then rising gate.
- 40–50 minutes: rotating obstacle demonstration and build.
- 50–60 minutes: playtest and adjust obstacle placement or motion.

If setup takes longer, keep the rotating solid variant and pivot experiment as extension choices. Reuse familiar sprite/collision setup to preserve time for experimentation.

**Checkpoint:** students can recover from falls and hazard contact, distinguish overlap detection from solid collision, configure horizontal and vertical motion, and explain how rotation differs from translation. Test that coins and score remain unchanged after respawning and that obstacles do not cover the spawn point.

**Student design challenge:** create a short obstacle section with a readable, avoidable route. Change one variable at a time, predict the effect, then test speed, direction, timer duration, or rotation speed.

**Deferred:** edge-detection with RayCast2D, waypoint paths, crushing mechanics, and more advanced animation systems.

---

## Lesson 5 — Goal, Win/Lose, Persistence

**Nodes touched:** Goal (`Area2D`), WinScreen, GameOverScreen, `GameState`.

**Mechanics:**

1. Goal is an `Area2D`; on `body_entered` → show WinScreen, freeze player input (simplest approach: a `game_over` bool checked at the top of `_physics_process`, or `set_physics_process(false)` on the player).
2. `GameState.gd` autoload holds `best_score` (and optionally `best_time`), compares and updates on win. Because it's an autoload, it persists across scene reloads with no save-to-disk needed yet.
3. A restart button reloads the World scene (`get_tree().reload_current_scene()`) — score resets to zero, but best score does not, since it lives in the autoload rather than the World.

**Checkpoint:** win screen appears at the goal, shows best score, restart button works and resets the level while keeping the best score.

**Deferred (not core):** actually saving best score to a file on disk so it survives *closing and reopening the game* (vs. just persisting for the current session). Clean stretch goal, not required for the core loop.

---

## Deliberately out of scope for core lessons

- TileMap-based level building
- Tween / AnimationPlayer-driven obstacle motion
- Acceleration/deceleration movement feel
- Coyote time / jump buffering
- Edge-detecting obstacles (RayCast2D)
- Saving best score to disk

Each of these is a clean "if you finish early" or homework hook, and skipping every one of them still leaves a complete, playable game at the end of Lesson 5.
