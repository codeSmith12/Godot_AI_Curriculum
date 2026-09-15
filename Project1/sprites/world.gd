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


func stop_game() -> void:
	$ScoreTimer.stop()
	$PipeTimer.stop()

	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.set_physics_process(false)

func reset_game() -> void:
	for pipe in get_tree().get_nodes_in_group("pipes"):
		remove_child(pipe)
		pipe.queue_free()

	score = 0
	$ScoreLabel.text = "0"

	$Bird.reset_bird()
	spawn_pipe_timeout()
	$ScoreTimer.start()
