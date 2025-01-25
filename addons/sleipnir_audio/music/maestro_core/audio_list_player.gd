@tool
extends AudioStreamPlayer
class_name AudioListPlayer

func _init(song_data) -> void:
	self.set_stream(song_data.get_main_clips())           # seta a stream pro MainPlayer
	self.name = song_data.resource_path.get_file().get_basename()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.volume_db = 1                 # volume pra 1
	self.pitch_scale = 1               # pitch pra 1
	self.bus = &"music"
