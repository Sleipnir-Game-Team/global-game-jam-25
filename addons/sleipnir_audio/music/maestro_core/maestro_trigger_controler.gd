extends Node

func _trigger_remove() ->void:
	for trigger_stem in self.get_children(): # literal só remove e queue_free diretão
		if trigger_stem.is_playing(): # se a stem ainda tiver tocando, dá um fadezao
			var fader = create_tween()
			fader.tween_method(trigger_stem.set_volume_db,-60,0,(SleipnirMaestro.SPB*SleipnirMaestro.BeatsPerBar))
			fader.tween_callback(self.remove_child.bind(trigger_stem))
			fader.tween_callback(trigger_stem.queue_free)
			continue
		self.remove_child(trigger_stem)
		trigger_stem.queue_free()

# função que cria trigger
func _trigger_populate(triggers:Array) ->void: 
	for i in range(0,triggers.size()):    # cria audiostreams pra cada clip de trigger
		var trigger_node = AudioStreamPlayer.new() # cria audiostreamplayer
		trigger_node.volume_db = 1
		trigger_node.pitch_scale = 1              
		trigger_node.bus = &"music"
		# setup do node
		trigger_node.set_stream(triggers[i])       # seta a stream dele pro clip de trigger
		trigger_node.name = triggers[i].resource_path.get_file().get_basename()  # seta o nome do node pro nome do clip
		# append no maestro
		SleipnirMaestro._trigger_stems.append(trigger_node.name)   # dá append na var das stems
		self.add_child(trigger_node)      # adiciona o node ao player
	
	if SleipnirMaestro.log_level <=2 and SleipnirMaestro._trigger_stems.size() > 0: 
		Logger.info("Trigger Loaded = "+str(SleipnirMaestro._trigger_stems.size()))
		Logger.info("Loaded Triggers = "+str(SleipnirMaestro._trigger_stems))
	elif SleipnirMaestro.log_level <=2 and SleipnirMaestro._trigger_stems.size() == 0:
		Logger.info("This Song Doesn't Have Any Trigger Stems")

# método pra tocar trigger syncado
func _trigger_play(TriggerStem:AudioStreamPlayer,sync_method:int=0) -> Error:
	if TriggerStem.is_queued_for_deletion(): # se vai ser liberado da tree
		if SleipnirMaestro.log_level <=2: Logger.info("Ignoring trigger play for "+TriggerStem.name+", because it's being freed")
		return ERR_UNAUTHORIZED
	
	match sync_method:
		0: ## por beat
			await SleipnirMaestro.next_beat
			if !is_instance_valid(TriggerStem): return ERR_UNAUTHORIZED
			
			TriggerStem.play() # da play
			if SleipnirMaestro.log_level <=2:
				Logger.info("playing: "+TriggerStem.name+" ["+str(SleipnirMaestro._get_elapsed_time())+"]")
			
		1: ## por bar
			await SleipnirMaestro.next_bar
			if !is_instance_valid(TriggerStem): return ERR_UNAUTHORIZED
			
			TriggerStem.play() # da play
			if SleipnirMaestro.log_level <=2: 
				Logger.info("playing: "+TriggerStem.name+" ["+str(SleipnirMaestro._get_elapsed_time())+"]")
			
		_: ## fora da seleção
			if SleipnirMaestro.log_level <= 3: Logger.warn("Invalid sync method for playing trigger, using next beat")
			await SleipnirMaestro.next_beat
			if !is_instance_valid(TriggerStem): return ERR_UNAUTHORIZED
			
			TriggerStem.play() # da play
			if SleipnirMaestro.log_level <=2:
				Logger.info("playing: "+TriggerStem.name+" ["+str(SleipnirMaestro._get_elapsed_time())+"]")
	return OK
