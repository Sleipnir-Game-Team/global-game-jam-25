extends Node

@onready var score_handler := $score_handler as Node
@onready var taste_handler := $taste_handler as Node

var retrived_taste: Variant
var scores: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	retrived_taste = taste_handler.retrive_taste('teste_client_1')
	print('retrived_taste: ', retrived_taste)
	score_handler.score_calculation('Cold', 5, retrived_taste['1'])
	score_handler.score_calculation('Sugar', 3, retrived_taste['2'])
	score_handler.score_calculation('Milk', 0, retrived_taste['4'])
	score_handler.score_calculation('Foam', 2, retrived_taste['8'])
	scores = score_handler.score_classification()
	print('melhores notas: ', scores['best_score'])
	print('piores notas: ', scores['worst_score'])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
