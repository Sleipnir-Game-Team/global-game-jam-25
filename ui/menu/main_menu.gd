extends Control


func _ready() -> void:
	if SleipnirMaestro.current_song_node != null and SleipnirMaestro.current_song_node.is_playing():
		SleipnirMaestro.load_song("main_menu",true,0,false)
	else:
		SleipnirMaestro.load_song("main_menu",false,0,false)
		SleipnirMaestro.play()
	UI_Controller.stack.screens.append(self)
	

## Função que roda quando você aperta o botão de "jogar"
func _on_play_button_pressed() -> void:
	AudioManager.play_global("ui.button.click")
	UI_Controller.changeScreen("res://main.tscn")

## Função que roda quando você aperta o botão de "opções"
func _on_options_button_pressed() -> void:
	AudioManager.play_global("ui.button.click")
	UI_Controller.openScreen("res://ui/menu/options_menu.tscn")
	
## Função que roda quando você aperta o botão de "créditos"
func _on_credits_button_pressed() -> void:
	AudioManager.play_global("ui.button.click")
	UI_Controller.openScreen("res://ui/menu/credits_menu.tscn")
	
## Função que roda quando você aperta o botão de "sair"
func _on_quit_button_pressed() -> void:
	AudioManager.play_global("ui.button.click")
	get_tree().quit() # Fecha a aplicação
