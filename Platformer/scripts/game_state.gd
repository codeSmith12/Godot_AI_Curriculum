# Registered as the GameState autoload, so other scripts can access this shared node.
# It survives scene reloads, but its values are not saved after the game closes.
extends Node

# An event that carries the updated score to listeners such as ScoreLabel.
signal score_changed(new_score)

# Coins collected during the current run.
var score = 0
# Highest score from a completed run during this play session.
var best_score = 0

# World calls this when the goal is reached, so unfinished runs do not count.
func record_best_score():
	# Only replace the record when this run beats it.
	if score > best_score:
		# Keep the new record across Play Again scene reloads.
		best_score = score

# Coins call this shared function when the player collects them.
func add_coin():
	# Add one point. This is shorthand for score = score + 1.
	score += 1
	# Notify connected listeners and pass them the current score.
	score_changed.emit(score)


# Start a fresh run without clearing best_score.
func reset_score():
	# Reset only the current run's coin count.
	score = 0
	# Notify connected listeners and pass them the current score.
	score_changed.emit(score)
