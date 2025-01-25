class_name ScoreHandler
extends Node

@export var turning_point: int

var score_dict: Dictionary = {}

func score_calculation(classification: String, total_qnt: Variant, taste_flag: bool) -> void:
	classification = classification.to_lower()
	
	var total_score: float = 0.0
	
	if not taste_flag:
		turning_point = 0
	
	if turning_point <= total_qnt:
		total_score = 0.25
	
	score_dict[classification] = total_score

func score_classification() -> Dictionary:
	var best_score_list: Array = []
	var worst_score_list: Array = []
	
	for classification: String in score_dict:
		if score_dict[classification] == 0:
			worst_score_list.append(classification)
		elif classification != "cold":
			best_score_list.append(classification)
	
	var score_data: Dictionary = {
		'best_score': best_score_list,
		'worst_score': worst_score_list
	}
	
	score_dict = {}
	
	return score_data
