extends SceneTree
func _initialize() -> void:
	var policy = preload("res://demo/local_policy.gd").new()
	var maximum_error := 0.0
	for fixture in policy.data.fixtures:
		var actual: Array = policy.probabilities(fixture.obs)
		for i in range(2):
			maximum_error = maxf(maximum_error, absf(actual[i] - fixture.probabilities[i]))
	print("32 policy fixtures: maximum probability error = ", maximum_error)
	quit(0 if maximum_error < 0.00001 else 1)
