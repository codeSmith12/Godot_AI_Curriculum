extends AnimatableBody2D

@export var rotation_speed = 90.0


func _physics_process(delta):
	rotation_degrees += rotation_speed * delta
