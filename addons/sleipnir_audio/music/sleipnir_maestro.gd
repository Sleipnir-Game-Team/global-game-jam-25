@tool
## Sleipnir Global Music Player
##
## [b][color=crimson]ATENÇÃO[/color] Measure e Bar são a mesma coisa. 
## estes termos são usados alternadamente durante esse código[/b] [br] [br]
## Para usar, salve sua musica como [SongData] e defina o path de onde você irá guardar estes resources. [br]
## Esses resources serão então carregados no SleipnirMaestro 
## onde todos os dados são tratados, e adicionados dinamicamente a nodes para poder tocar e
## transicionar as músicas e suas diversas sessões. [br]
extends Node

# sinais de tempo
signal beat (position:int)              ## manda a beat atual 
signal measure (position:int)           ## manda a measure atual
signal next_bar                         ## manda a próxima measure 
signal next_beat                        ## manda a próxima beat 

# variáveis do editor
@export_category("Config Geral")        # Configurações relacionadas a música
@export var MainPlayer     : Node       ## [Node] que cuida dos clips principais
@export var TriggerPlayer  : Node       ## [Node]  que cuida dos clips de trigger
@export var Clock          : Timer      ## Clock para contar tempo musical 
@export_dir var _song_path : String     ## Path das músicas
@export_subgroup("Debug")               # Configurações de debugging
@export_enum(                           # enum de logging
"ALL","DEBUG","INFO","WARN","ERROR","FATAL","OFF"
) var log_level : int = 2               ## Selecionar nível de logging

# variaveis de tempo
var BPM              : int              ## Beats per Minute
var BeatsPerBar      : int              ## Beat em 1 até infty (só n abusa)
var SPB              : float            ## Seconds Per Beat
# variaveis de monitoramento
var elapsed_measures : int = 0:         ## conta as barras
	set(value):
		elapsed_measures = value
		if value == _next_measure:
			next_bar.emit()
	get:
		return elapsed_measures
var elapsed_beats    : int = 1:         ## conta beats sempre relativo a Time Signature
	set(value):
		elapsed_beats = value
		if value == _next_beat:
			next_beat.emit()
	get:
		return elapsed_beats       
var current_song     : String = "none"  ## musica atual
var current_song_node: AudioStreamPlayer  # Node da música atual mais nova


#region variaveis privadas
var _next_measure : int:               # próxima measure
	set(value): _next_measure = elapsed_measures+1
var _next_beat : int:               # próxima beat
	set(value): _next_beat = elapsed_beats+1 if elapsed_beats < BeatsPerBar else 1
var _trigger_stems : Array              # stems trigger
var _currently_playing_trigger : Array              # triggers tocando
var _is_changing_songs : bool = false       # se está mudando de música
var _silence_path : String = "silence-500ms.mp3"    # path do placeholder de silencio
#endregion

# funções públicas VVVVVVVVV
#region PlayBack

## da o play, com ou sem fade in
## [codeblock]SleipnirMaestro.play()[/codeblock]
func play(fade_time:float=0.0) ->void:
	if current_song == "none":        # se não tem musica carregada retorna
		Logger.warn("there's no song here!")
		return
	if (current_song_node.is_playing() == true): # se já estiver tocando retorna
		Logger.warn("song already playing!")
		return
		
	Clock.start()     # começa o conductor
	_next_beat = _next_beat
	_next_measure = _next_measure
	if fade_time == 0:
		current_song_node.set_volume_db(0.0)
		current_song_node.play() # da play
	else:
		current_song_node.set_volume_db(-60.0)
		var fader = create_tween()
		current_song_node.play() # da play
		fader.tween_method(current_song_node.set_volume_db,-60,0,(fade_time))

## para tudo, com ou sem fade out
## [codeblock]SleipnirMaestro.stop()[/codeblock]
func stop(fade_time:float=0.0) ->void : 
	if current_song == null or current_song_node == null: # se não tiver musica, retorna
		Logger.warn("there's no song here!")
		return
	
	if current_song_node.is_playing() == false: # se já nao estiver tocando, retorna
		Logger.warn("The Song is not playing! can't stop what's not happening")
		return
	
	if fade_time == 0:
		current_song_node.stop() # para musica
	else:
		var fader = create_tween()
		fader.tween_method(current_song_node.set_volume_db,0,-60,(fade_time))
		fader.tween_callback(current_song_node.stop)
	
	Clock.stop()      # para clock
	elapsed_beats    = 1
	elapsed_measures = 0
	
	if current_song_node is AudioInteractivePlayer:
		current_song_node.current_section = current_song_node._section_dict.keys()[0]
	
	if _currently_playing_trigger.size() != 0: # para os triggers
		for TriggerStem in _currently_playing_trigger:
			TriggerStem.stop()
			_currently_playing_trigger.erase(TriggerStem)

## chama um clip e da play nele
## [codeblock]
## # pode ser
## SleipnirMaestro.trigger("nome_do_trigger")
## # ou
## SleipnirMaestro.trigger("nome_do_trigger",int)
## # esta int podendo ser 0 ou 1 ,onde 0 é por beat e 1 é por bar
## [/codeblock]    
func trigger(trigger_name:String,sync_method:int=0) ->void :
	if current_song == "none":     # se não tem musica carregada retorna
		if log_level <=3: Logger.warn("there's no song here!")
		return
		
	if (current_song_node.is_playing() == false): # se não estiver tocando retorna
		Logger.warn("can't play when song is not playing")
		return
	
	if _trigger_stems.has(trigger_name) == false: # se não tem o trigger chamado
		if log_level <=3: Logger.warn("there's no trigger with the name \""+trigger_name+"\"")
		return

	var TriggerStem = get_node("/root/SleipnirMaestro/Triggers/"+trigger_name)
	
	TriggerPlayer._trigger_play(TriggerStem,sync_method) ## WARNING TESTAR BEM.
	
	_currently_playing_trigger.append(TriggerStem)
	
	await TriggerStem.finished
	
	if log_level <=1: Logger.debug("finished playing: "+TriggerStem.name)
	
	_currently_playing_trigger.erase(TriggerStem)

## pausa tudo
## [codeblock]SleipnirMaestro.pause()[/codeblock]
func pause(fade_time:float=0.0) ->void :
	if current_song == "none": #se não tem musica tocando retorna
		Logger.warn("there's no song here!")
		return 
	if current_song_node.get_stream_paused() == true: # se não estiver pausado, retorna
		Logger.warn("song already paused!")
		return
	if fade_time == 0:
		current_song_node.stream_paused = true # pausa musica
	else:
		var fader = create_tween()
		fader.tween_method(current_song_node.set_volume_db,0,-60,(fade_time))
		fader.tween_callback(current_song_node.set_stream_paused.bind(true))
	Clock.set_paused(true) # pausa clock
	Logger.info("Song Paused!")
	if _currently_playing_trigger.size() != 0: # pausa trigger 
		for TriggerStem in _currently_playing_trigger:
			TriggerStem.set_stream_paused(true)

## resume o pause
## [codeblock]SleipnirMaestro.resume()[/codeblock]
func resume(fade_time:float=0.0) ->void :
	if current_song == "none": # se não tem musica tocando, retorna
		Logger.warn("there's no song here!")
		return 
	if current_song_node.get_stream_paused() == false: # se não estiver pausado, retorna
		Logger.warn("song already playing!")
		return
	Clock.set_paused(false) # resume clock
	if fade_time == 0:
		current_song_node.set_volume_db(0.0)
		current_song_node.stream_paused = false # resume musica
	else:
		current_song_node.set_volume_db(-60.0)
		var fader = create_tween()
		current_song_node.stream_paused = false # resume musica
		fader.tween_method(current_song_node.set_volume_db,-60,0,(fade_time))
	Logger.info("Song Resumed!")
	if _currently_playing_trigger.size() != 0:
		for TriggerStem in _currently_playing_trigger:
			
			TriggerStem.set_stream_paused(false)
#endregion

## Muda de música de acordo com suas especificações [br]
## [codeblock]
## # pode ser
## SleipnirMaestro.change_song("nome_da_musica")
## # ou também
## SleipnirMaestro.change_song("nome_da_musica",stay_playing:bool,transition_type:String, keep_section:bool)
## [/codeblock]
## onde: [br]
## [param stay_playing] diz se continua tocando enquanto transiciona ou não[br]
## [param fade_beats] em quantas beats vai fazer a transição de fade, 0 desativa [br]
## [param keep_section] diz se mantém a sessão anterior, ou se muda pra default, por exemplo, se estava em combate, se deve permanecer quando transicionar ou não
## 
func load_song(song_name:String, stay_playing:bool=false, fade_beats:int = 1, keep_section:bool=false) ->Error:
	# BUG se tu trocar várias vezes muito rápido (o que é BEEM improvável), cria audiostream extra. 
	# ele eventualmente é limpado, mas acaba gerando duas transições por algum motivo
	if current_song_node != null and song_name == current_song_node.name: # checa se n tá tentando ir pra mesma
		if log_level <= 3: Logger.info("Changing to the same song!")
		SleipnirMaestro.stop()
		SleipnirMaestro.play()
		return ERR_ALREADY_IN_USE
	
	_is_changing_songs = true
	
	if Clock.is_stopped() == false: Clock.stop() 
	
	if TriggerPlayer.get_child_count() != 0: # se tiver trigger, tira 
		TriggerPlayer._trigger_remove() # TODO tem que ter algo aqui que garanta ela não tocar, ou nao remover até o trigger terminar de tocar?
		_trigger_stems.clear()
	
	var old_song : AudioStreamPlayer
	
	if (current_song_node != null) and (song_name != str(current_song_node.name)):
		if log_level<=2: Logger.info("Transitioning from "+str(current_song_node.name)+" to "+song_name)
		old_song = current_song_node
	
	# carrega o resource da musica
	var song_data = load(_song_path+"/"+song_name+".tres")
	
	if (song_data == null) or (song_data is not SongData):
		Logger.error("Could not load song \""+song_name+"\"")
		return ERR_FILE_NOT_FOUND
	
	if MainPlayer.get_child_count() == 0:
		_data_handling(song_data) # distribui os dados onde precisa
	else:
		_data_handling(song_data,!keep_section) # distribui os dados onde precisa
	
	elapsed_measures = elapsed_measures # seta as measures
	current_song = song_name # seta o nome
	
	# mensagens extras
	var _stay_playing_message :String = " "
	var _keep_section_message :String = " "
	
	if old_song == null:
		if log_level < 3: 
			Logger.info(str(current_song)+" Ready! at "+
					str(BPM)+" BPM or "+ str(SPB) +" SPB | "+str(BeatsPerBar)+" Beats per Bar")
		
		_is_changing_songs = false
		return OK
	
	if stay_playing == true and old_song.is_playing():
		if fade_beats != 0:
				_clock_reset()
				current_song_node.play()
				_fade_transition(old_song,current_song_node,fade_beats)
		else:
			old_song.stop()
			_clock_reset()
			current_song_node.play()
			old_song.queue_free()
	else:
		old_song.queue_free()
	
	_is_changing_songs = false

	if log_level < 3:
		if stay_playing == true: _stay_playing_message = "| continued playing" 
		else: _stay_playing_message = "| stopped playing"
		if current_song_node is AudioInteractivePlayer:
			_keep_section_message = "| keeping section "+\
			current_song_node.current_section if keep_section == true else "| overriding section to default"
	 
		Logger.info(str(current_song)+" Ready! at "+
		str(BPM)+" BPM or "+ str(SPB) +" SPB "+_stay_playing_message+" "+_keep_section_message)
	
	return OK

# funções privadas 
func _ready() -> void:
	if Clock.one_shot != false: # só pra garantir o clock n tocar só uma vez
		Clock.one_shot = false
	#var _measure_tracker = Callable(self,"_measure_tracker")
	if TriggerPlayer.get_child_count() != 0: # se tiver algum trigger aqui, remover
		TriggerPlayer._trigger_remove()                

# o que acontece quando o conductor conta 1 Beat
func _on_conductor_timeout() -> void:
	elapsed_beats += 1                            # Adiciona ao elapsed_beats
	_next_beat = _next_beat
	if elapsed_beats == BeatsPerBar+1:            # Checa se não finalizou uma Measure
		elapsed_beats = 1                         # Reseta o timer de beats
		emit_signal("measure", elapsed_measures)  # Emite sinal de finalizar Measure
		elapsed_measures += 1                     # Adiciona ao elapsed_measures
		_next_measure = _next_measure
	
	if log_level < 2:                             # Log informando tempo musical
		Logger.debug(str(elapsed_measures)+"Bar "
		+str(elapsed_beats)+"Beat "
		+"["+str(_get_elapsed_time())+" s]")
	
	emit_signal("beat", elapsed_beats)            # Emite o sinal de finalizar uma Beat	

# só a transição por fade
func _fade_transition(old:AudioStreamPlayer,new:AudioStreamPlayer,offset:int) ->void:
	new.volume_db = -60
	var fader = create_tween()
	fader.tween_method(new.set_volume_db,-60,0,(SPB*BeatsPerBar*offset))
	fader.parallel().tween_method(old.set_volume_db,0,-60,(SPB*BeatsPerBar*offset))
	fader.tween_callback(old.queue_free)

#region Utilities
# literal só pega o tempo atual da engine
func _get_elapsed_time() -> float: return Time.get_ticks_msec()/1000.00;

# reseta o clock quando muda de musica
func _clock_reset()->void:
	elapsed_beats = 1
	elapsed_measures = 0
	Clock.start()
#endregion

# aviso funções gigante abaixo
#region Data Handling
# função para pegar os dados e popular o player Main e os Triggers
func _data_handling(song_data:Resource,change_to_default_first:bool=true) -> void:
	var is_silent : bool = false
	var AudioPlayer : AudioStreamPlayer
	
	# WARNING quando eu dou clear no section_dict eu não estou mudando o current_section para null
	# acredito que isso não poderá causar erros, já que ele só é limpo em coisas que não usam ele,
	# porém deixo o warning aqui.
	
	if song_data.MainClips is AudioStreamInteractive:
		AudioPlayer = AudioInteractivePlayer.new(song_data,change_to_default_first)
		
	elif song_data.MainClips is AudioStreamSynchronized:
		AudioPlayer = AudioSyncPlayer.new(song_data)
		
	elif song_data.MainClips is AudioStreamPlaylist: 
		AudioPlayer = AudioListPlayer.new(song_data)
	
	else:
		AudioPlayer = AudioStreamPlayer.new()
		Logger.error("Invalid AudioStream, loading silence stream...")
		is_silent = true
		AudioPlayer.set_stream(_load_mp3())
		AudioPlayer.name = "NO_AUDIO"
		AudioPlayer.bus = &"music"
	
	MainPlayer.add_child(AudioPlayer)      # adiciona o node ao player
	current_song_node = AudioPlayer
	
	if is_silent == false: _get_bpm(song_data)                               # seta o BPM pro clock só se não for silencio
	
	if song_data.has_trigger_clips == true:      # se tem trigger
		var trigger_clips : Array = song_data.get_trigger_clips() # seta a stream pro trigger
		TriggerPlayer._trigger_populate(trigger_clips)
	else: return                 # se não tem , retorna

# pega o BPM para usar no clock
# usado no _data_handling()
func _get_bpm(song_data:Resource) -> void: 
	if song_data.BPM != 0: # vê se os dados estão sendo dados no resource
		BPM = song_data.BPM                                      # pega o BPM dela
		BeatsPerBar = song_data.BeatsPerBar                      # pega as BeatsPerBar dela
		SPB = 60.0/(BPM*(BeatsPerBar/4))                         # calcula SPB
		Clock.wait_time = SPB                                    # Seta o conductor para o tempo certo
		return	
	
	# TASK falta uma forma de pegar bpm caso alguem esqueça do bpm
	# porém não é um problema em música que não precise de sync.
	
	elif log_level<=4: 
			Logger.warn("No BPM found in "+str(song_data.resource_path.get_file().get_basename())+".tres, sync errors may occur")

func _load_mp3() -> AudioStreamMP3: 
	var file = FileAccess.open(_silence_path, FileAccess.READ)
	# pega um arquivo em silencio
	var sound = AudioStreamMP3.new()
	# cria um AudioStreamMP3 Novo
	sound.data = file.get_buffer(file.get_length())
	# Esqueci
	return sound 
	# retorna a audiostream
#endregion

# Aqui tem as que mão uso mais, mas pode ser que eu use depois
#region deprecated
func _look_for_bpm():
	# qual é a primeira stream do node
	var first_stream : Variant = current_song_node.stream    
	var reference_stream : Variant      # variável que vai ser usada para pegar bpm
	var count : int                     # variavel pra loop pra achar bpm
	var stream_get : Callable           # qual método vai pegar
	
	if current_song_node.stream is AudioStreamInteractive:
		count = first_stream.clip_count
		stream_get = Callable(AudioStreamInteractive,"get_clip_streams")
	elif current_song_node.stream is AudioStreamSynchronized:
		count = first_stream.stream_count       
		stream_get = Callable(AudioStreamSynchronized,"get_sync_streams")
	elif current_song_node.stream is AudioStreamPlaylist:
		count = first_stream.stream_count
		stream_get = Callable(AudioStreamPlaylist,"get_list_streams")
		
	for index_stream in range(0,count):
		var stream : Variant # stream a ser analisada
		stream = first_stream.stream_get.bind(index_stream)
		if (
			stream is AudioStreamInteractive or
			stream is AudioStreamSynchronized or 
			stream is AudioStreamPlaylist or 
			stream.is_meta_stream()
			):
			stream = _get_child_stream(stream)
		
		if stream.get_bpm() == 0:
			continue
			
		reference_stream = stream
		break

	BPM = int(reference_stream.get_bpm())                    # pega o BPM dela
	BeatsPerBar = int(reference_stream.get_bar_beats())      # pega as BeatsPerBar dela
	SPB = 60.0/(BPM*(BeatsPerBar/4))                         # calcula SPB
	Clock.wait_time = SPB                                    # Seta o conductor para o tempo certo

# pega a AudioStreamMP3, OggVorbis ou WAV
# usado no _get_bpm()
func _get_child_stream(stream): 
	## Aqui é a mais pura bagunça, desculpa o textão mas puta que pariu.
	## tem um método diferente pra cada uma das 3 AudioStreams Musicais
	## essa função inteira é só lidando com o método de cada uma delas
	
	var count : int # variavel que conta quantas streams tem 
	
	if stream is not AudioStreamInteractive: # se não for interactive, usa a propriedade comum
		count = stream.stream_count # quantos clips tem
	else: # se for, USA A PORRA DA PROPRIEDADE ESPECIFICO PARA INTERACTIVE
		count = stream.clip_count
		
	for i in range(0,count):  # loopa dentro do count
		var audiostream # definimos um audiostream, que pode ser qualquer um
		if stream is AudioStreamSynchronized: # se for sync, usa metodo do sync
			audiostream = stream.get_sync_stream(i)
		elif stream is AudioStreamInteractive:# se for interactive, usa metodo do interactive
			audiostream = stream.get_clip_stream(i)
		elif stream is AudioStreamPlaylist:   # se for playlist, usa metodo do playlist
			audiostream = stream.get_list_stream(i)
		else:
			if log_level <=3 : Logger.warn("audiostream is not meta_stream")
		
		# checa se o resultado n foi um dos tipos de audiostreams formados de outro
		# se for, repete a função
		if (
		audiostream is AudioStreamInteractive or 
		audiostream is AudioStreamPlaylist or 
		audiostream is AudioStreamSynchronized or 
		audiostream.is_meta_stream()
		):
				_get_child_stream(audiostream)
		# se não, só retorna o audiostream
		elif ( 
		audiostream is AudioStreamMP3 or 
		audiostream is AudioStreamOggVorbis or 
		audiostream is AudioStreamWAV
		):
			return audiostream
		# se n for nenhum deles, deu merda
		else:
			if log_level <=4 :Logger.error("No Usable AudioStreams found")
#endregion
