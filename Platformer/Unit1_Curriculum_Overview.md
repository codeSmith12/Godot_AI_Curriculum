# Unit 1: Introduction to Game Development with Godot

**Audience:** Students approximately age 13 with some prior Python experience; no prior Godot experience required.  
**Duration:** Five 60-minute lessons, followed by additional independent project time.  
**Tools:** Godot 4.6 and GDScript.  
**Culminating product:** A playable 2D platformer with movement, collectibles, obstacles, a goal, and a replay loop.

## Unit purpose

Students apply familiar programming ideas—variables, functions, and conditionals—to an interactive game. Through a guided platformer project, they learn how a game engine organizes objects, updates movement, detects interactions, and displays information to the player.

Each lesson adds a working feature to the same project. Students predict the effect of changes, test their ideas, and revise their designs. The finished game provides a foundation for an independent extension or an original game using the same concepts.

## Learning outcomes

By the end of the unit, students should be able to:

- Navigate Godot's editor and organize a project using nodes, scenes, and reusable scene instances.
- Explain the different roles of an object's appearance, collision shape, and behavior.
- Read and modify short GDScript programs for input, movement, gravity, and jumping.
- Use signals—events that trigger connected functions—to respond to interactions.
- Create and display a score, and distinguish a current-run value from a session record.
- Design a navigable level with collectibles, obstacles, and a clear endpoint.
- Playtest, diagnose simple problems, and explain how a change affects the player's experience.

## Lesson sequence

### Lesson 1 — Build a Moving Character

**Guiding question:** How do we turn code and visual objects into a controllable character?

Students explore the editor, create a World scene, and build a separate Player scene. They combine a visible sprite with a collision shape, add a solid floor, and write movement code for walking, gravity, and jumping. They place an instance of Player inside World and test the result.

**Key concepts:** Nodes and scenes; parent/child relationships; the Inspector; scene instancing; input; velocity; repeated physics updates; floor detection.

**Student experimentation:** Predict and test how movement speed and jump strength change the character's behavior.

**Evidence of learning:** The player moves, jumps, and lands reliably. Students can explain why the sprite and collision shape have separate jobs. The core version permits jumping from the floor; double jumping is an extension.

### Lesson 2 — Design a Level

**Guiding question:** What makes a platforming course navigable and interesting?

Students turn a platform into a reusable scene and arrange instances into a short jumping course. They add a camera that follows the player. Polygon terrain introduces ramps and irregular shapes; students copy the visual polygon's points into its collision polygon to keep the boundaries aligned.

**Key concepts:** Reuse; coordinates and placement; camera behavior; visual and physical boundaries; level design through iteration.

**Student experimentation:** Adjust gaps, heights, and terrain shapes, then test whether the route remains achievable.

**Evidence of learning:** A short course has reachable platforms, a following camera, and correctly aligned terrain collisions. Students can explain the benefit of reusing scenes.

### Lesson 3 — Collect Coins and Track Score

**Guiding question:** How does the game respond to an interaction and communicate the result?

Students create a reusable coin that detects the player entering its area. Collecting a coin removes it and increases a shared score. A custom signal updates a label on a screen-fixed UI layer. Students use a player group to identify which objects should trigger collection.

**Key concepts:** Overlap detection; signals and event-driven programming; groups; shared game state; updating UI text.

**Student experimentation:** Place coins to guide the player along a route or reward a more difficult jump.

**Evidence of learning:** Each coin adds one point and disappears. The score remains visible while the camera moves. Students can trace the sequence from touching a coin to updating the display.

### Lesson 4 — Create Obstacles and Recover from Mistakes

**Guiding question:** How can different obstacle behaviors create different challenges?

Students add a reusable respawn function, first for falling off the level and then for touching hazards. They build horizontal and vertical patrols using a timer, expose movement settings in the Inspector, and compare contact hazards with solid barriers. A rising gate and a rotating obstacle extend the movement patterns.

| Obstacle | Behavior | Learning focus |
|---|---|---|
| Horizontal or vertical hazard | Reverses direction on a timer; contact respawns the player | Direction vectors, timing, and overlap events |
| Solid block / rising gate | Physically blocks the player; can move up and down | Solid collision versus contact detection |
| Rotating obstacle | Turns continuously around a pivot; can be a contact hazard or solid block | Angular speed and parent/child transforms |

**Key concepts:** Reusable functions; timers; exported variables; movement direction; rotation; choosing an appropriate physics node.

**Student experimentation:** Change speed, direction, or timer duration and predict the effect. Compare clockwise and counterclockwise rotation. Changing the rotation pivot is an extension.

**Evidence of learning:** The player recovers from falls and hazard contact without losing collected coins. Students distinguish a detection area from a solid body and create an obstacle section that can be navigated. Rotating variants can be demonstrated or offered as extensions if setup takes longer than expected.

### Lesson 5 — Finish and Replay the Game

**Guiding question:** What makes a collection of mechanics feel like a complete game?

Students add a goal that triggers a win panel with the final score. They pause gameplay while keeping the UI responsive, connect a Play Again button, and reload the level for a fresh run. A session best score remains available across level restarts.

**Key concepts:** Game state transitions; UI buttons and signals; pausing; scene reloads; the lifetime of shared data.

**Student experimentation:** Playtest the complete experience and improve goal placement, difficulty, or clarity of feedback.

**Evidence of learning:** The game can be completed and replayed. Restarting restores coins and resets the current score while retaining the session best. Students understand that the session record is cleared when the application closes; saving to disk is an extension.

## Instructional approach and pacing

Lessons combine brief demonstrations, guided building, and frequent playable checkpoints. A typical hour allocates approximately 10 minutes to introduction or review, 30 minutes to guided construction, 15 minutes to experimentation and debugging, and 5 minutes to reflection. The balance can shift as students become more independent.

Prior Python knowledge supports the transition to GDScript, while explicit instruction addresses unfamiliar engine concepts: scene structure, automatic update functions, signals, and collisions. Simple placeholder art keeps early work focused on behavior. Commented scripts support code reading, and optional challenges give faster-moving students room to extend their work.

The five-hour schedule is a planning target to confirm through classroom delivery. Lesson 4 has the broadest range of features; additional rotating variants and pivot experiments provide flexible extension content. Independent project time is additional to the five guided lessons.

## Assessment

Assessment combines working features with students' explanations of their decisions.

- **During each lesson:** Check the playable milestone, ask students to predict a code change, and have them explain the result after testing.
- **At the end of the guided unit:** Review the complete play–collect–avoid–finish–replay loop and ask students to trace one interaction through its code.
- **During independent work:** Look for purposeful modifications, evidence of testing and revision, and the ability to explain how a feature works.

Success emphasizes functional understanding and iteration rather than artistic polish or the number of features added.

## Independent extension

After the guided unit, students use their platformer as a starting point for a personal project. They may design a new course, change the visual theme, create new obstacle arrangements, or add a mechanic such as double jumping or moving platforms. Students ready for more complexity can investigate persistent saving, additional levels, or animation.

A suggested project submission includes a playable game, a short description of the student's changes, and a reflection on one problem they solved through testing. The amount of independent work can be scaled to the time available.

## Preparation and scope

- Provide computers with Godot 4.6 installed and a consistent project-saving workflow.
- Prepare a working reference project and lesson checkpoints to help students recover from setup or coding difficulties.
- Use built-in shapes and placeholder textures initially; a separate art package is not required.
- Keep advanced movement polish, tile-based level tools, complex animation systems, and saving to disk outside the core requirements.

The unit provides an introductory foundation in game development, with a completed project students can understand, modify, and build upon.
