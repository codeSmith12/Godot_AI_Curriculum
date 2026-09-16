# Platformer unit — teaching notes

Audience: students around age 13 with some Python experience. Five lessons of one hour each, followed by time to extend the game independently.

## Lesson 1 — Move and jump

Introduce the Scene tree, FileSystem, Inspector, and viewport. Create World and a separate Player scene; instance Player into World. Build a floor and attach the player movement script.

- Player: CharacterBody2D with Sprite2D and CollisionShape2D children.
- Floor: StaticBody2D with Sprite2D and CollisionShape2D children.
- Explain horizontal input, velocity, gravity, delta, negative Y for jumping, is_on_floor(), and move_and_slide().
- Experiment: predict and test changes to speed and jump velocity.
- Checkpoint: walk, jump, land, and prevent jumping again while airborne.

Lesson 1 ends here. Reusable platforms and level design begin Lesson 2.

## Lesson 2 — Level design and camera

Save the floor branch as a reusable platform scene. Place platform instances to build a jumpable course. Keep physics node scales at (1, 1); resize the texture and collision shape together. When changing one instance's resources independently, enable Editable Children and make its texture and shape unique first.

Add Camera2D as a child of Player so it follows without additional code. Playtest gaps and heights with the actual movement settings.

### Polygon terrain

Introduce polygon terrain after the rectangular platforms. Use a StaticBody2D with sibling Polygon2D and CollisionPolygon2D children. Draw a gentle ramp or irregular terrain with Polygon2D.

**Copy the points instead of tracing the collision outline manually:**

1. Select Polygon2D and find its Polygon property in the Inspector (search for Polygon if needed).
2. Right-click the Polygon property name and choose Copy Value.
3. Select CollisionPolygon2D.
4. Right-click its Polygon property name and choose Paste Value.
5. Keep both nodes at position (0, 0), rotation 0, and scale (1, 1), with Polygon2D's Offset at (0, 0), so the outlines match.
6. Leave CollisionPolygon2D's Build Mode set to Solids.

The copied points are not linked. After editing the visual polygon, copy and paste its Polygon value again to update the collision boundary.

Playtest landing on the terrain and walking up the slope. Use Debug > Visible Collision Shapes to inspect alignment if necessary.

### Lesson 2 checkpoint

- A short course with reachable platforms and gaps.
- A camera that follows the player.
- Polygon terrain with a matching collision boundary, if this extension is included.
- Students can explain scene reuse and the separate jobs of visual and collision nodes.

Use remaining time to design and playtest a short course. Stop and rerun after falling for now; respawning is planned for Lesson 4.

Next: Lesson 3 introduces coins, Area2D overlap detection, signals, score, and a UI label.


## Lesson 4 — Expanded obstacle behaviors

See [the build plan](Unit1_Platformer_Build_Plan.md#lesson-4--obstacle-behavior--respawning) for the full sequence and one-hour pacing.

- Falling recovery: store the starting position, then reuse `respawn()` for falls and hazard contact. Clear velocity; preserve collected coins and score.
- Horizontal and vertical hazards: Area2D, exported speed and Vector2 direction, repeating Timer that reverses direction.
- Solid barrier and rising gate: AnimatableBody2D with Sync to Physics enabled. First test stationary collision, then add vertical movement and a reversal Timer.
- Rotating hazard: Area2D with a rectangular bar; update `rotation_degrees` each physics tick. No Timer required.
- Rotating solid variant: AnimatableBody2D with the same rotation pattern, without an Area2D contact signal or respawn handler.
- Pivot experiment: move both the sprite and collision shape away from the root origin to rotate around one end.

Explicitly teach that an Area2D detects overlap but does not physically block the player. A collision shape alone does not determine whether an object is solid; the parent node type matters.

Playtest contact from both sides, jumping past hazards, falling recovery, score preservation, the gate opening, and rotation. Keep the spawn clear. Use the solid rotating variant and pivot experiment as extensions if the one-hour lesson is full.
