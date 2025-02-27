class_name CoffeeMaking
extends Node2D

enum CoffeeTemperature {HOT, COLD}

class Coffee:
	var temperature: CoffeeTemperature = CoffeeTemperature.HOT
	
	# FIRST STAGE
	## HOT SERVE - How many sugar spoons
	var sugar_spoons: int = 0

	## COLD BREW - How many ice cubes
	var ice_cubes: int = 0


	# SECOND STAGE
	## HOT SERVE - How much milk
	var milk_pitcher: MilkPitcher.SIZE = MilkPitcher.SIZE.NONE

	## COLD BREW - How much coffee
	var coffee_oz: float = 0


	# THIRD STAGE (HOT) / FOURTH STAGE (COLD)
	## COLD BREW AND HOT SERVE - How much of your milk is actually just foam
	var foam_percentage: float = 0 


@export var coffee_type: CoffeeTemperature

const COLD_COFFEE_MAKING: Array[PackedScene] = [
	preload("res://coffee/cold/1_ice/ice.tscn"),
	preload("res://coffee/cold/2_pour/pour.tscn"),
	preload("res://coffee/cold/3_syrup/syrup.tscn"),
	preload("res://coffee/cold/4_foam/foam.tscn"),
	preload("res://coffee/cold/5_height/height.tscn")
]

const HOT_COFFEE_MAKING: Array[PackedScene] = [
	preload("res://coffee/hot/1_sugar/sugar.tscn"),
	preload("res://coffee/hot/2_milk/milk.tscn"),
	preload("res://coffee/hot/3_foam/foam.tscn"),
	preload("res://coffee/hot/4_pour/pour.tscn")
]

@onready var current_scene_flow: Array[PackedScene]

var current_scene: CoffeeStep:
	set(new_scene):
		if current_scene:
			current_scene.end.disconnect(_on_scene_end)
			remove_child(current_scene)
			current_scene.queue_free()
		
		current_scene = new_scene
		current_scene.end.connect(_on_scene_end)
		add_child(current_scene)

var current_scene_index: int = 0:
	set(index):
		current_scene_index = index
		_update_scene()

var new_coffee: Coffee = Coffee.new()

signal finished(coffee: Coffee)

func _ready() -> void:
	match coffee_type:
		CoffeeTemperature.HOT:
			current_scene_flow = HOT_COFFEE_MAKING
		CoffeeTemperature.COLD:
			current_scene_flow = COLD_COFFEE_MAKING
	
	_update_scene()


func _update_scene() -> void:
	current_scene = current_scene_flow[current_scene_index].instantiate()

func _on_scene_end(data: Variant) -> void:
	if current_scene_index < current_scene_flow.size() - 1:
		
		match [current_scene_index, data, coffee_type]:
			[_, null, _]: # Received no data - who gives a fuck
				pass
			[0, _, CoffeeTemperature.HOT]: # (HOT) Sugar Spoons 
				new_coffee.sugar_spoons = data
			[0, _, CoffeeTemperature.COLD]: # (COLD) Ice Cubes
				new_coffee.ice_cubes = data
			[1, _, CoffeeTemperature.HOT]: # (HOT) Milk
				new_coffee.milk_pitcher = data
			[1, _, CoffeeTemperature.COLD]: # (COLD) Coffee
				new_coffee.coffee_oz = data
			[2, ..], [3, ..]: # Received data on third or fourth stage - Foam
				new_coffee.foam_percentage = data
		
		current_scene_index += 1
		return
	
	finished.emit(new_coffee)
