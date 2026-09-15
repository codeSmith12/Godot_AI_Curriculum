extends Node2D

var score: int=0
const PIPE = preload("uid://4ey5u1xjnomg")


func increment_score() -> void:
	score += 1
	$ScoreLabel.text = str(score)


func _on_timer_timeout() -> void:
	increment_score()
	
func spawn_pipe_timeout() -> void:
	# Instantiate the pipe scene
	var pipe_instance = PIPE.instantiate()
	
	# Set its starting position (e.g., right side of the screen)
	pipe_instance.position.x = 1200 
	
	# Optional: Also give it a random vertical height for gameplay variety
	pipe_instance.position.y = randf_range(300.0, 500.0)
	
	# Add it to the scene tree
	add_child(pipe_instance)
	$PipeTimer.start(randf_range(1.3,1.75))
