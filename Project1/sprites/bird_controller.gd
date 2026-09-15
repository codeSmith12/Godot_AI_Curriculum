extends AIController2D

const PLAY_WIDTH := 1150.0
const PLAY_HEIGHT := 650.0
const FLAP_SPEED := 400.0

# Your moving body is a sibling of this controller.
@onready var bird: CharacterBody2D = $"../CharacterBody2D"


func get_obs() -> Dictionary:
	# Default Target when there are no pipes
	var gap_offset := Vector2(PLAY_WIDTH, 0,0)
	var nearest_distance := INF
	
	# Get each pipe in the game from the group
	for pipe in get_tree().get_nodes_in_group("pipes"):
		# Grab the marker node
		var marker: Marker2D = pipe.get_node("GapCenter")
		var offset: Vector2 = marker.global_position - bird.global_position
		
		# Keep observing this pipe until the bird clears it.
		# About 85 pixels covers your pipe half-width + bird radius.
		if offset.x < -85.0:
			continue
		
