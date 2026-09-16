extends Node2D

# Get a reference to the CharacterBody2D child node
# (Replace "CharacterBody2D" with the exact name of your node if it's different)
@onready var bird: CharacterBody2D = $CharacterBody2D
@onready var ai_controller = $AIController2D
@onready var starting_position: Vector2 = bird.position

@export var jump_velocity = 100

var dead := false
# Get the project's default gravity value
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	ai_controller.init(self)



func _physics_process(delta: float) -> void:
	
	if ai_controller.needs_reset:
		if ai_controller.heuristic == "human" or not ai_controller.done:
			get_parent().reset_game()
		return

	if dead:
		return

	ai_controller.reward += 0.1 * delta
	
	
	# Use 'character.' to apply gravity to the child node
	if not bird.is_on_floor():
		bird.velocity.y += gravity * delta
	
	var should_flap := false

	if ai_controller.heuristic == "human":
		should_flap = Input.is_action_just_pressed("ui_accept")
	else:
		should_flap = ai_controller.flap_requested

	ai_controller.flap_requested = false

	if should_flap:
		bird.velocity.y = -jump_velocity	
	
	# 2. Jump input (Checks for spacebar, mouse click, or screen tap by default)
	#if Input.is_action_just_pressed("ui_accept"):
		#bird.velocity.y = -jump_velocity
		
	

	var collided = bird.move_and_slide()

	if collided or bird.global_position.y < 0.0 or bird.global_position.y > 650.0:
		die()

func die() -> void:
	if dead:
		return

	dead = true
	bird.velocity = Vector2.ZERO
	ai_controller.flap_requested = false
	ai_controller.reward -= 1.0
	ai_controller.done = true
	ai_controller.needs_reset = true

	get_parent().stop_game()

func reset_bird() -> void:
	bird.position = starting_position
	bird.velocity = Vector2.ZERO
	dead = false

	ai_controller.reset()
	ai_controller.done = false
	ai_controller.reward = 0.0
	ai_controller.flap_requested = false
