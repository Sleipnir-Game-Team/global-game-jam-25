class_name TasteGenerator
extends Node

enum taste_value {
	FOAM = 8,
	MILK = 4,
	SUGAR = 2,
	COLD = 1
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func generate_taste() -> Taste:
	var new_taste: Taste = Taste.new()
	
	var selector_number: int = rng.randi_range(0, 15)
	
	if selector_number >= taste_value.FOAM:
		selector_number -= taste_value.FOAM
		new_taste.wants_foam = true
	
	if selector_number >= taste_value.MILK:
		selector_number -= taste_value.MILK
		new_taste.wants_milk = true
	
	if selector_number >= taste_value.SUGAR:
		selector_number -= taste_value.SUGAR
		new_taste.wants_sugar = true
	
	if selector_number >= taste_value.COLD:
		selector_number -= taste_value.COLD
		new_taste.temperature = CoffeeMaking.CoffeeTemperature.COLD
	
	return new_taste
