extends CoffeeStep

@onready var tip: Area2D = %Tip
@onready var foam_line: Area2D

@onready var pitcher_top: Marker2D
@onready var pitcher_bottom: Marker2D
@onready var next: Button = %Next
@onready var foam_audio: AudioStateMachine = %FoamAudio

var frothing: bool = false
var foaming: bool = false
var full: bool = false

@export_range(0, 1, 0.05) var milk: float = 0.2
@export_range(0, 1, 0.05) var increment_per_second: float = 0.2

var foam: float = 0

func _ready() -> void:
	var pitcher: Node
	match get_parent().new_coffee.milk_pitcher:
		1: 
			pitcher = load("res://coffee/hot/3_foam/small_pitcher.tscn").instantiate();
			increment_per_second = 0.2
		2: 
			pitcher = load("res://coffee/hot/3_foam/medium_pitcher.tscn").instantiate();
			increment_per_second = 0.15
		3: 
			pitcher = load("res://coffee/hot/3_foam/large_pitcher.tscn").instantiate();
			increment_per_second = 0.1
	
	pitcher.name = "Pitcher"
	add_child(pitcher)
	foam_line = $Pitcher/FoamLine
	pitcher_top = $Pitcher/PitcherTop
	pitcher_bottom = $Pitcher/PitcherBottom
	AudioManager.play_sfx(foam_audio)

func _process(delta: float) -> void:
	if full:
		foam_audio.switch_audio_state("OUT")
		return;
		
	foam_line.position.y = pitcher_bottom.position.y + (pitcher_top.position.y -  pitcher_bottom.position.y) * (milk + foam)
	
	if frothing:
		if foaming:
			foam_audio.switch_audio_state("DEEP")
			foam += delta * increment_per_second
		else:
			foam_audio.switch_audio_state("SHALLOW")
			milk += delta * increment_per_second
	else:
		foam_audio.switch_audio_state("OUT")
	
	if milk + foam >= 1:
		print("Milk: %s" % milk)
		print("Foam: %s" % foam)
		full = true
		next.visible = true
		

func _on_frother_area_entered(_area: Area2D) -> void:
	frothing = true

func _on_frother_area_exited(_area: Area2D) -> void:
	frothing = false


func _on_tip_area_entered(_area: Area2D) -> void:
	foaming = true

func _on_tip_area_exited(_area: Area2D) -> void:
	foaming = false


func _on_next_pressed() -> void:
		AudioManager.stop_sfx(foam_audio)
		end.emit(foam)
