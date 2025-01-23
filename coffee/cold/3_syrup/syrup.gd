extends Control

var pumps: int = 0
@onready var pump_button: Button = %PumpButton


func _on_pump_button_pressed() -> void:
	pumps += 1
	
	if pumps >= 2:
		pump_button.disabled = true
	
