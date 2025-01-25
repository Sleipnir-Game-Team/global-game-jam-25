extends Node

var config := ConfigFile.new()
const SETTINGS_FILE_PATH := "user://settings.ini" #local:C:\Users\#USUARIO#\AppData\Roaming\Godot\app_userdata\#PROJECTNAME#
var screen_resolution := DisplayServer.screen_get_size()
var pc_resolution := [screen_resolution[0], screen_resolution[1]]
var pc_width : int = pc_resolution[0]
var pc_height : int = pc_resolution[1]
signal window_mode_changed
signal window_resolution_changed

func _ready() -> void:
	verify_configfile()

######################################### Init Handler #########################################
func verify_configfile() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding", "player_left", "A")
		config.set_value("keybinding", "player_right", "D")
		config.set_value("keybinding", "player_hit", "Left Mouse Button")
		config.set_value("keybinding", "player_special", "Right Mouse Button")
		
		config.set_value("video", "window_mode", 4)
		config.set_value("video", "width", pc_width)
		config.set_value("video", "height", pc_height)
		
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
		verify_all_settings()
		run_all_settings()

func run_all_settings() -> void:
	var video_settings := load_all_video_settings()
	change_window_settings(video_settings.window_mode, [video_settings.width, video_settings.height])
	
	var audio_settings := load_all_audio_settings()
	change_master_volume(min(audio_settings.master_volume, 1.0) * 100)
	change_music_volume(min(audio_settings.music_volume, 1.0) * 100)
	change_sfx_volume(min(audio_settings.sfx_volume, 1.0) * 100)

func verify_all_settings() -> void:
	if config.has_section_key("video", "resolution"):
		save_video_settings("resolution", null)
	if get_setting("video", "width") == null:
		save_video_settings("width", pc_width)
	if get_setting("video", "height") == null:
		save_video_settings("height", pc_height)
	if type_string(typeof(get_setting("video", "window_mode"))) == "String":
		save_video_settings("window_mode", 3)
	if config.has_section_key("video", "supported_resolutions"):
		save_video_settings("supported_resolutions", null)
	if config.has_section_key("keybinding", "player_up"):
		save_keybinding_settings("player_up", null)
	if config.has_section_key("keybinding", "player_down"):
		save_keybinding_settings("player_down", null)


######################################### Window Handler #########################################
func change_window_mode(mode: int) -> void:
	DisplayServer.window_set_mode(mode)
	save_video_settings("window_mode", mode)


func change_window_resolution(resolution: Array) -> void:
	var vector := Vector2i(resolution[0], resolution[1])
	var decoration_size := Vector2i(DisplayServer.window_get_size_with_decorations() - DisplayServer.window_get_size())
	vector -= decoration_size
	var pos := [pc_resolution[0]/2 - vector[0]/2, pc_resolution[1]/2 - vector[1]/2]
	DisplayServer.window_set_size(vector)
	DisplayServer.window_set_position(Vector2i(pos[0], pos[1]))
	save_video_settings("width", resolution[0])
	save_video_settings("height", resolution[1])


func change_window_settings(window_mode: Variant, window_resolution: Variant) -> void:
	if window_mode != null and window_resolution != null:
		var borderless :bool = (window_mode >= 3)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
		change_window_mode(window_mode)
		change_window_resolution(window_resolution)
		window_mode_changed.emit(window_mode)
		window_resolution_changed.emit(window_resolution)
	elif window_mode != null and window_resolution == null:
		if window_mode >= 3:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			change_window_mode(window_mode)
			window_mode_changed.emit(window_mode)
			window_resolution_changed.emit(pc_resolution)
		else:
			var resolution := [get_setting("video", "width"), get_setting("video", "height")]
			change_window_mode(window_mode)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			change_window_resolution(resolution)
			window_mode_changed.emit(window_mode)
			window_resolution_changed.emit(resolution)
	elif window_mode == null and window_resolution != null:
		if DisplayServer.window_get_mode() < 3:
			change_window_resolution(window_resolution)
			window_resolution_changed.emit(window_resolution)
		else:
			if window_resolution != pc_resolution:
				change_window_mode(0)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				window_mode_changed.emit(0)
				change_window_resolution(window_resolution)
				window_resolution_changed.emit(window_resolution)
	else:
		Logger.fatal("Erro: Configuração selecionada não existe")


func reset_window_settings() -> void:
	change_window_settings(4, [1920, 1080])


######################################### Volume Handler #########################################
func change_master_volume(value: float) -> void:
	AudioManager.change_bus_volume(&"Master", value)


func change_music_volume(value: float) -> void:
	AudioManager.change_bus_volume(&"music", value)


func change_sfx_volume(value: float) -> void:
	AudioManager.change_bus_volume(&"sfx", value)


func mute_master_volume(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)


######################################### Input Handler #########################################
#func create_action_list():
	#InputMap.load_from_project_settings()
	#for item in keybinding_list:
		#item.queue_free()
		#
	#var action_formatted_list = format_actions(InputMap.get_actions())
	#for action in action_formatted_list:
		##var button = input_button_scene.instantiate()
		#pass
#
#
#func format_actions(actions):
	#pass

#TODO finalizar essa função, conectar ela com os sliders e criar o botão de reset
func reset_volume_settings() -> void:
	change_master_volume(1.0)
	change_music_volume(1.0)
	change_sfx_volume(1.0)
	save_audio_settings("master_volume", 1.0)
	save_audio_settings("music_volume", 1.0)
	save_audio_settings("sfx_volume", 1.0)


######################################### Saving Handler #########################################
func save_video_settings(key: String, value: Variant) -> void:
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)


func save_audio_settings(key: String, value: Variant) -> void:
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)


func save_keybinding_settings(key: String, value: Variant) -> void:
	config.set_value("keybinding", key, value)
	config.save(SETTINGS_FILE_PATH)


######################################### Loading Handler #########################################
func load_all_video_settings() -> Dictionary:
	var video_settings: Dictionary = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings


func load_all_audio_settings() -> Dictionary:
	var audio_settings: Dictionary = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings


func load_all_keybinding_settings() -> Dictionary:
	var keybinding_settings: Dictionary = {}
	for key in config.get_section_keys("keybinding"):
		keybinding_settings[key] = config.get_value("keybinding", key)
	return keybinding_settings


func get_setting(category: String, key: String) -> Variant:
	return config.get_value(category, key)
