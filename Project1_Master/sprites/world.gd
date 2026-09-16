extends Node2D

var score: int=0
const PIPE = preload("res://sprites/pipe.tscn")


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

	episodes += 1
	elapsed = 0.0
	episode_reward = 0.0
	score = 0
	$ScoreLabel.text = "0"

	$Bird.reset_bird()
	spawn_pipe_timeout()
	$ScoreTimer.start()

var demo_ai := true
var episodes := 1
var elapsed := 0.0
var episode_reward := 0.0
var last_probabilities: Array = [0.5, 0.5]
var external_training := false
var policy = preload("res://demo/local_policy.gd").new()

func _ready() -> void:
	external_training = "--train" in OS.get_cmdline_user_args()
	if external_training:
		$Sync.control_mode = 1
	$ScoreLabel.hide()

func _physics_process(delta: float) -> void:
	if not $Bird.dead:
		elapsed += delta
		episode_reward += 0.1 * delta
