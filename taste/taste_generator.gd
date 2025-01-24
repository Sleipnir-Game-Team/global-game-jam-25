extends Node

var want_it_cold := false
var want_a_lot_of_sugar := false
var want_a_lot_of_milk := false
var want_a_lot_of_foam := false

var rng := RandomNumberGenerator.new()

func generate_taste() -> Array:
	var selector_number := rng.randi_range(0, 15)

	if selector_number >= 8:
		want_a_lot_of_foam = true
		selector_number -= 8
	
	if selector_number >= 4:
		want_a_lot_of_milk = true
		selector_number -= 4
		
	if selector_number >= 2:
		want_a_lot_of_sugar = true
		selector_number -= 2
		
	if selector_number >= 1:
		want_it_cold = true
		selector_number -= 1

	var taste_list := [want_it_cold, want_a_lot_of_sugar, want_a_lot_of_milk, want_a_lot_of_foam]
	return taste_list
	
