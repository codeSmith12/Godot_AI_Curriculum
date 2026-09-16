extends Node2D

# Get a reference to the CharacterBody2D child node
# (Replace "CharacterBody2D" with the exact name of your node if it's different)
@onready var bird: CharacterBody2D = $CharacterBody2D
@export var jump_velocity = 100
# Get the project's default gravity value
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Use 'character.' to apply gravity to the child node
	if not bird.is_on_floor():
		bird.velocity.y += gravity * delta
		
	# 2. Jump input (Checks for spacebar, mouse click, or screen tap by default)
	if Input.is_action_just_pressed("ui_accept"):
		bird.velocity.y = -jump_velocity
		

	# Call move_and_slide on the child node to move it
	# Move the bird and check for collisions
	var collided = bird.move_and_slide()
	
	# Check the birds height, return true of the bird is out of bounds
	var outside_play_area = (
		bird.global_position.y < 0.0
		or bird.global_position.y > 650.0
	)

	if collided or outside_play_area:
		# Wipes the current scene out of memory and loads it completely fresh
		get_tree().reload_current_scene()
