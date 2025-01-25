extends Node

@onready var taste_generator := $taste_generator as Node
@onready var taste_handler := $taste_handler as Node

var generated_taste: Dictionary
var retrived_taste: Variant
var created_taste: Dictionary

func _ready() -> void:
	generated_taste = taste_generator.generate_taste()
	print('generated_taste: ', generated_taste)
	taste_handler.save_taste(generated_taste, 'teste_client_1')
	retrived_taste = taste_handler.retrive_taste('teste_client_1')
	print('retrived_taste: ', retrived_taste)
	created_taste = taste_handler.create_taste(false, true, false, true, 'test_client_2')
	print('created_taste: ', created_taste)
