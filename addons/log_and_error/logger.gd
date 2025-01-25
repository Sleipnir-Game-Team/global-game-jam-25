## Logging 
##
## AutoLoad para logging da sleipnir
extends Node


enum LogLevel {all,debug,info,warn,error,fatal,off}  

func _init():
	pass

## Indicação sobre algo acontecendo.[br]
## Por exemplo, se algo entrou ou saiu da cena, se algum recurso foi criado, não algo muito profundo
func info(message: String) -> void:
	print_rich("[color=cyan]INFO: [",
	_get_script_name(get_stack()[1]["source"]),"][/color][color=light_blue] ",message,"[/color]")

## Diagnóstico geral.[br]
## Por exemplo, se uma variável mudou de estado, se uma função foi chamada, com bastante detalhe geralmente
func debug(message: String) -> void:
	print_rich("[color=green]DEBUG: [",
	_get_script_name(get_stack()[1]["source"]),"][/color][color=gray] ",message,"[/color]")

## Indicação de risco em potêncial.[br]
## Por exemplo, uma variável assumiu um valor que não devia, falta de algum recurso que pode levar a erro[br]
## Não requer um [code]get_stack()[/code] ao ser chamado, porém pode ser usado.[br]
## [codeblock]
## Logger.warn("messagem", true)
## #ou
## Logger.warn("mensagem")
## [/codeblock]
func warn(message: String, print_stack: bool = false) -> void:
	if print_stack == false:
		push_warning("[",_get_script_name(get_stack()[1]["source"]),"] ",message)
	else:
		var where_went_wrong : String
		var source_script : String
		var stack_trace : Array[Dictionary] = get_stack()
		stack_trace.remove_at(0)
		
		for i in range(0,stack_trace.size()):
			var stack : Dictionary = stack_trace[i]
			where_went_wrong = where_went_wrong + stack["source"] + ": line " + str(stack["line"]) \
			+  " in function " + stack["function"] + "\n"
			if i == 0:
				source_script = _get_script_name(stack["source"])
		push_warning("[",source_script,"] ",message,"\n check: \n", where_went_wrong)

## Indicação de um problema que deve ser resolvido, mas não "irei crashar" nível de sério.[br]
## Por exemplo, uma função que cuida da AI dos inimigos do nada jogando eles pra fora do mapa[br]
## requer um [code]get_stack()[/code] ao ser chamado.[br]
## [codeblock]
## Logger.error("mensagem")
## [/codeblock]
func error(message: String) -> void:
	var where_went_wrong : String
	var source_script : String
	var stack_trace : Array[Dictionary] = get_stack()
	stack_trace.remove_at(0)
	
	for i in range(0,stack_trace.size()):
		var stack : Dictionary = stack_trace[i]
		where_went_wrong = where_went_wrong + stack["source"] + ": line " + str(stack["line"]) \
		+  " in function " + stack["function"] + "\n"
		if i == 0:
			source_script = _get_script_name(stack["source"])
			
	push_error("[",source_script,"] ",message,"\n try checking: \n", where_went_wrong)

## Indicação de que deu um problema que para o programa, erro irrecuperavel.[br]
## Por exemplo, uma coisa que não devia dar errado de jeito nenhum dando errado[br]
## requer um [code]get_stack()[/code] ao ser chamado.[br]
## [codeblock]
## Logger.fatal("mensagem")
## [/codeblock]
func fatal(message: String) -> void:
	var where_went_wrong : String
	var source_script : String
	var stack_trace : Array[Dictionary] = get_stack()
	stack_trace.remove_at(0)
	
	for i in range(0,stack_trace.size()):
		var stack : Dictionary = stack_trace[i]
		where_went_wrong = where_went_wrong + stack["source"] + ": line " + str(stack["line"]) \
		+  " in function " + stack["function"] + "\n"
		if i == 0:
			source_script = _get_script_name(stack["source"])
	
	print_rich("[bgcolor=red][color=black]FATAL: [",source_script,"][/color][/bgcolor][color=red] ",message,"\n located at: \n",
	 where_went_wrong,"[/color]")

## @experimental
## cria um pop up de alerta do sistema 
## pode não ser util
func pop_up_alert(title:String,message:String) ->void:
	var source_script : String
	var stack_trace : Array[Dictionary] = get_stack()
	stack_trace.remove_at(0)
	
	for i in range(0,stack_trace.size()):
		var stack : Dictionary = stack_trace[i]
		if i == 0:
			source_script = _get_script_name(stack["source"])
	OS.alert("["+source_script+"] "+message,title)

func _get_script_name(stack_info:String):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9-_.]+(\\.gd)")	
	return regex.search(stack_info).get_string().split(".")[0]

## @experimental
## cria uma tela de erro
## Ainda bem arcaica, se quiser usar está disponivel, porém mudanças serão feitas
func load_error_screen(type: String="Error", message:String="Unexpected Error Happened") -> void:
	#var errorscene = preload("error_screen/error_screen.tscn")
	#var Error = errorscene.instantiate() as ErrorScreen
	#get_tree().root.add_child(Error)
	#Error.ErrorMessage.text = message
	var attributes: Dictionary = {}
	attributes["Tipo"] = type
	attributes["Mensagem"] = message
	UI_Controller.openScreen("res://ui/error/error_screen.tscn", get_tree().root, attributes)
	

## @experimental
## Cria o arquivo de log com tudo dentro
func create_log_file(): # TODO
	pass
