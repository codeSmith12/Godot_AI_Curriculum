# Inherit character movement tools such as velocity, is_on_floor(), and move_and_slide().
extends CharacterBody2D

# Horizontal speed in pixels per second; @export exposes it in the Inspector.
@export var speed = 250.0
# An upward launch speed. Negative Y points up; more negative means a higher jump.
@export var jump_velocity = -400.0
# Downward acceleration in pixels per second squared.
var gravity = 980.0

# A Vector2 stores x and y. We will remember the spawn point in world coordinates.
var start_position: Vector2
# Track whether the available airborne jump has been used.
var doubleJump = false


# Godot calls this every physics tick. delta is the elapsed time in seconds.
func _physics_process(delta):
	# Read floor contact from the most recent move_and_slide() call.
	if not is_on_floor():
		# While airborne, increase downward speed according to the time elapsed.
		velocity.y += gravity * delta

	# Read built-in input actions: left = -1, right = 1, neither (or both) = 0.
	var direction = Input.get_axis("ui_left", "ui_right")
	# Set horizontal speed immediately; releasing the keys stops horizontal motion.
	velocity.x = direction * speed

	# Jump on a fresh button press if grounded OR the airborne jump is still available.
	# ui_accept includes Space. The parentheses group the two ways jumping is allowed.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or not doubleJump):
		# Replace vertical speed with an upward launch, even if we were falling.
		velocity.y = jump_velocity
		# Mark the jump as used. The floor check below clears this again on a ground jump.
		doubleJump = true
		
	# This still reads the previous move_and_slide() result, before this tick's movement.
	if is_on_floor():
		# Restore the airborne jump while grounded. Walking off a ledge also leaves it available.
		doubleJump = false
	
		
	# Move using velocity, resolve solid collisions, and update floor/wall/ceiling contact.
	# This method handles the physics timestep internally; do not multiply velocity by delta.
	move_and_slide()

	# Positive Y points down. Below this world-space boundary, the player has fallen off.
	if global_position.y > 900:
			# Return to the saved starting point instead of reloading the whole level.
			respawn()
# Called once when this player is ready in World, before normal physics updates.
func _ready():
	# Remember where this player instance was placed in the level.
	start_position = global_position

# Shared by falling recovery and hazards that touch the player.
func respawn():
	# Teleport back to the saved world-space spawn point.
	global_position = start_position
	# Clear horizontal and vertical speed so the player does not keep falling.
	# This function leaves the score, coins, and doubleJump flag unchanged.
	velocity = Vector2.ZERO
