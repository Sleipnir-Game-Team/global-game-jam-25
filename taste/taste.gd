class_name Taste
extends Resource

@export var temperature: CoffeeMaking.CoffeeTemperature
@export var wants_sugar: bool
@export var wants_milk: bool
@export var wants_foam: bool


# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_temperature: CoffeeMaking.CoffeeTemperature = CoffeeMaking.CoffeeTemperature.HOT,
			p_wants_sugar: bool = false,
			p_wants_milk: bool = false,
			p_wants_foam: bool = false) -> void:
	temperature = p_temperature
	wants_sugar = p_wants_sugar
	wants_milk = p_wants_milk
	wants_foam = p_wants_foam
