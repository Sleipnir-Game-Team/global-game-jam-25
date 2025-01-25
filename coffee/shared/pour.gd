extends CoffeeStep

@onready var pivot: Node2D = %Pivot
@onready var spout_slider: PathFollow2D = %SpoutSlider
@onready var osu_slider: PathFollow2D = %OsuSlider
@onready var left_border: Marker2D = %LeftBorder
@onready var right_border: Marker2D = %RightBorder

var mouse_held_down: bool = false
var mouse_on_slider: bool = false

## Intencionalmente isso está feito de um jeito em que não é preciso acompanhar a area
## com o mouse, como seria em OSU de verdade, mas da pra trocar se ficar melhor
func _process(_delta: float) -> void:
	if mouse_held_down:
		var percentage: float = (get_global_mouse_position().x - left_border.global_position.x) / (right_border.global_position.x - left_border.global_position.x)
		percentage = clamp(percentage, 0, 1)
		osu_slider.progress_ratio = 1 - percentage
		spout_slider.progress_ratio = 1 - percentage
		pivot.rotation = -PI/2 + percentage * (PI/2)
		osu_slider.rotation = -PI/2 + percentage * (PI/2)
		
		spout_slider.visible = spout_slider.progress_ratio >= 0.5



func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return;
		
	if mouse_on_slider and event.is_pressed():
		mouse_held_down = true;
	else:
		mouse_held_down = false;

func _on_osu_slider_mouse_entered() -> void:
	mouse_on_slider = true

func _on_osu_slider_mouse_exited() -> void:
	mouse_on_slider = false
