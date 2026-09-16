extends CharacterBody2D

@export var speed = 250.0
@export var jump_velocity = -400.0
var gravity = 980.0


func _physics_process(delta):
	# Fall faster over time.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Left gives -1, right gives 1, neither gives 0.
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Jump only while standing on the floor.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
