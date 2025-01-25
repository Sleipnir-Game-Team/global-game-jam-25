@tool
extends AudioStreamPlayer
class_name AudioSyncPlayer

## streams de sync atuais [br](no momento somente válidas para [AudioStreamSynchronized] como MainClip)
var sync_streams : Dictionary      

func _init(song_data) -> void:
	var clips = song_data.get_main_clips()
	self.set_stream(clips)           # seta a stream pro MainPlayer
	self.name = song_data.resource_path.get_file().get_basename()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.volume_db = 1                 # volume pra 1
	self.pitch_scale = 1               # pitch pra 1
	self.bus = &"music"
	_get_sync_streams(self.stream)


func _get_sync_streams(sync_stream:AudioStreamSynchronized) -> void:
	sync_streams.clear()
	var count = sync_stream.stream_count
	var volume : float
	for i in range(0,count):
		volume = sync_stream.get_sync_stream_volume(i)
		var temp_dict : Dictionary
		if volume == -60:
			temp_dict = {i:false} 
		else:
			temp_dict = {i:true} 
		sync_streams.merge(temp_dict, false)
	if SleipnirMaestro.log_level <= 1:
		Logger.info("there are " + str(count) + " sync_streams and they are: " +str(sync_streams))


func toggle_layer_on(SyncStream:int) -> Error:
	if sync_streams.is_empty():
		if  SleipnirMaestro.log_level <= 3: Logger.warn("No sync_streams for this player")
		return ERR_DOES_NOT_EXIST
	
	if sync_streams[SyncStream] == true:
		if  SleipnirMaestro.log_level <=1: Logger.debug("Layer Already Active!")
		return ERR_ALREADY_IN_USE
	
	if self.get_stream() is not AudioStreamSynchronized:
		if  SleipnirMaestro.log_level <= 3 : Logger.warn("can't toggle unless is AudioStreamSynchronized")
		return ERR_INVALID_PARAMETER
	
	var old : float = self.stream.get_sync_stream_volume(SyncStream)
	var new : float
	
	if old != 0.0:
		new = 0.0
	
	if SleipnirMaestro.log_level<=1: 
		Logger.debug("Stream of Number: "+str(SyncStream)+" from "+str(old)+" to "+str(new))
	if SleipnirMaestro.log_level<=1: 
		Logger.debug("BeatsPerBar: "+str(SleipnirMaestro.BeatsPerBar)+
					", SPB: "+str(SleipnirMaestro.SPB)+
					", BPM: "+str(SleipnirMaestro.BPM))
	
	var gain_control = func(tweener:float):
		self.stream.set_sync_stream_volume(SyncStream,tweener)
	
	var fader = create_tween()
	fader.tween_method(gain_control,old,new,(SleipnirMaestro.SPB*SleipnirMaestro.BeatsPerBar))
	
	sync_streams[SyncStream] = true
	
	if SleipnirMaestro.log_level <=2 : Logger.info("Toggled On "+str(self.stream.get_sync_stream(SyncStream)))
	return OK

func toggle_layer_off(SyncStream:int) -> Error:
	if sync_streams.is_empty():
		if  SleipnirMaestro.log_level <= 3: Logger.warn("No sync_streams for this player")
		return ERR_DOES_NOT_EXIST
	
	if sync_streams[SyncStream] == false:
		if  SleipnirMaestro.log_level <=1: Logger.debug("Layer Already Inactive!")
		return ERR_ALREADY_IN_USE
	
	if self.get_stream() is not AudioStreamSynchronized:
		if  SleipnirMaestro.log_level <= 3 : Logger.warn("can't toggle unless is AudioStreamSynchronized")
		return ERR_INVALID_PARAMETER
		
	var old : float = self.stream.get_sync_stream_volume(SyncStream)
	var new : float
	
	if old != -60.0:
		new = -60.0
	
	if SleipnirMaestro.log_level<=1: 
		Logger.debug("Stream of Number: "+str(SyncStream)+" from "+str(old)+" to "+str(new))
	if SleipnirMaestro.log_level<=1: 
		Logger.debug("BeatsPerBar: "+str(SleipnirMaestro.BeatsPerBar)+
					", SPB: "+str(SleipnirMaestro.SPB)+
					", BPM: "+str(SleipnirMaestro.BPM))
	
	var gain_control = func(tweener:float):
		self.stream.set_sync_stream_volume(SyncStream,tweener)
	
	var fader : Tween = create_tween()
	fader.tween_method(gain_control,old,new,(SleipnirMaestro.SPB*SleipnirMaestro.BeatsPerBar))
	
	sync_streams[SyncStream] = false

	if SleipnirMaestro.log_level <=2 : Logger.info("Toggled Off "+str(self.stream.get_sync_stream(SyncStream)))
	return OK
