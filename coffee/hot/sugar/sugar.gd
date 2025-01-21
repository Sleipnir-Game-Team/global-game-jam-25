extends Control

@onready var sugar_counter_label: Label = %SugarCounterLabel

var sugar_spoons: int = 0:
	set(value):
		sugar_spoons = value
		_update_label(value)


func _on_add_sugar_button_pressed() -> void:
	sugar_spoons += 1


func _update_label(new_value: int) -> void:
		sugar_counter_label.text = "Colheres de açucar: %s" % new_value
	
