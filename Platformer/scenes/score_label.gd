extends Label


func _ready():
	GameState.score_changed.connect(update_score)
	GameState.reset_score()

func update_score(new_score):
	text = "Score: " + str(new_score)
