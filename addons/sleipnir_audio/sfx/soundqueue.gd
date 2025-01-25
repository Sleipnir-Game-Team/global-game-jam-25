@tool
class_name SoundQueue
extends Node
## Workaround para lidar com polyfonia no godot
##
## Cria AudioStreamPlayer para ser usado como polifonia


@export var Count : int = 1: ## Quantos AudioStreamPlayer vai ter
	get:
		return Count
	set(value):
		update_configuration_warnings() #NOTE eu devia mesmo chamar isso aqui, aqui?
		Count = clamp(value,0,16) # Limite passivo de 16
#@export var print_log : bool = false              ## Ativar logging no output


var _next : int = 0 ## Variável que vai ser usada para navegar na lista de AudioStreamPlayers
var _audioStreamPlayers : Array[AudioStreamPlayer] ## Faz uma lista que só aceita AudioStreamPlayers


func _ready() -> void:                      # Logo quando entra
	if get_child_count() == 0:              # Se o Node n tiver nenhuma child
		return                           
	var child = get_child(0)                # Pega a primeira child
	if child is AudioStreamPlayer:          # Se ela for AudioStreamPlayer
		_audioStreamPlayers.append(child)   # Bota na Lista
		for i in range(0,Count-1):          # Duplica o AudioStreamPlayer de acordo com o Count
			var  child_duplicate = child.duplicate() as AudioStreamPlayer
			add_child( child_duplicate)
			_audioStreamPlayers.append(child_duplicate)


func play_sound() -> void:   ## Toca a SoundQueue    
	if !_audioStreamPlayers[_next].playing: # Se o som da child _next não estiver tocando:
		if !AudioManager.currently_playing_audiostreams.has(_audioStreamPlayers[_next]): 
			AudioManager.currently_playing_audiostreams.append(_audioStreamPlayers[_next])
			AudioManager._currently_playing_size = AudioManager. currently_playing_audiostreams.size()
			
		_audioStreamPlayers[_next].play() # Ele vai tocar nela
		
		# cria uma variavel
		var audio_playing := get_node(get_path_to(_audioStreamPlayers[_next]))
		if !audio_playing.finished.is_connected(_on_audio_finished.bind(audio_playing)):
			audio_playing.finished.connect(_on_audio_finished.bind(audio_playing)) 
		# conecta um sinal a ela pra saber quando acaba
		
		_next = _next + 1                              # E passar pro proximo AudioStreamPlayer na lista	
	if _next == _audioStreamPlayers.size(): _next = 0  # Quando atinge o fim Reseta pra 0, criando um ciclo


func stop_sound() -> void:
	for audio_index in Count:
		if _audioStreamPlayers[audio_index].playing:
			_audioStreamPlayers[audio_index].stop()
			_audioStreamPlayers[audio_index].emit_signal("finished")


func _on_audio_finished(audio_playing): 
	AudioManager.currently_playing_audiostreams.erase(audio_playing)
	#if print_log == true:
	#	Logger.debug("Tocando:\n"+str(AudioManager.currently_playing_audiostreams)+"\n - - - - - - -")


func _get_configuration_warnings() -> PackedStringArray: # Manda Notificação Direto no Node:
	if get_child_count() == 0:                           # Se n tem nenhuma Child
		return ["No children found. Expected AudioStreamPlayer child."]
	if not(get_child(0) is AudioStreamPlayer):           # Se a primeira Child não é AudioStreamPlayer
		return ["Expected first child to be an AudioStreamPlayer."]
	return []
