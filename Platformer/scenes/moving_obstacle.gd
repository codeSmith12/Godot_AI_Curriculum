# A moving solid body: it blocks or pushes the player instead of detecting overlaps.
# Keep Sync to Physics enabled in the Inspector.
extends AnimatableBody2D

# Inspector setting: pixels per second when direction has a length of one.
@export var speed = 60.0
# Start upward: UP is (0, -1), because negative Y points up in Godot.
@export var direction = Vector2.UP


# Update movement every physics tick; delta is the tick duration in seconds.
func _physics_process(delta):
	# Move the body and its children together. The physics body handles solid contact.
	position += direction * speed * delta


# The repeating Timer calls this through its editor-connected timeout signal.
func _on_flip_timer_timeout():
	# Reverse travel. Distance per leg is speed multiplied by the timer duration.
	direction *= -1
