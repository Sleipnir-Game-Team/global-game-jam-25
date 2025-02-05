extends Control

@onready var resolution_dropbox: = get_node("%resolution_dropbox")
@onready var window_mode_dropbox: = get_node("%window_mode_dropbox")
@onready var volume_master_slider: = get_node("%master_slider")
@onready var volume_music_slider: = get_node("%music_slider")
@onready var volume_sfx_slider: = get_node("%sfx_slider")
@onready var volume_ambience_slider: = get_node("%ambience_slider")
@onready var mute_checkbox: = get_node("%mute_check_box")


func _ready() -> void:
	Config_Handler.window_mode_changed.connect(_on_window_mode_changed)
	var window_mode : Variant = Config_Handler.get_setting("video", "window_mode")
	var window_resolution := [Config_Handler.get_setting("video", "width"), Config_Handler.get_setting("video", "height")]
	window_mode_dropbox.select(window_mode_dropbox.get_item_index(window_mode))
	resolution_dropbox.select_item(window_resolution)
	volume_master_slider.value = min(Config_Handler.get_setting("audio", "master_volume"), 1.0) * 100
	volume_music_slider.value = min(Config_Handler.get_setting("audio", "music_volume"), 1.0) * 100
	volume_sfx_slider.value = min(Config_Handler.get_setting("audio", "sfx_volume"), 1.0) * 100
	volume_ambience_slider.value = min(Config_Handler.get_setting("audio", "ambience_volume"), 1.0) * 100
	

func _on_window_mode_changed(value: int) -> void:
	window_mode_dropbox.select(window_mode_dropbox.get_item_index(value))

func _on_window_mode_dropbox_item_selected(index: int) -> void:
	Config_Handler.change_window_settings(window_mode_dropbox.get_item_id(index), null)
	

func _on_resolution_dropbox_item_selected(index: int) -> void:
	Config_Handler.change_window_settings(null, resolution_dropbox.get_selected_item(index))
	

func _on_master_slider_value_changed(value: float) -> void:
	mute_checkbox.button_pressed = false
	AudioManager.play_global("ui.slider.tick")
	Config_Handler.change_master_volume(value)
	

func _on_master_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Config_Handler.save_audio_settings("master_volume", volume_master_slider.value / 100)
	

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.play_global("ui.slider.tick")
	Config_Handler.change_music_volume(value)


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Config_Handler.save_audio_settings("music_volume", volume_music_slider.value / 100)
		

func _on_sfx_slider_value_changed(value:float) -> void:
	AudioManager.play_global("ui.slider.tick")
	Config_Handler.change_sfx_volume(value)
	

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Config_Handler.save_audio_settings("sfx_volume", volume_sfx_slider.value / 100)
	

func _on_ambience_slider_value_changed(value:float) -> void:
	AudioManager.play_global("ui.slider.tick")
	Config_Handler.change_ambience_volume(value)
	

func _on_ambience_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Config_Handler.save_audio_settings("ambience_volume", volume_ambience_slider.value / 100)
	

func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	AudioManager.play_global("ui.button.click")
	Config_Handler.save_audio_settings("muted", toggled_on)
	Config_Handler.mute_master_volume(toggled_on)
	

func _on_back_button_pressed() -> void:
	AudioManager.play_global("ui.screen.back")
	UI_Controller.freeScreen()
	
