# This hazard detects contact and respawns the player; it is not a solid block.
extends Area2D

# @export makes this setting editable per instance in the Inspector.
# With a unit-length direction, speed is measured in pixels per second.
@export var speed = 80.0
# Vector2 holds x and y. RIGHT is (1, 0); UP is (0, -1).
# Use these unit directions to choose horizontal or vertical motion.
@export var direction = Vector2.RIGHT


# Godot calls this each physics tick. delta is the elapsed time in seconds.
func _physics_process(delta):
	# Convert speed into distance for this tick and add it to our local position.
	position += direction * speed * delta


# Connected to the repeating FlipTimer's timeout signal in the editor.
func _on_flip_timer_timeout():
	# Reverse both direction components so the hazard travels back the other way.
	direction *= -1


# Connected to this Area2D's body_entered signal in the editor.
func _on_body_entered(body: Node2D):
	# Ignore bodies that are not members of the player group.
	if body.is_in_group("player"):
		# Call the player's respawn function; collected coins and score stay unchanged.
		body.respawn()
