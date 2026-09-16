extends AIController2D

const PLAY_WIDTH := 1150.0
const PLAY_HEIGHT := 650.0
const FLAP_SPEED := 400.0

var flap_requested := false

# Your moving body is a sibling of this controller.
@onready var bird: CharacterBody2D = $"../CharacterBody2D"

func _physics_process(_delta: float) -> void:
	pass

# The overlay and policy share this exact target-selection function.
func observation_snapshot() -> Dictionary:
	var gap_offset := Vector2(PLAY_WIDTH, 0.0)
	var target: Marker2D = null
	var nearest_distance := INF
	for pipe in get_tree().get_nodes_in_group("pipes"):
		var marker: Marker2D = pipe.get_node("GapCenter")
		var offset := marker.global_position - bird.global_position
		if offset.x < -85.0:
			continue
		if offset.x < nearest_distance:
			nearest_distance = offset.x
			gap_offset = offset
			target = marker
	return {"target": target, "offset": gap_offset, "obs": [
		bird.global_position.y / PLAY_HEIGHT,
		bird.velocity.y / FLAP_SPEED,
		gap_offset.x / PLAY_WIDTH,
		gap_offset.y / PLAY_HEIGHT,
	]}

func get_obs() -> Dictionary:
	return {"obs": observation_snapshot().obs}

# To flap or not to flap! 0 == do nothing, 1 == flap
# "size": 2 means there are 2 choices
func get_action_space() -> Dictionary:
	return {
		"flap": {
			"size": 2,
			"action_type": "discrete",
		}
	}
	
#The plugin calls set_action() when an action arrives from Python. The controller stores whether the bird should flap.
#The name "flap" must match the name in get_action_space().
func set_action(action) -> void:
	flap_requested = action["flap"] == 1
	
func get_reward() -> float:
	return reward
