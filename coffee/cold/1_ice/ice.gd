extends CoffeeStep

@onready var ice_counter_label: Label = %IceCounterLabel
@onready var ice_cube_animation: AnimationPlayer = %ice_animation
@onready var ice_cube_sprite: Sprite2D = %Ice_cube_sprite

var can_be_pressed := true

var ice_cubes: int = 0:
	set(value):
		ice_cubes = value
		_update_label(value)
		
func _ready() -> void:
	ice_cube_sprite.visible = false

func _update_label(new_value: int) -> void:
		ice_counter_label.text = "Cubos de gelo: %s" % new_value

func _on_add_ice_button_pressed() -> void:
	if can_be_pressed:
		can_be_pressed = false
		ice_cube_animation.play('ice_cube_animation')
		ice_cubes += 1


func _on_next_pressed() -> void:
	end.emit(ice_cubes)


func _on_ice_animation_animation_finished(anim_name: StringName) -> void:
	can_be_pressed = true
