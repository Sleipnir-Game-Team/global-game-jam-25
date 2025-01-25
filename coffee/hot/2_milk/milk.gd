extends CoffeeStep

@onready var small: Button = %Small
@onready var medium: Button = %Medium
@onready var large: Button = %Large
@onready var next: Button = %Next

var pitcher_size: MilkPitcher.SIZE = MilkPitcher.SIZE.NONE

var _pressed: bool = false:
	set(value):
		small.disabled = not value
		medium.disabled = not value
		large.disabled = not value
		next.visible = value
		_pressed = value

func _on_small_pressed() -> void:
	_pressed = true
	small.disabled = true
	pitcher_size = MilkPitcher.SIZE.SMALL


func _on_medium_pressed() -> void:
	_pressed = true
	medium.disabled = true
	pitcher_size = MilkPitcher.SIZE.MEDIUM


func _on_large_pressed() -> void:
	_pressed = true
	large.disabled = true
	pitcher_size = MilkPitcher.SIZE.LARGE


func _on_next_pressed() -> void:
	end.emit(pitcher_size)
