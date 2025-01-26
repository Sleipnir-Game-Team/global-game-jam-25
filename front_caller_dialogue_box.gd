extends VBoxContainer

var actions: Array = []
var introText: String = "type|img;url|res://Assets/Cutscene/Intro 1.jpg\ntype|txt;text|Every day adventurers raid and loot poor dungeons in search of treasure.\ntype|wait\ntype|img;url|res://Assets/Cutscene/Intro 2.jpg\ntype|txt;text|In search of the greatest known treasure, the Dungeon's Heart, the blasted adventurers decided to invade the magnificent living dungeon.\ntype|wait\ntype|img;url|res://Assets/Cutscene/Intro 3.jpg\ntype|txt;text|But what they didn't know is that the dungeon itself could grow.\ntype|wait\ntype|img;url|res://Assets/Cutscene/Intro 4.jpg\ntype|txt;text|Filling the path with traps to stop them\ntype|wait\ntype|img;url|res://Assets/Cutscene/Intro 2.jpg\ntype|txt;text|They think it will be easy to rob me\ntype|wait\ntype|img;url|res://Assets/Cutscene/Intro 5.jpg\ntype|txt;text|F O O L S ! !\ntype|wait\ntype|end"
var test_text: String = "type|img;content|res://assets/ice_cube.png\ntype|name;content|Ice Cube\ntype|txt;content|Olá! Meu nome é Ice Cube, eu sou um negão de respeito, to preparado p mostrar a que eu vim, rexpeita fi\ntype|wait\ntype|end"

func _ready() -> void:
	format_content(test_text)
	UI_Controller.dialogue_request.connect(pass_content)

func _process(_delta: Variant) -> void:
	if Input.is_action_just_pressed("Dialogue"):
		UI_Controller.start_dialogue()

func format_content(content: String) -> void:
	for linha in content.split("\n"):
		var linhaDividida: Array = linha.split(";")
		var actionDict: Dictionary = {}
		for item: String in linhaDividida:
			var itemDividido: Array = item.split("|")
			actionDict[itemDividido[0]] = itemDividido[1]
		actions.append(actionDict)

func pass_content() -> void:
	#InkHandler.continue_story()
	UI_Controller.manage_dialogue_box.emit(actions.pop_front())
