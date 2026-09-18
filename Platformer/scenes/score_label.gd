# This script controls the text of the on-screen ScoreLabel.
extends Label


# Run once when this label is ready in the scene, including after a level reload.
func _ready():
	# Connect through code: whenever the score changes, call update_score.
	# Pass the function itself (no parentheses), so it can be called later.
	GameState.score_changed.connect(update_score)
	# Start this run at zero. Resetting emits the signal, which refreshes this label.
	GameState.reset_score()

# The score_changed signal supplies the new score as this argument.
func update_score(new_score):
	# Convert the number to a string and join it to the caption.
	# The parent CanvasLayer keeps this label in screen space while the camera moves.
	text = "Score: " + str(new_score)
