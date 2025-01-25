extends CoffeeStep

var pumps: int = 0
@onready var pump_button: Button = %PumpButton
@onready var next: Button = %Next


func _on_pump_button_pressed() -> void:
	pumps += 1
	
	if pumps >= 2:
		pump_button.disabled = true
		next.visible = true
	


func _on_next_pressed() -> void:
	end.emit(null)
