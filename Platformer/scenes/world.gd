# World coordinates the level's win screen and restart behavior.
extends Node2D

# Called when World and its children are ready at the start of each run.
func _ready():
	# $ follows a node path from World. Hide the panel until the player wins.
	$UILayer/WinPanel.hide()


# Connected in the editor to the Goal instance's custom reached signal.
func _on_goal_reached():
	# Update the session record before displaying the results.
	GameState.record_best_score()

	# Build the results text. Parentheses let this expression span several lines.
	# Each \n starts a new line; str() converts a score number to text.
	$UILayer/WinPanel/WinLabel.text = (
        "You Win!"
		+ "\nScore: " + str(GameState.score)
		+ "\nBest: " + str(GameState.best_score)
	)

	# Display the results panel on the UI layer.
	$UILayer/WinPanel.show()
	# Pause gameplay, including player movement, obstacle movement, and timers.
	# WinPanel uses Process Mode Always so its restart button remains responsive.
	get_tree().paused = true


# Connected to RestartButton's pressed signal. void means no return value.
func _on_restart_button_pressed() -> void:
	# Clear the pause before reloading; a scene reload does not clear it for us.
	get_tree().paused = false
	# Recreate World, restoring the player, coins, obstacles, and goal.
	# ScoreLabel resets the run score; the GameState autoload keeps the session best.
	get_tree().reload_current_scene()
