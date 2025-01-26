extends Control



func _on_back_button_pressed() -> void:
	AudioManager.play_global("ui.screen.back")
	UI_Controller.freeScreen()
