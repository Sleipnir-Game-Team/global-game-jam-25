extends Node

var want_it_cold := false
var want_a_lot_of_sugar := false
var want_a_lot_of_milk := false
var want_a_lot_of_foam := false

enum taste_value {
	FOAM = 8,
	MILK = 4,
	SUGAR = 2,
	COLD = 1
}

var rng := RandomNumberGenerator.new()

func generate_taste() -> Dictionary:
	var selector_number := rng.randi_range(0, 15)

	if selector_number >= taste_value.FOAM:
		want_a_lot_of_foam = true
		selector_number -= taste_value.FOAM
	
	if selector_number >= taste_value.MILK:
		want_a_lot_of_milk = true
		selector_number -= taste_value.MILK
		
	if selector_number >= taste_value.SUGAR:
		want_a_lot_of_sugar = true
		selector_number -= taste_value.SUGAR
		
	if selector_number >= taste_value.COLD:
		want_it_cold = true
		selector_number -= taste_value.COLD

	var taste_list := {
		taste_value.COLD : want_it_cold,
		taste_value.SUGAR : want_a_lot_of_sugar,
		taste_value.MILK: want_a_lot_of_milk,
		taste_value.FOAM: want_a_lot_of_foam
	}
	
	return taste_list
