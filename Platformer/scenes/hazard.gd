extends Area2D

@export var speed = 80.0
@export var direction = Vector2.RIGHT


func _physics_process(delta):
	position += direction * speed * delta


func _on_flip_timer_timeout():
	direction *= -1


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.respawn()
