extends Control

@onready var error_type_label: Label = get_node("%error_type_label")
@onready var error_description: RichTextLabel = get_node("%error_description")
var error_type:String
var error_msg:String


func _ready() -> void:
	error_type_label.text = error_type
	error_description.text = error_msg


func manage_attributes(attributes: Dictionary) -> void:
	error_type = attributes["Tipo"]
	error_msg = attributes["Mensagem"]


func _on_ok_button_pressed() -> void:
	AudioManager.play_global("ui.screen.back")
	UI_Controller.freeScreen()
