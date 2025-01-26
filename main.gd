extends Node2D

@onready var cold_toggle: CheckButton = %ColdToggle
@onready var sugar_toggle: CheckButton = %SugarToggle
@onready var milk_toggle: CheckButton = %MilkToggle
@onready var foam_toggle: CheckButton = %FoamToggle

@onready var taste_generator: TasteGenerator = TasteGenerator.new()

@onready var scores: Label = %Scores

var coffee_making: CoffeeMaking

var current_taste: Taste:
	set(value):
		current_taste = value
		
		cold_toggle.button_pressed = current_taste.temperature == CoffeeMaking.CoffeeTemperature.COLD
		sugar_toggle.button_pressed = current_taste.wants_sugar
		milk_toggle.button_pressed = current_taste.wants_milk
		foam_toggle.button_pressed = current_taste.wants_foam

var score: ScoreHandler = ScoreHandler.new()

func _ready() -> void:
	_on_generate_pressed()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		UI_Controller.managePauseMenu()

func _instantiate_making() -> void:
	coffee_making = preload("res://coffee/coffee_making.tscn").instantiate()
	coffee_making.finished.connect(_on_coffee_finished)

func _on_hot_coffee_pressed() -> void:
	_instantiate_making()
	coffee_making.coffee_type = CoffeeMaking.CoffeeTemperature.HOT
	_start()

func _on_cold_coffee_pressed() -> void:
	_instantiate_making()
	coffee_making.coffee_type = CoffeeMaking.CoffeeTemperature.COLD
	_start()


func _start() -> void:
	add_sibling(coffee_making)
	visible = false


func _on_generate_pressed() -> void:
	current_taste = taste_generator.generate_taste()


func _on_coffee_finished(created_coffee: CoffeeMaking.Coffee) -> void:
	get_parent().remove_child(coffee_making)
	coffee_making.queue_free()
	visible = true
	
	# COFFEE TYPE
	score.score_calculation('Cold', created_coffee.temperature, current_taste.temperature)
	
	# FIRST STAGE - SUGAR OR ICE CUBES
	score.score_calculation('Sugar', created_coffee.sugar_spoons, current_taste.wants_sugar)
	#score.score_calculation('Ice', created_coffee.ice_cubes, current_taste.wants_sugar) TODO
	
	# SECOND STAGE - MILK OR COFFEE 
	score.score_calculation('Milk', created_coffee.milk_pitcher, current_taste.wants_milk)
	#score.score_calculation('Coffee', created_coffee.coffee_oz, current_taste.wants_milk) TODO
	
	# THIRD/FOURTH STAGE - FOAM
	score.score_calculation('Foam', created_coffee.foam_percentage, current_taste.wants_foam)
	
	var classification: Dictionary = score.score_classification()
	scores.text = "MELHOR SCORE: %s\nPIOR SCORE: %s" % [classification["best_score"], classification["worst_score"]]
	
