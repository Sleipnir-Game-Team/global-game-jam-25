@tool
extends EditorPlugin

const MAESTRO_SINGLETON      = "SleipnirMaestro"
const AUDIOMANAGER_SINGLETON = "AudioManager"
const SFXGLOBALS_SINGLETON   = "SfxGlobals"

func _enter_tree() -> void:
	add_custom_type("SoundQueue", "Node",
	preload("sfx/soundqueue.gd"),preload("icons/soundqueue.png"))
	
	add_custom_type("SoundQueue2D", "Node2D",
	preload("sfx/soundqueue_2d.gd"),preload("icons/soundqueue2d.png"))
	
	add_autoload_singleton(SFXGLOBALS_SINGLETON,"sfx/sfx_globals.tscn")
	add_autoload_singleton(AUDIOMANAGER_SINGLETON,"manager/audio_manager.gd")
		
	add_custom_type("SongData","Resource",
	preload("music/maestro_core/song_data.gd"),preload("icons/song_data.png"))
	
	add_custom_type("AudioStateMachine", "AudioStreamPlayer",
	preload("sfx/audio_state_machine.gd"),preload("icons/AudioPlayerInteractive.svg"))

	add_custom_type("AudioInteractivePlayer","AudioStreamPlayer",
	preload("music/maestro_core/audio_interactive_player.gd"),preload("icons/AudioPlayerInteractive.svg"))

	add_custom_type("AudioSyncPlayer","AudioStreamPlayer",
	preload("music/maestro_core/audio_sync_player.gd"),preload("icons/AudioPlayerInteractive.svg"))
	
	add_custom_type("AudioListPlayer","AudioStreamPlayer",
	preload("music/maestro_core/audio_list_player.gd"),preload("icons/AudioPlayerList.svg"))
	
	add_autoload_singleton(MAESTRO_SINGLETON,"music/sleipnir_maestro.tscn")

func _exit_tree() -> void:
	remove_custom_type("SoundQueue")
	remove_custom_type("SoundQueue2D")
	remove_custom_type("AudioStateMachine")
	remove_custom_type("AudioInteractivePlayer")
	remove_custom_type("AudioListPlayer")
	remove_custom_type("AudioSyncPlayer")
	remove_autoload_singleton(AUDIOMANAGER_SINGLETON)
	remove_autoload_singleton(SFXGLOBALS_SINGLETON)
	remove_custom_type("SongData")
	remove_autoload_singleton(MAESTRO_SINGLETON)
