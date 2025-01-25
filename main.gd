extends Node2D



var coffee_making: CoffeeMaking = preload("res://coffee/coffee_making.tscn").instantiate()

func _on_hot_coffee_pressed() -> void:
	coffee_making.coffee_type = coffee_making.CoffeeTemperature.HOT
	_start()

func _on_cold_coffee_pressed() -> void:
	coffee_making.coffee_type = coffee_making.CoffeeTemperature.COLD
	_start()


func _start() -> void:
	add_sibling(coffee_making)
	visible = false
	queue_free()
	
