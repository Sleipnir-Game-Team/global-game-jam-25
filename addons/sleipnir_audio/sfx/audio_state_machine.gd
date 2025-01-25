extends AudioStreamPlayer
class_name AudioStateMachine

var current_state  : String          ## em que sessão estamos?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.volume_db = -3                 # volume pra 1
	self.pitch_scale = 1               # pitch pra 1

## Muda de estado no sfx
func switch_audio_state(state_name:String,offset:int=0) ->Error:
	if self.stream is not AudioStreamInteractive:
		Logger.warn("stream invalid: "+str(self.stream)+
				" Can only use this method if Main Stream is of type AudioStreamInteractive")
		return ERR_INVALID_PARAMETER

	# se quiser mudar pra sessão atual, retorna
	if current_state == state_name:
		Logger.warn("can't switch to the same state")
		return ERR_ALREADY_IN_USE
	
	# se estiver pausado ou parado, retorna
	if (self.is_playing() == false) and (self.get_stream_paused() == false):
		Logger.warn("can't switch to state when stopped or paused!")
		return ERR_UNAVAILABLE
	
	self._switch_state(state_name)
	return OK

func _switch_state(state_name : String):
	var playback : AudioStreamPlaybackInteractive = self.get_stream_playback()
	playback.switch_to_clip_by_name(state_name) # usa o default
	current_state = state_name
