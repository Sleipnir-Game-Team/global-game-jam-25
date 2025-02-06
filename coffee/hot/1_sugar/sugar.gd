extends CoffeeStep

@onready var sugar_counter_label: Label = %SugarCounterLabel
@onready var sugar_jar_sprite: Button = %AddSugarButton
@onready var sugar_jar_animation: AnimationPlayer = %sugar_animation


var sugar_spoons: int = 0:
	set(value):
		sugar_spoons = value
		_update_label(value)
		
func _ready() -> void:
	sugar_jar_sprite.set_button_icon(load('res://assets/Assets finalizados/Acucar A.png'))

func _on_add_sugar_button_pressed() -> void:
	sugar_jar_animation.play('sugar_animation')
	sugar_spoons += 1


func _update_label(new_value: int) -> void:
	sugar_counter_label.text = "Colheres de açucar: %s" % new_value


func _on_next_pressed() -> void:
	end.emit(sugar_spoons)
