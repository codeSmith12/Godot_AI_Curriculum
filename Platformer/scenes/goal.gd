# Detect the player reaching the goal without making the goal a solid wall.
extends Area2D

# Our own event: World listens for this signal to display the win panel.
signal reached

# Remember whether this goal has already been reached during this run.
var activated = false


# The editor-connected body_entered signal supplies the body that touched the goal.
func _on_body_entered(body: Node2D):
	# Both conditions must pass: this is the player, and the goal has not fired yet.
	if body.is_in_group("player") and not activated:
		# Mark the goal as used before announcing the win, so it cannot fire twice.
		activated = true
		# Emit our custom signal; World handles the score display and pausing.
		reached.emit()
		# Show a debugging message in Godot's Output panel.
		print("Goal reached!")
