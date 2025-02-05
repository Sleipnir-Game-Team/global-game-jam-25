extends CoffeeStep

@onready var pivot: Node2D = %Pivot
@onready var spout_slider: PathFollow2D = %SpoutSlider
@onready var left_border: Marker2D = %LeftBorder
@onready var right_border: Marker2D = %RightBorder
@onready var next: Button = %Next
@onready var texture_rect: TextureRect = %TextureRect

## Porcentagem de líquido que já foi derramado
var liquid_poured: float = 0:
	set(value):
		liquid_poured = value
		texture_rect.size.y = value * 100
		minimum_progress = lerp(0.5, 1.0, liquid_poured) 

@export_range(0, 1, 0.05) var min_liquid_poured: float = 0
@export_range(0, 1, 0.05) var max_liquid_poured: float = 1


## Progresso minímo para que o líquido possa ser derramado.
## Inicia em 50% (ângulo de 45º), incrementa linearmente com o restante
var minimum_progress: float = 0.5

## Por quantos segundos é possível derramar o liquido no angulo máximo;
## Essencialmente, é o tempo minimo que o jogador precisa passar derramando
@export_range(0, 20, 1) var min_pouring_duration: float = 5

var mouse_held_down: bool = false
var mouse_on_slider: bool = false

## Intencionalmente isso está feito de um jeito em que não é preciso acompanhar a area
## com o mouse, diferente de OSU de verdade, mas da pra trocar se ficar melhor
func _process(delta: float) -> void:
	
	if mouse_held_down:
		var percentage: float = inverse_lerp(left_border.global_position.x, right_border.global_position.x, get_global_mouse_position().x)
		percentage = clamp(percentage, 0, 1)
		
		spout_slider.progress_ratio = 1 - percentage
		pivot.rotation = -PI/2 + percentage * (PI/2)
	
	if liquid_poured >= min_liquid_poured:
		next.visible = true
		
	if liquid_poured >= max_liquid_poured:
		spout_slider.visible = false
		return
	
	spout_slider.visible = spout_slider.progress_ratio >= minimum_progress
	
	if spout_slider.visible:
		liquid_poured += delta / (min_pouring_duration / spout_slider.progress_ratio)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return;
		
	mouse_held_down = mouse_on_slider and event.is_pressed();

func _on_osu_slider_mouse_entered() -> void:
	mouse_on_slider = true

func _on_osu_slider_mouse_exited() -> void:
	mouse_on_slider = false


func _on_next_pressed() -> void:
	end.emit(liquid_poured)
