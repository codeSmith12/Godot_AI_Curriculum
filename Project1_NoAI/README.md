# Flappy Bird — No AI

The original human-playable game for the first sessions of the course, before reinforcement learning is introduced.

Restored from Git commit **`cbc7409`**, “Made the clone of flappy bird. Pushing before starting AI work.” All original scenes, scripts, and assets are preserved. Only the project display name was changed, and this README was added.

## Run

1. Import this folder's **project.godot** in Godot (the original project targets Godot 4.6).
2. Press **F5**.
3. Press **Space** to flap (`ui_accept`; Enter also works with the default input map).
4. Colliding with a pipe reloads the scene and starts over.

No plugins, Python packages, AI models, or external projects are required. This folder can be copied on its own.

## Teaching sequence

1. **Bird scene:** sprite, circle collision shape, and CharacterBody2D.
2. **Movement:** gravity, vertical velocity, keyboard input, and `move_and_slide()`.
3. **Pipe scene:** upper/lower obstacles and Area2D collision detection.
4. **World scene:** instantiate pipes, randomize their height, and use a timer to spawn more.
5. **Game loop:** update the score, delete off-screen pipes, and reload after collision.

| File | Responsibility |
|---|---|
| `sprites/bird.gd` | Gravity and flapping; moves the CharacterBody2D child |
| `sprites/pipe.gd` | Scrolls pipes left, removes old pipes, and handles pipe collisions |
| `sprites/world.gd` | Spawns pipes and updates the score |
| Corresponding `.tscn` files | Node structure, appearance, and collision shapes |

## Original behavior intentionally preserved

- Score counts elapsed timer ticks, **not pipes passed**.
- Pipe spawn intervals range from 1 to 2 seconds.
- The bird scene overrides the script's default flap speed to 400.
- There is no top/bottom screen-exit death check. If the bird leaves the play area without hitting a pipe, stop and rerun the game.
- Death uses scene reloads. The later AI projects replace this with episode/reset handling.

These are useful extension exercises after students recreate the basic game.

## Course projects

- **Project1_NoAI:** original game, for the first lessons.
- **Project1:** game with Godot RL Agents integration and training materials.
- **Project1_Master:** instructor demo with a learned pilot and visual observations.
