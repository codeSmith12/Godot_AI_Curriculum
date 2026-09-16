extends Node

signal score_changed(new_score)

var score = 0

func add_coin():
	score += 1
	score_changed.emit(score)


func reset_score():
	score = 0
	score_changed.emit(score)
