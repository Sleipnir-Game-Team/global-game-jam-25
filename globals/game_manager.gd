extends Node

## Quantas camadas de pause tem
##  0 - O jogo não está pausado
## +1 - O jogo está pausado por essa quantidade de fontes
var _pause_layers: int = 0:
	get:
		return _pause_layers
	set(value):
		_pause_layers = max(0, value)
		get_tree().paused = _pause_layers > 0

## Adiciona uma camada de pause
func pause() -> void:
	_pause_layers += 1
	Logger.info("Camada de pause adicionada, atualmente existem %s camadas" % [_pause_layers])

## Remove uma camada de pause
## ATENÇÃO: Utilizar essa função NÃO implica que o jogo será despausado
## Despausar o jogo exige que TODAS as camadas de pause sejam removidas
func resume() -> void:
	_pause_layers -= 1
	Logger.info("Camada de pause removida, atualmente existem %s camadas" % [_pause_layers])


func game_over() -> void:
	UI_Controller.changeScreen("res://ui/menu/game_over_menu.tscn", get_tree().root)
