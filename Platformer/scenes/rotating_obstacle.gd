# This is the solid rotating variant: contact blocks or pushes rather than respawning.
# Keep Sync to Physics enabled in the Inspector.
extends AnimatableBody2D

# Degrees per second, editable in the Inspector. 90 makes a full turn in 4 seconds.
# A negative value reverses the spin.
@export var rotation_speed = 90.0


# Godot calls this each physics tick, supplying elapsed seconds as delta.
func _physics_process(delta):
	# Add this tick's rotation. The sprite and collision shape rotate with their parent.
	# The root origin is the pivot; offsetting both children changes the sweep.
	rotation_degrees += rotation_speed * delta
