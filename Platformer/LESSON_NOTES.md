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
