@tool
extends Node
## Gerenciador de Audio da Sleipnir (Singleton)
##
## Cuida de Tocar SFX e Música, além de garantir perfomance
## por meio de limitar número máximo de audio tocando.

var max_audiostreams : int = 120           ## Número máximo de sons tocando ao mesmo tempo
var currently_playing_audiostreams : Array ## Lista de AudioStreamPlayers tocando no momento
var audiobuses : Array[StringName]         ## Lista de AudioBuses presentes na engine

#private
var _currently_playing_size: int:          # NOTE nao sei se é o melhor lugar para isso estar
	get:
		return _currently_playing_size
	set(value):
		if currently_playing_audiostreams.size() > max_audiostreams:
			if !is_instance_valid(currently_playing_audiostreams[0]): # se tiver sido deletado da memória
				currently_playing_audiostreams.remove_at(0)
			else: # caso não tenha sido deletado da memória
				currently_playing_audiostreams.pop_front().stop()     
			
			Logger.warn("Number of AudioStreamPlayers playing at the same time passed the maximum of "+
					str(max_audiostreams))
			
		_currently_playing_size = currently_playing_audiostreams.size()


func _enter_tree() -> void:
	#_create_bus_layout(["music","sfx"])
	
	for idx in range(0,AudioServer.bus_count):
		audiobuses.append(AudioServer.get_bus_name(idx))
	
	Logger.info("Available Audio Buses are: "+", ".join(audiobuses))


func _ready() -> void: 
	currently_playing_audiostreams.clear()


## Método pra tocar SFX, acontando com os limites do AudioManager [br]
func play_sfx(audio_player) -> void:
	if audio_player is Array: # Pra tocar grupos, pq eles são array de nodes
		for member in audio_player:
			_play(member)
		return
		
	_play(audio_player)


## Método pra parar SFX
func stop_sfx(audio_player) -> void: 
	if audio_player is Array[Node]: # Para grupos, pq são arrays de nodes
		for member in audio_player:
			_stop(member)
		return
	
	_stop(audio_player)


## Método para tocar um SFX Global
func play_global(sfx_name: String) ->void:
	if SfxGlobals.sound_events.has(sfx_name.to_lower()):  
		play_sfx(SfxGlobals.sound_events[sfx_name.to_lower()]) 
	else:
		Logger.warn(sfx_name+" not yet implemented!")


## Método para parar um SFX Global
func stop_global(sfx_name: String) ->void:
	if SfxGlobals.sound_events.has(sfx_name.to_lower()):   
		stop_sfx(SfxGlobals.sound_events[sfx_name])
	else:
		Logger.warn(sfx_name+" not yet implemented!")


## Método para mudar o volume dos buses de audio [br]
## [color=tomato][ATENÇÃO][/color] para a segurança de seus ouvidos [code]allow_clipping[/code] é false por padrão,
## caso você por algum motivo queira que o valor de volume precise passar de 0dB, mude para true na chamada.
func change_bus_volume(bus_name:String,value:float,allow_clipping:bool=false) ->void:
	var bus_idx : int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		Logger.warn(bus_name+" Bus don't exist")
		return 
	
	if allow_clipping and value > 0: # se permite clipar 
		AudioServer.set_bus_volume_db(bus_idx,value) # vai até onde teu coração permitir e teus ouvidos aguentarem
	elif value <= -30: # se o valor for menor que -30
		AudioServer.set_bus_mute(bus_idx,true) # muta
	else:
		AudioServer.set_bus_mute(bus_idx,false) # maior desmuta
		AudioServer.set_bus_volume_db(bus_idx,clampf(value,-30,0)) 


## @experimental
## Método para criar AudioBus [br]
func create_bus(bus_name:StringName) -> Error: 
	match _check_bus_dont_exist(bus_name):
		OK: # bus não existe
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,bus_name.to_lower())
			Logger.info("Added: "+bus_name.to_lower()+" bus")
			return OK
			
		var result: # se bus existe bota o nome dele em uma variável result
			Logger.warn("Cannot create \""+result+"\" bus, it already exists.")
			return ERR_ALREADY_EXISTS
		_:      # qualquer outra merda é um erro gigante
			Logger.fatal("Erro inesperado ao criar bus")
			return FAILED


## @experimental
## Método para deletar AudioBus [br]
func remove_bus(bus_name:String) -> Error: 
	match _check_bus_dont_exist(bus_name):
		OK: # bus não existe
			Logger.warn("Cannot remove \""+bus_name+"\" bus, it does not exist.")
			return ERR_DOES_NOT_EXIST
			
		var result: # se bus existe bota o nome dele em uma variável result
			AudioServer.remove_bus(AudioServer.get_bus_index(result))
			Logger.info("Removed: \""+result+"\" bus")
			return OK
		_:  # qualquer outra merda é um erro gigante
			Logger.fatal("Erro inesperado ao remover bus")
			return FAILED


#region private
func _play(audio_player) -> void:  # O que realmente toca o sfx
	_check_play(audio_player)


func _stop(audio_player) -> void:  # O que realmente para o sfx
	if audio_player.has_method("stop_sound"): # parar o som
		audio_player.stop_sound()     
	
	elif audio_player.has_method("stop"): # parar o som
		audio_player.stop()
		audio_player.emit_signal("finished")
	
	else: # se n for nenhum dos acima vai dar erro
		Logger.error(str(audio_player)+" Not SoundQueue nor AudioStreamPlayer")


func _check_play(audio_player) ->void:
	if audio_player.has_method("play_sound"):
		audio_player.play_sound()
	 
	elif audio_player.has_method("play"): # tocar o som
		if !currently_playing_audiostreams.has(audio_player): currently_playing_audiostreams.append(audio_player)
		_currently_playing_size = currently_playing_audiostreams.size()
		audio_player.play()
		
		if !audio_player.finished.is_connected(_on_audio_finished.bind(audio_player)):
			audio_player.finished.connect(_on_audio_finished.bind(audio_player))
			
	else: # se n for nenhum dos acima vai dar erro
		Logger.error(str(audio_player)+" Not SoundQueue nor AudioStreamPlayer")


func _on_audio_finished(audio_playing): 
	AudioManager.currently_playing_audiostreams.erase(audio_playing)

# TASK Revisar depois :salute:
func _check_bus_dont_exist(bus_name:String) ->Variant: # Checa se o bus existe ou não
	var available_buses : Dictionary
	for i in range(0,AudioServer.bus_count): 
		available_buses.merge({AudioServer.get_bus_name(i).to_lower():AudioServer.get_bus_name(i)})
		
	if bus_name.to_lower() not in available_buses:
		return OK
	elif bus_name.to_lower() in available_buses:
		return available_buses[bus_name]
	return FAILED


func _create_bus_layout(buses:Array[String]) ->Error: # TBD Isso aqui é fudidamente experimental, nao é para agora.
	for bus in buses:
		match _check_bus_dont_exist(bus):
			OK:
				create_bus(bus)
			var result:
				Logger.warn("\""+result+"\" bus already exists")
				continue
			_:
				Logger.error("Error creating \""+bus+"\" bus")
				continue
	
	var bus_layout = AudioServer.generate_bus_layout()
	match ResourceSaver.save(bus_layout,"res://default_bus_layout.tres"):
		OK:
			Logger.info("New bus layout loaded succesfully!")
			AudioServer.set_bus_layout(bus_layout)
			return OK
		_:
			Logger.warn("Failed in loading bus layout")
			return ERR_CANT_CREATE
#endregion

#region deprecated code	
#func _play(audio_player) -> void:  # O que realmente toca o sfx
	#if currently_playing_audiostreams.size() <= max_audiostreams:
		# se o numero de sons tocando for menor ou igual ao numero de audiostreams maxima
	#	_check_play(audio_player)
	#if currently_playing_audiostreams.size() > max_audiostreams:
		# se passou do numero
		#Logger.warn("Number of AudioStreamPlayers playing at the same time passed the maximum of "+ str(max_audiostreams))
		#var stream = currently_playing_audiostreams[0] if currently_playing_audiostreams.size() != 0 else null
		#if stream != null: 
		#	stream.stop()    
		#	Logger.debug("REMOVED: "+str(stream))
		#	currently_playing_audiostreams.remove_at(0)


#func _check_bus_dont_exist(bus_name:String) ->Variant: # Checa se o bus existe ou não
	#var regex = RegEx.new()
	#match regex.compile("(?i)("+bus_name+")"):
		#OK:
			#var result : RegExMatch
			#for i in range(0,AudioServer.bus_count):
				#result = regex.search(str(AudioServer.get_bus_name(i)))
				#if result:
					#return result
			## se não achar nenhum retorna OK
			#return OK
		#_:
			#Logger.error("regex compiling failed, aborting operation!")
			#return FAILED
#endregion
