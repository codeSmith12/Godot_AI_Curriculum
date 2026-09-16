extends AnimatableBody2D

@export var speed = 60.0
@export var direction = Vector2.UP


func _physics_process(delta):
	position += direction * speed * delta


func _on_flip_timer_timeout():
	direction *= -1
