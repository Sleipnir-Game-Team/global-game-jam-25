@tool
extends Node
## (singleton) Sound Effects que podem levar trigger de qualquer lugar do projeto
##
## Utilize esta cena para sons que irão se repetir em multiplos lugares pelo jogo
## como botões de UI, ataques em comum de inimigos, e etc.

var sound_events : Dictionary ## Sons no SFXGlobals

func _ready() -> void:
	sound_events.clear()
	sound_events = _get_all(self)
	if sound_events.size() == 0:
		Logger.info("Não existe nenhum SFX Global carregado.")
	else:
		Logger.info("SFX Globais são: "+", ".join(sound_events.keys()))

# private
func _get_all(node:Node) -> Dictionary: # pega todos as children e grand children de um node e joga pro sound_events
	if node.get_child_count() == 0: return {}
	
	var all_child : Dictionary
	
	for child in node.get_children():
		if child.has_method("play_sound") or child.has_method("play"):
			if child.get_parent() != self:
				all_child.merge({child.name.to_lower():child})
			else:
				all_child.merge({"uncategorized."+child.name.to_lower():child})
			continue
		
		var child_array = _get_all(child)
		for grand_child in child_array:
			if child_array[grand_child].has_method("play_sound") or child_array[grand_child].has_method("play"):
				all_child.merge({child.name.to_lower()+"."+grand_child.to_lower():child_array[grand_child]})
				continue
	
	return all_child
