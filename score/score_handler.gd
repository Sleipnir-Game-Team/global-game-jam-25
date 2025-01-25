extends Node

@export var turning_point: int

var score_dict := {}

func score_calculation(classification: String, total_qnt: int, taste_flag: bool) -> void:
	classification = classification.to_lower()
	
	var total_score := 0.0
	
	if not taste_flag:
		turning_point = 0
	
	if total_qnt < turning_point:
		total_score = 0
	elif turning_point <= total_qnt:
		total_score = 0.25
	
	score_dict[classification] = total_score

func score_classification() -> Dictionary:
	var best_score_list := []
	var worst_score_list := []
	
	for classification: String in score_dict:
		if classification == 'cold':
			if score_dict[classification] == 0:
				worst_score_list.append(classification)
		elif score_dict[classification] == 0:
			worst_score_list.append(classification)
		else:
			best_score_list.append(classification)
	
	var score_data := {
		'best_score': best_score_list,
		'worst_score':worst_score_list
	}
	
	score_dict = {}
	
	return score_data
