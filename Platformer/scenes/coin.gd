# An Area2D detects overlaps; it does not physically block the player.
extends Area2D


# Connected to body_entered in the editor. body is the object that entered.
# Node2D describes the argument type; -> void means this function returns no value.
func _on_body_entered(body: Node2D) -> void:
	# Only collect the coin when the entering body belongs to our player group.
	if body.is_in_group("player"):
		# Ask the shared GameState to add a point and announce the new score.
		GameState.add_coin()
		# Remove this coin safely at the end of the frame.
		queue_free()
