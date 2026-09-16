extends RefCounted
## Deterministic forward pass of the saved SB3 policy (not a hand-coded pilot).
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://agents/best_policy.json"))

func probabilities(observations: Array) -> Array:
	var values: Array = observations.duplicate()
	for layer in data.layers:
		var result: Array = []
		for row in range(layer.bias.size()):
			var value: float = layer.bias[row]
			for column in range(values.size()):
				value += layer.weights[row][column] * values[column]
			result.append(tanh(value) if layer.activation == "tanh" else value)
		values = result
	var maximum: float = max(values[0], values[1])
	var a := exp(values[0] - maximum)
	var b := exp(values[1] - maximum)
	return [a / (a + b), b / (a + b)]
