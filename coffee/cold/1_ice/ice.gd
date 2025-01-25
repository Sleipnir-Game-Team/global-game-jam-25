extends CoffeeStep

@onready var ice_counter_label: Label = %IceCounterLabel

var ice_cubes: int = 0:
	set(value):
		ice_cubes = value
		_update_label(value)


func _update_label(new_value: int) -> void:
		ice_counter_label.text = "Cubos de gelo: %s" % new_value


func _on_add_ice_button_pressed() -> void:
	ice_cubes += 1


func _on_next_pressed() -> void:
	end.emit(ice_cubes)
