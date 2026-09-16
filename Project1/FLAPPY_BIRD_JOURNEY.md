# From Flappy Bird to a Learning Agent

A teaching guide and project journal for `Project1`, based on our walkthrough and experiments.

## What we achieved

We started with a small Flappy Bird clone built from memory. We added observations, actions, rewards, episode handling, and a Godot–Python connection. We trained in the editor, exported to macOS, ran four headless game instances, and compared saved models.

The final lesson was unexpected: training longer made the bird worse. In manual playback, the **200,000-step checkpoint from the long run** performed best. That is our best candidate so far, not a formally evaluated success rate.

This document reconstructs the game-building steps from the original project and records the AI integration we actually discussed. The original game already existed when the conversation began. The reset implementation still needs an audit before this becomes a fully verified, copy-and-paste classroom tutorial; see “What still needs verification.”

## Suggested lesson sequence

| Lesson | Build or demonstrate | Checkpoint |
|---|---|---|
| 1 | Bird movement and keyboard input | The bird falls and flaps |
| 2 | Pipes, spawning, collisions, score | A playable game that restarts |
| 3 | Agent observations and actions | Explain what the AI sees and controls |
| 4 | Rewards, episodes, resets, Sync | Repeated runs without scene reloads |
| 5 | Python training and playback | Save a model and watch it play |
| 6 | macOS export and parallel training | Four headless environments |
| 7 | Checkpoint comparison | Select a model using observed performance |

# Part I — Build the playable game

## 1. Organize the project into three scenes

The game uses Godot 4.6. Its core files live in `Project1/sprites/`.

```text
World (Node2D, world.gd)
├── Background (ColorRect)
├── Bird (instance of bird.tscn)
├── Camera2D
├── Pipe (instance of pipe.tscn)
├── ScoreLabel
├── ScoreTimer
└── PipeTimer

Bird (Node2D, bird.gd)
└── CharacterBody2D
    ├── CollisionShape2D
    └── Sprite2D

Pipe (Area2D, pipe.gd)
├── Collision shapes for upper and lower obstacles
└── Colored rectangles for their appearance
```

Set `world.tscn` as the main scene. The background defines an approximately 1150 × 650 play area. The bird starts near (200, 200).

The important structural detail is that **the CharacterBody2D moves; its Bird parent does not**. Later, observations and resets must use the moving child.

## 2. Give the bird gravity and a flap

In `bird.gd`:

1. Reference the CharacterBody2D child.
2. Read the project’s 2D gravity.
3. Add gravity to vertical velocity each physics tick, using `delta`.
4. On `ui_accept`, set vertical velocity to the negative flap speed.
5. Call `move_and_slide()`.

Godot’s positive Y direction points downward. Negative vertical velocity moves the bird upward. The script’s exported default is 100, but the bird scene overrides `jump_velocity` to **400**; the scene value is what this game uses.

Teaching point: a flap sets upward velocity. It does not teleport the bird or move it a fixed number of pixels.

## 3. Build a reusable pipe pair

The pipe scene contains both obstacles and their opening. Its Area2D detects the bird entering a collision shape.

In `pipe.gd`, move the pipe left by `speed * delta`. The current speed is 300 pixels per second. Delete pipes once their X position falls below −200.

In `world.gd`, instantiate pipes at X = 1200 with randomized Y positions between 300 and 500. Restart the one-shot PipeTimer after each spawn. The current interval is randomized between 1.3 and 1.75 seconds.

Connect the PipeTimer’s timeout signal to the spawn function and the pipe’s `body_entered` signal to its collision handler.

## 4. Add a score and restart behavior

ScoreTimer increments the score and updates ScoreLabel. **This score measures survival time, not pipes passed.** Passing-pipe scoring would require an additional detector or crossing check.

The original game reloaded its current scene on collision. That is a simple first implementation for human play. During the RL integration, we replaced it with an in-place reset so the communication node could remain alive.

The original game also lacked screen-exit death handling. We added it during integration to prevent an off-screen bird from earning survival rewards indefinitely.

**Human-game checkpoint:** flapping works, pipes move and spawn, collisions restart the game, and the score updates.

# Part II — Give the game an AI interface

## 5. Understand the learning loop

```text
Godot state → observations → Python policy → action → Godot simulation
                                ↑                         |
                                └── reward and episode end┘
```

- **Observation:** numbers describing the current situation.
- **Action:** the choice the agent can make.
- **Reward:** feedback about outcomes.
- **Episode:** one run, from reset until it ends.
- **Policy:** the model that maps observations to action choices.
- **PPO:** Proximal Policy Optimization, the learning algorithm used here. It collects experience and updates the policy in batches.

We did not need a custom PPO YAML file. We used the official Stable Baselines3 Python example and its command-line options. The older `gdrl` entry point was initially suggested, but the source marks it deprecated in favor of the example scripts.

## 6. Install Godot RL Agents

Use AssetLib to install Godot RL Agents, then enable it under Project Settings → Plugins. The plugin belongs under `res://addons/godot_rl_agents/`.

During installation, three files were skipped: the package’s `project.godot` and two C# ONNX files. Preserving our own `project.godot` was appropriate. The two ONNX files were not needed for the Python-based training and playback route used in this journey.

Do not generalize this to every conflict warning: inspect the filenames. Running a model through ONNX directly inside Godot is a separate deployment step that we did not complete.

## 7. Extend AIController2D

Add an AIController2D child to the Bird root, alongside CharacterBody2D. Use **Extend Script**, creating `bird_controller.gd`:

```gdscript
extends AIController2D
```

Extending the script inherits the plugin’s shared functionality while allowing our script to implement game-specific behavior. We do not edit the plugin’s base controller.

The four main methods are:

| Method | Purpose |
|---|---|
| `get_obs()` | Return the observation dictionary |
| `get_action_space()` | Declare the available choices |
| `set_action(action)` | Receive the chosen action |
| `get_reward()` | Return accumulated reward since collection |

The base controller can infer the observation size from `get_obs()`; a separate observation-space implementation was unnecessary here.

## 8. Add GapCenter and the pipes group

Add a Marker2D named **GapCenter** inside `pipe.tscn`, positioned in the opening. Its current local position is approximately (41, −98). The pipe root itself is not the center of the opening.

Add the pipe scene’s **root** to the **`pipes`** group. Each instance inherits the membership. Making the group global makes it available across the editor’s group lists; it does not change runtime lookup behavior.

We initially discussed a separate `gap_centers` group, then chose `pipes` because it also helps clear the level during reset. The controller finds each pipe and reads its GapCenter child.

## 9. Return four scaled observations

The observations, always in this order, are:

| Value | Calculation | Meaning |
|---|---|---|
| Bird height | Moving body’s global Y ÷ 650 | Vertical location |
| Vertical velocity | Y velocity ÷ 400 | Rising or falling, and how fast |
| Horizontal gap distance | (Gap global X − bird global X) ÷ 1150 | Distance ahead |
| Vertical gap offset | (Gap global Y − bird global Y) ÷ 650 | Opening above or below |

The position calculation assumes the play area begins near global Y = 0. Use a consistent coordinate system if restructuring the world.

Scaling changes the representation, not the game’s physics. For example, 575 pixels ahead becomes 0.5 screen widths. A negative gap offset means the gap is above the bird. Values can exceed ±1; dividing by a reference value does not enforce a bound.

The controller selects the nearest pipe not yet fully cleared. Our implementation keeps a pipe until its gap center is more than 85 pixels behind the bird, approximately accounting for the pipe half-width and bird radius. This is specific to our geometry.

If there is no pipe, it uses a default target one screen-width ahead and vertically aligned. The observation list still contains four numbers.

The return structure is:

```gdscript
return {
    "obs": [
        bird.global_position.y / PLAY_HEIGHT,
        bird.velocity.y / FLAP_SPEED,
        gap_offset.x / PLAY_WIDTH,
        gap_offset.y / PLAY_HEIGHT,
    ]
}
```

Teaching checkpoint: the distance shrinks as the pipe approaches; the vertical offset becomes zero when aligned with the opening.

## 10. Connect flap/no-flap actions

In the controller:

```gdscript
var flap_requested := false

func get_action_space() -> Dictionary:
    return {"flap": {"size": 2, "action_type": "discrete"}}

func set_action(action) -> void:
    flap_requested = action["flap"] == 1
```

There is one control with two choices: 0 = no flap; 1 = flap.

In `bird.gd`, reference the controller and call `ai_controller.init(self)` from `_ready()`. During physics processing, read keyboard input when `heuristic == "human"`; otherwise, read `flap_requested`. Clear the request after consuming it, then apply the same upward velocity used for human input.

We removed the original duplicate keyboard check, which would otherwise allow keyboard input during AI control.

Each received flap triggers once. A larger action-repeat setting therefore reduces opportunities to flap; it does not hold the flap continuously in this implementation.

## 11. Define rewards

We chose:

- **+0.1 per simulated second alive**, using `ai_controller.reward += 0.1 * delta`.
- **−1 on death**, applied once.

The controller already inherits a `reward` variable:

```gdscript
func get_reward() -> float:
    return reward
```

Our installed Sync calls `get_reward()` and then clears the reward with `zero_reward()`. Return reward accumulated **since the last collection**, not the lifetime episode total. Earlier advice to return cumulative episode reward was incorrect.

Do not add the displayed score to reward each frame. That would repeatedly reward previously earned score.

## 12. Replace scene reloads with episode handling

Our implementation splits responsibilities:

| Script | Responsibility |
|---|---|
| `bird.gd` | Guard against repeated death, apply penalty, stop movement, restore bird |
| `pipe.gd` | Send collision events to the Bird parent’s `die()` method |
| `world.gd` | Stop timers and pipes; remove pipes, reset score, spawn a fresh pipe |
| Controller / Sync | Track and report reward and completion |

The bird saves the moving CharacterBody2D’s starting local position. Reset restores that position, zeros velocity, clears pending flap input, and resets controller state.

Death sets `done` and `needs_reset`. The current code waits for Sync to collect the terminal result before resetting during training. Human mode resets without waiting for Python.

**Known limitation:** this sequencing may expose the dead-state observation as the next episode’s initial observation and discard an action during reset. It needs verification against the wrapper’s automatic-reset expectations before teaching it as a finished implementation. We have not demonstrated that it caused the later training regression.

The inherited controller also requested resets after 1,000 physics ticks. For this experiment, we disabled that automatic limit by adding this override to **`bird_controller.gd`**:

```gdscript
func _physics_process(_delta: float) -> void:
    pass
```

It does **not** belong in `bird.gd`, which already has its movement function. One script cannot define `_physics_process()` twice. With the override, runs end through death, not a fixed episode length.

## 13. Add Sync

Add the plugin’s Sync node as a child of World.

| Setting | First test | Training |
|---|---|---|
| Sync Control Mode | Human | Training |
| Sync Action Repeat | 1 | 1 throughout the successful comparison |
| Sync Speed Up | 1 | Later increased to 8 |
| Sync Process Mode | Always | Always |
| Controller Control Mode | Inherit From Sync | Inherit From Sync |

**Process Mode → Always** is different from Control Mode. Sync pauses gameplay while communicating with Python and must remain able to process while the tree is paused. Keep ordinary gameplay nodes on Inherit.

The base controller joins the `AGENT` group automatically. No manual signal wiring between Sync and the controller was required. The default Python connection port is 11008.

# Part III — Train and evaluate

## 14. Set up Python

From the repository root, a reproducible setup is:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install "godot-rl[sb3]"
curl -fL https://raw.githubusercontent.com/edbeeching/godot_rl_agents/main/examples/stable_baselines3_example.py -o stable_baselines3_example.py
```

Our traceback later showed packages loading from a user-level Python 3.10 installation, so the conversation does not establish that all runs used the virtual environment. For a class, choose one environment and record package versions and the downloaded script version. The upstream `main` branch can change.

## 15. Train in the editor

Start Python first:

```bash
python stable_baselines3_example.py --timesteps=10000 --save_model_path=flappy_first.zip
```

Then press F5 in Godot. Omitting `--env_path` selects editor training. This first short run checks communication, actions, rewards, and repeated resets; it is not a promise of a skilled bird.

To watch a saved model through Python:

```bash
python stable_baselines3_example.py --resume_model_path=flappy_first.zip --inference --timesteps=10000
```

Keep Sync in Training mode because it is still talking to Python. The Python `--inference` flag stops learning and uses the saved policy. Our example uses deterministic action selection during inference.

## 16. Save, resume, and interrupt

- `--save_model_path=NAME.zip` saves a model for later use.
- `--resume_model_path=NAME.zip` loads a model instead of starting from scratch.
- `--timesteps` sets additional training steps for the new run.
- `--save_checkpoint_frequency` saves intermediate models.
- `--experiment_name` identifies logs and checkpoints; use a new name for a new experiment.

The training script catches Ctrl+C and saves when `--save_model_path` is supplied. Press it once and wait for the saving message and shell prompt. A force quit or repeated interruption can prevent saving; checkpoints preserve earlier progress.

One resume detail: our script loads PPO settings from the saved model. Its resume branch does not apply the command-line learning rate to that loaded model. Changing `--learning_rate` alone would not change the resumed run’s learning rate.

# Part IV — Export on macOS and train faster

## 17. Create the export

1. Install matching templates through Editor → Manage Export Templates.
2. Open Project → Export and add macOS.
3. Set a bundle identifier such as `org.example.flappytraining`.
4. Use Built-in (ad-hoc only) signing and disable notarization for this local training build.
5. Keep App Sandbox disabled for this local setup.
6. Export a release `.app` into `Project1/exports/`.

We initially got a `.dmg`. Select `.app` in the export dialog, or mount the DMG and copy its app into the exports folder. Renaming an existing DMG to `.app` does not convert it.

### The two path problems we resolved

**App location:** the example command assumed `exports/` at the repository root, but the actual file was in `Project1/exports/`. This caused `assert os.path.exists(filename)` to fail.

**App name:** our installed Godot-RL helper assumed the outer app name matched its internal executable. The app was named `FlappyTraining.app`, but its executable was `Contents/MacOS/Project_1`. Renaming the outer bundle to **`Project_1.app`** resolved that mismatch. Future exports should use that matching name with this installed version.

Supply the `.app` path to `--env_path`, not the DMG or the internal executable path.

## 18. Test the export, then speed up

All following commands run from the repository root in the Python environment used for training.

First check one visible instance:

```bash
python stable_baselines3_example.py \
  --env_path="./Project1/exports/Project_1.app" \
  --viz --speedup=1 --action_repeat=1 \
  --timesteps=1000 --save_model_path=flappy_export_test.zip
```

Python launches the export. Do not press F5.

Then train four headless instances:

```bash
python stable_baselines3_example.py \
  --env_path="./Project1/exports/Project_1.app" \
  --n_parallel=4 --speedup=8 --action_repeat=1 \
  --timesteps=100000 --save_model_path=flappy_parallel.zip
```

Omitting `--viz` makes exported training headless. Four games collect experience for one shared policy. Speed Up requests faster simulation; actual throughput depends on the machine.

For editor training, set Speed Up on Sync. For launched exports, use `--speedup`. Re-export after changing scenes or scripts: an existing app does not pick up editor changes.

We also discussed increasing Action Repeat to reduce decision frequency. At 60 simulation ticks per second, values 1, 2, and 4 give 60, 30, and 15 decisions per simulated second. This changes the control task and must match playback. **We did not adopt that change for the checkpoint comparison.**

## 19. Continue for a longer run

```bash
python stable_baselines3_example.py \
  --env_path="./Project1/exports/Project_1.app" \
  --resume_model_path=flappy_parallel.zip \
  --n_parallel=4 --speedup=8 --action_repeat=1 \
  --timesteps=1000000 \
  --experiment_name=flappy_long_run \
  --save_checkpoint_frequency=50000 \
  --save_model_path=flappy_long_run.zip
```

The requested million steps are collected across all instances, not a million per instance. The inspected saved model reported 573,044 total training steps; the requested budget does not establish how much training actually completed.

# Part V — The model got worse, and checkpoints helped

## 20. What happened

The user observed learning in earlier individual and parallel runs. After continuing training, `flappy_long_run.zip` floated upward and died.

We inspected the saved policy on several synthetic observations. It assigned essentially 100% probability to flap, even near the top while rising. This supported the observed behavior but did not identify its cause.

An initial hypothesis was that frequent flap opportunities made learning difficult. The user pointed out that the earlier model worked without setting changes. That made **training regression** a better explanation to investigate first. We kept the environment settings fixed and compared checkpoints instead of immediately changing the task.

## 21. Evaluate the selected checkpoint at normal speed

```bash
python stable_baselines3_example.py \
  --env_path="./Project1/exports/Project_1.app" \
  --resume_model_path="logs/sb3/flappy_long_run_checkpoints/flappy_long_run_200000_steps.zip" \
  --inference --viz --speedup=1 --action_repeat=1 \
  --n_parallel=1 --timesteps=10000
```

The long-run checkpoints were saved every 50,000 steps through 550,000. Their filename counters describe that training session, not necessarily the model’s cumulative lifetime training.

The user reported that **200,000 was “perfect” in playback**. Preserve it under a clear name:

```bash
cp logs/sb3/flappy_long_run_checkpoints/flappy_long_run_200000_steps.zip flappy_best.zip
```

This copy was suggested; its creation was not confirmed in the conversation. Once created, use `--resume_model_path=flappy_best.zip` for playback.

For stronger evaluation, repeat with different seeds, such as `--seed=1`, `--seed=2`, and `--seed=3`, and record survival time and pipes passed across several episodes. Multiple seeds were suggested but not yet reported as tested.

**Teaching takeaway: training produces candidates. Evaluation selects the model. The last checkpoint is not automatically the best.**

## What still needs verification

Before publishing a fully reproducible classroom implementation:

1. Audit episode reset/observation timing against the installed Python wrapper, including whether a first action gets discarded after death.
2. Verify behavior across multiple seeds and record performance rather than relying on one successful playback.
3. Keep the export, action-repeat setting, observation order, and model together so later tests use the same environment.
4. Pin the Godot/plugin/Python package versions and preserve the exact training script used.
5. If adding a time limit, explicitly report episode completion rather than silently resetting the game.

The reset concern is separate from the observed regression: no experiment in this conversation established a causal link.

## Corrections worth preserving in teaching material

- Use `get_obs()`, `get_action_space()`, `set_action()`, and `get_reward()`; initial method-name suggestions were inaccurate.
- Use the moving CharacterBody2D’s state, not the Bird parent’s stationary position.
- Return incremental reward since collection, not cumulative episode reward.
- Scene reloads are unsuitable for this layout because Sync is inside the reloaded scene. We chose in-place reset; other persistent-scene architectures are possible.
- The empty physics override belongs in the controller, not beside the existing bird movement function.
- ONNX deployment is optional and was not completed. Python inference already demonstrates the trained bird.
- An official Flappy Bird example was initially claimed without verification; this guide does not depend on one.
- More training did not guarantee a better result in our experiment.

## Reference material

- [Project scripts](Project1/sprites/): current implementation discussed here.
- [Training script](stable_baselines3_example.py): local command-line interface used for training and playback.
- [Godot RL custom environment guide](https://github.com/edbeeching/godot_rl_agents/blob/main/docs/CUSTOM_ENV.md): controller integration.
- [Stable Baselines3 training guide](https://github.com/edbeeching/godot_rl_agents/blob/main/docs/ADV_STABLE_BASELINES_3.md): training, inference, resume, and checkpoints.
- [Godot macOS export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html): app bundles, templates, signing, and notarization.

Online documentation may describe newer versions. Local source inspection was important in this journey, particularly for reward clearing, macOS executable naming, and resume behavior.
