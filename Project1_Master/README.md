# Flappy Bird — Observation Lab

A self-contained classroom demo copied from `Project1`. The student project is unchanged.

## Run the demo

1. Import **this folder's `project.godot`** into Godot (the source project targets 4.6; this demo was also tested with the locally available 4.4).
2. Press **F5**. The selected agent plays immediately at normal speed.
3. Pause to explain the scene, switch to human control to try the same task, or enable slow motion.

**No Python process, export, or ONNX installation is needed for this demo.** The selected saved policy's weights are stored in `agents/best_policy.json` and evaluated directly by GDScript. This is the learned neural network, not a scripted autopilot. The original `agents/flappy_bird_BestAgent.zip` remains included.

## What students see

| Visual | Meaning |
|---|---|
| Cyan ring and arrow | The controller's selected GapCenter |
| Gold dashed horizontal line | Distance from bird to selected target |
| Pink dashed vertical line | Relative gap offset |
| Green ruler | Bird height measured from the top of the play area |
| Cyan ruler | Absolute gap height, an explanatory guide rather than a separate policy input |
| White up/down arrow | Bird vertical velocity; length is visually capped for readability |
| Gold expanding ring | A flap was actually applied |
| Episode-end banner | Death event and −1 reward |
| Bottom observation strip | The four scaled values returned by `get_obs()` |
| Probability bar | Flap probability at the most recent local policy decision |

The policy and overlay share `bird_controller.observation_snapshot()`. The overlay displays live state; the probability bar describes the last decision, just before that physics step moved the bird. The target selection and four input definitions match the student project. The extra gap-height ruler is explicitly marked with an asterisk because the policy receives relative offset instead.

## Controls

- **Tab / pilot button:** switch between the saved AI and human control; starts a fresh episode.
- **Space:** flap in human mode.
- **P / Pause:** freeze gameplay while keeping the teaching panel usable.
- **Slow motion:** toggle between normal speed and 0.25×.
- **R / Restart:** begin a fresh episode.
- **O / Observation overlay:** show/hide drawings; observation values remain visible.
- Individual switches isolate geometry, rulers, and velocity.

Selecting buttons does not consume Space through UI focus. Restarting and switching pilots keep the current pause/slow-motion selection.

## How it is organized

```text
Project1_Master/
  project.godot
  sprites/                 Game, controller, and scenes
  demo/
    observation_lab.gd     Visuals and classroom controls
    local_policy.gd        Deterministic neural-network forward pass
  agents/
    flappy_bird_BestAgent.zip
    best_policy.json       Runtime weights + reference predictions
    export_policy.py       Regenerate weights from the selected zip
  addons/                  Godot RL Agents plugin
  stable_baselines3_example.py
  JOURNEY.md               Historical walkthrough (paths describe the original layout)
  tests/
```

This copy excludes exported builds, logs, Python environments, and generated Godot caches. Its `.gitignore` keeps those excluded if generated later. Source UIDs and import metadata remain included.

## Using a different trained model

In a Python environment with `godot-rl[sb3]` installed, replace `agents/flappy_bird_BestAgent.zip` with the chosen model and run from this folder:

```bash
python agents/export_policy.py
```

Then restart Godot playback. The exporter is intentionally specific to our four-observation, two-action policy with two 64-unit tanh layers. A different architecture needs a matching exporter/runtime. Changing only the zip does not update the runtime JSON.

The current weights were checked against 32 predictions from the saved SB3 policy. Maximum probability difference was approximately **6.7 × 10⁻⁸**.

## Optional Python connection

Normal F5 launches the standalone demonstration with Sync in Human mode. The bird uses the local policy unless Human is selected in the panel.

To use the Python trainer instead, start the included script without `--env_path`, then launch Godot with the user argument `--train`:

```bash
python stable_baselines3_example.py --timesteps=10000 --save_model_path=flappy_master.zip
```

In another terminal (macOS example):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path . -- --train
```

That startup flag switches Sync to Training and disables the local pilot. Pilot switching, pause, slow motion, and restart are blocked during external training, so classroom controls do not interfere with the trainer. This external route retains the student project's reset behavior and its documented reset-timing caveat; the standalone demo does not depend on that socket handshake.

For a classroom session, use the standalone mode above. Python training in this master copy has not been run end-to-end as part of this change.

## Exporting the classroom demo

Create an export preset for this new project. Keep the **`agents/best_policy.json`** file in the export: in the preset's Resources tab, add `agents/*.json` to the non-resource file inclusion filter. Standard scenes, scripts, textures and addon resources should be exported normally. Do not launch with `--train` for the standalone demo.

The Python zip is for retraining/exporting weights; it is not loaded during Godot gameplay. An export of the master demo has not been validated yet.

## Checks

From this folder, substituting your Godot executable as needed:

```bash
Godot --headless --path . --script res://tests/policy_check.gd
Godot --headless --path . --script res://tests/demo_check.gd
```

The first compares GDScript against saved Python predictions. The second checks target selection, paused movement, slow motion, switching pilots, death/reset, and overlay toggles. Running the second with a graphical display also writes `/tmp/flappy-master.png` for visual inspection.
