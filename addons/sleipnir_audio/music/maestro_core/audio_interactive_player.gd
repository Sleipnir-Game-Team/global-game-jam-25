@tool
extends AudioStreamPlayer
class_name AudioInteractivePlayer

static var current_section  : String          ## em que sessão estamos?

var _section_dict : Dictionary         # sessões da música mapeadas para int
var _transition_type : int                # qual transição vai rolar
var _corrected_transitions : Array              # as transições corrigidas do modo BAR de transição

func _init(song_data:SongData,change_to_default_first:bool) -> void:
	_section_dict.clear()
	_corrected_transitions.clear()
	_section_dict =  song_data.get_sections()\
	 if _section_dict != song_data.get_sections() else _section_dict
	
	Logger.info("Sections are: "+str(_section_dict))
	if change_to_default_first == true:
		current_section = song_data.get_first_section()          # pega qual a sessão default da música
	
	self.set_stream(song_data.get_main_clips())           # seta a stream pro _current_song_node
	
	if self.get_stream().get_transition_list().size() == 0:   ## Se a table não for usada, usar configurações default
		_transition_type = song_data.get_track_transition()          # pega qual transição default é usada entre os clips da musica
		var fade_mode  : int   = song_data.get_fade_mode()           # pega qual o fade_mod
		var fade_beats : float = song_data.get_fade_beats()          # pega em quanto faz o fade	
		# se a transição geral for feita por barras, seta como imediato pra poder usar o metodo custom
		if _transition_type == 2:
			self.get_stream().add_transition(-1,-1,0,0,fade_mode,fade_beats)
		# caso não seja, apenas usa a forma padrão
		else:
			self.get_stream().add_transition(-1,-1,_transition_type,0,fade_mode,fade_beats)
	
	else: # WARNING Tem forma melhor de fazer isso? # TASK Ver _init_()
		for corrected in song_data.correct_clips_transition(): 
			## Para cada transição que precisa ser corrigida
			## Apaga a atual, e substitui por uma nova
			self.get_stream().erase_transition(corrected["from_to"][0],corrected["from_to"][1])
			
			if corrected["filler_clip"] == -1: # se não usar filler clips, adiciona sem
				self.get_stream().add_transition(
						corrected["from_to"][0],corrected["from_to"][1],
						0,corrected["to_time"],corrected["fade_mode"],
						corrected["fade_beats"],false,-1,corrected["hold_previous"]
					)
			else: # se usar filler clips, passa eles
				self.get_stream().add_transition(
						corrected["from_to"][0],corrected["from_to"][1],
						0,corrected["to_time"],corrected["fade_mode"],
						corrected["fade_beats"],true,corrected["filler_clip"],
						corrected["hold_previous"]
					)
			_corrected_transitions.append(corrected["from_to"]) # dá append na variavel de transições corrigidas pra check depois
		Logger.info("corrected these transitions: "+str(_corrected_transitions))
	
	if song_data.MainClips.get_clip_name(song_data.MainClips.initial_clip) != current_section:
		self.set("parameters/switch_to_clip",current_section)  # seta a sessão pra ela
	else:
		pass # do nothing
	self.name = song_data.resource_path.get_file().get_basename()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.volume_db = -3                 # volume pra 1
	self.pitch_scale = 1               # pitch pra 1
	self.bus = &"music"

## Muda de sessão para a música toda [br]
## [codeblock]SleipnirMaestro.switch_song_section("combat")[/codeblock]
func switch_song_section(section_name:String,offset:int=0) ->Error:
	if self.stream is not AudioStreamInteractive:
		if SleipnirMaestro.log_level<=3:
			Logger.warn("stream invalid: "+str(self.stream)+
					" Can only use this method if Main Stream is of type AudioStreamInteractive")
		return ERR_INVALID_PARAMETER

	# se quiser mudar pra sessão atual, retorna
	if current_section == section_name:
		Logger.warn("can't switch to the same section")
		return ERR_ALREADY_IN_USE
	
	# se estiver pausado ou parado, retorna
	if (self.is_playing() == false) and (self.get_stream_paused() == false):
		Logger.warn("can't switch to section when stopped or paused!")
		return ERR_UNAVAILABLE
	
	#if log_level <=1 : 
	#	Logger.debug("transition type é: "
	#	+str(_current_song_node.stream.get_transition_from_time(_section_dict[current_section],_section_dict[section_name])))
	
	# isso checa se tem que fazer em barra ou nao
	# as transições são feitas em pares (onde estamos, para onde vamos), por isso to passando o dict
	if _corrected_transitions.has(
			[_section_dict[current_section],
			_section_dict[section_name]]
			): 
		if SleipnirMaestro.log_level <=2 : 
			Logger.info("will switch to "+ section_name +" ["+str(SleipnirMaestro._get_elapsed_time())+" s]")
		self._switch_by_bar(section_name,offset)
		return OK
		
	# Se nao tem que fazer a transição em barra nessa transição especifica
	# checa a default da música
	match _transition_type: 
		2: # se for por bar
			if SleipnirMaestro.log_level <=2 : 
				Logger.info("will switch to "+ section_name +" ["+str(SleipnirMaestro._get_elapsed_time())+" s]") 
			self._switch_by_bar(section_name,offset) # usar o método custom de transição
		_: # se for qualquer outra
			self._switch_section(section_name)
	return OK

func _switch_by_bar(section_name : String ,offset : int = 0) -> void:
	await SleipnirMaestro.next_bar
	_switch_section(section_name)

func _switch_section(section_name : String):
	var playback : AudioStreamPlaybackInteractive = self.get_stream_playback()
	playback.switch_to_clip_by_name(section_name) # usa o default
	current_section = section_name
	
	if SleipnirMaestro.log_level <=2: 
		Logger.info(current_section+" ["+str(SleipnirMaestro._get_elapsed_time())+" s] [Bar "+
		str(SleipnirMaestro.elapsed_measures)+"| Beat "+str(SleipnirMaestro.elapsed_beats)+"] ")	
