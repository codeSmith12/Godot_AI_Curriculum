extends Area2D

@onready var pipe: Area2D = $"."
@export var speed = 300
 
func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	
	if position.x < -200:
		print("deleting pipe")
		queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	var bird_root = body.get_parent()

	if bird_root.has_method("die"):
		bird_root.die()
