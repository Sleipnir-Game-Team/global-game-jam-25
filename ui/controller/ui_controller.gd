extends Node

var stack: ScreenStack = ScreenStack.new()
var pause_menu_on: bool = false
signal manage_dialogue_box
signal dialogue_request

class ScreenStack:
	var screens: Array[Node]  = []
	
	func add(scene: PackedScene, parent: Node, attributes: Variant = null) -> void:
		var screen: Node = scene.instantiate()
		
		screens.append(screen)
		if attributes != null:
			screen.manage_attributes(attributes)
		parent.add_child(screen)
	
	
	func pop() -> Node:
		if screens.size() <= 0:
			Logger.fatal("Não há cena para liberar")
			push_error('deu ruim')
		
		## FIXME OU QUE MEDO ISSO AQUI MANO, tá retornando o bagulho que foi queue_freed, pode dar ruim isso aqui
		var screen: Node = screens.pop_back()
		screen.queue_free()
		return screen


func openScreen(screen_path: String, parent: Node = get_tree().root, attributes: Variant = null) -> void:
	var newScreen: PackedScene
	
	if screen_path != null:
		newScreen = load(screen_path)
	else:
		Logger.warn("Parâmetro de tela não informado")
	if attributes != null:
		stack.add(newScreen, parent, attributes)
	else:
		stack.add(newScreen, parent)


func changeScreen(screen_path: String, parent: Node = get_tree().root, attributes: Variant = null) -> void:
	var newScreen: PackedScene
	
	if screen_path != null:
		newScreen = load(screen_path)
	
	while stack.screens != []:
		stack.pop()
	if attributes != null:
		stack.add(newScreen, parent, attributes)
	else:
		stack.add(newScreen, parent)

func freeScreen() -> Node:
	print(stack.screens)
	return stack.pop()

func managePauseMenu() -> void:
	if !pause_menu_on:
		pause_menu_on = true
		Game_Manager.pause()
		openScreen("res://ui/menu/pause_menu.tscn", get_tree().root)
	elif freeScreen().name == "PauseMenu":
		print("whyyyyyyyyy")
		pause_menu_on = false
		Game_Manager.resume()
		
func start_dialogue() -> void:
	#chamar o ink
	openScreen("res://ui/dialogue/dialogue_box.tscn", get_tree().root)
