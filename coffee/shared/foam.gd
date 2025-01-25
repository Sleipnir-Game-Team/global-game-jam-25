extends CoffeeStep

@onready var tip: Area2D = %Tip
@onready var foam_line: Area2D = %FoamLine

@onready var pitcher_top: Marker2D = %PitcherTop
@onready var pitcher_bottom: Marker2D = %PitcherBottom

var frothing: bool = false
var foaming: bool = false
var full: bool = false:
	set(value):
		full = value
		

@export_range(0, 1, 0.05) var milk: float = 0.2
@export_range(0, 1, 0.05) var increment_per_second: float = 0.2

var foam: float = 0

func _process(delta: float) -> void:
	if full:
		print("Milk: %s" % milk)
		print("Foam: %s" % foam)
		return;
		
	foam_line.position.y = pitcher_bottom.position.y + (pitcher_top.position.y -  pitcher_bottom.position.y) * (milk + foam)
	
	if frothing:
		if foaming:
			foam += delta * increment_per_second
		else:
			milk += delta * increment_per_second
	
	if milk + foam >= 1:
		full = true

func _on_frother_area_entered(_area: Area2D) -> void:
	frothing = true

func _on_frother_area_exited(_area: Area2D) -> void:
	frothing = false


func _on_tip_area_entered(_area: Area2D) -> void:
	foaming = true

func _on_tip_area_exited(_area: Area2D) -> void:
	foaming = false
