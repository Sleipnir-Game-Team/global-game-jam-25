extends Node2D

@export_range(5, 90, 1) var tipping_angle: float = 15
@export_range(0, 1, 0.05) var down_duration: float = 1
@export_range(0, 1, 0.05) var up_duration: float = 0.5

@onready var pivot: Node2D = %Pivot
@onready var base_rotation: float

var tipping: bool = false
var tipped: float = 0

func _ready() -> void:
	base_rotation = pivot.rotation

func _process(delta: float) -> void:
	if not tipping:
		tipped -= delta/up_duration
	else:
		tipped += delta/down_duration
	
	tipped = clamp(tipped, 0, 1)
	
	pivot.rotation = base_rotation + tipped * (base_rotation - deg_to_rad(tipping_angle) - base_rotation)
	

func _on_tip_over_button_down() -> void:
	tipping = true


func _on_tip_over_button_up() -> void:
	tipping = false
