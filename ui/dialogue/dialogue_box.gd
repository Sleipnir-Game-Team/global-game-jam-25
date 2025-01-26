extends Control

@onready var speaker_sprite_texturerect: TextureRect = get_node("%speaker")
@onready var speaker_name_label: Label = get_node("%speaker_name")
@onready var speech_richlabel: RichTextLabel= get_node("%speech")
var speaker_sprite: String
var speaker_name: String
var speech: String
var text_to_format: String
var actions: Array = []

func _ready() -> void:
	speaker_sprite
	format_dialogue_box()
	

func format_dialogue_box() -> void:
	for linha in text_to_format.split("\n"):
		var linhaDividida: Array = linha.split(";")
		var actionDict: Dictionary = {}
		for item: String in linhaDividida:
			var itemDividido: Array = item.split("|")
			actionDict[itemDividido[0]] = itemDividido[1]
		actions.append(actionDict)

func manage_attributes(attributes: Dictionary) -> void:
	speaker_name = attributes["nome"]
	speaker_sprite = attributes["imagem"]
	text_to_format = attributes["texto"]

func on_cutsceneNext() -> void:
	UI_Controller.processAction(actions.pop_front())

func updateCutsceneImg(image: String) -> void:
	$TextureRect.texture = load(image)

func updateCutsceneTxt(text: String) -> void:
	$Label.set_text(text)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if event.is_pressed():
			UI_Controller.cutsceneNext.emit()
