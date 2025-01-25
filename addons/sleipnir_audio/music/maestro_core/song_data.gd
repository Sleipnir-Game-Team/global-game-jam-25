## Resource usado no SleipnirMaestro, para facilitar o handling de dados e agilizar tudo
##
## Utilize esse resource para preparar sua música pra ser utilizada no SleipnirMaestro, so cria resource com esse script :)
@tool
class_name SongData
extends Resource
enum _track_transitions {IMMEDIATE,NEXT_BEAT,NEXT_BAR,END}

# exports
var default_first_section : String = "ambient"   
var default_track_transition : _track_transitions
var fade_beats : int = 0
var fade_mode : AudioStreamInteractive.FadeMode
@export_category("Time")
@export var BPM : int = 0
@export var BeatsPerBar : int = 4
@export_category("Data")
@export var MainClips : Resource: ## é foda
	get():
		return MainClips
	set(value):
		if value == MainClips : return
		MainClips = value
		notify_property_list_changed()
@export var TriggerClips : Array[Resource]:
	get:
		return TriggerClips
	set(value):
		TriggerClips = value
		if value != null:
			has_trigger_clips = true
		else:
			has_trigger_clips = false

var has_trigger_clips : bool = false

## Função para pegar os MainClips
func get_main_clips(): 
	return MainClips

## Função para pegar os TriggerClips
func get_trigger_clips() -> Array[Resource]: return TriggerClips

## Função para pegar a primeira sessão da música
func get_first_section() -> String: return default_first_section

func get_sections() -> Dictionary:
	var sections : Dictionary
	for i in range(0,MainClips.clip_count):
		sections.merge({MainClips.get_clip_name(i):i},false)
	return sections

## Função para pegar o método de transição da música
func get_track_transition(): return default_track_transition

## Função para pegar o método de transição da música (detalhado)
func correct_clips_transition() -> Array[Dictionary]:
	var trans_table : Array[Dictionary] 
	var trans_list  : PackedInt32Array = MainClips.get_transition_list()
	for i in range(0,trans_list.size()):
		if i % 2 == 1: # pra n pegar um par inexistente
			continue
		if (
				MainClips.get_transition_from_time(trans_list[i],trans_list[i+1])\
				!= AudioStreamInteractive.TRANSITION_FROM_TIME_NEXT_BAR
			):
			continue
		
		var table_dict : Dictionary ={
			"from_to":[trans_list[i],trans_list[i+1]],
			"from_time":4,
			"to_time":MainClips.get_transition_to_time(trans_list[i],trans_list[i+1]),
			"fade_mode":MainClips.get_transition_fade_mode(trans_list[i],trans_list[i+1]),
			"fade_beats":MainClips.get_transition_fade_beats(trans_list[i],trans_list[i+1]),
			"hold_previous":MainClips.is_transition_holding_previous(trans_list[i],trans_list[i+1])
		}
		if MainClips.is_transition_using_filler_clip(trans_list[i],trans_list[i+1]):
			table_dict.merge({"filler_clip":MainClips.get_transition_filler_clip(trans_list[i],trans_list[i+1])},false)
		else:
			table_dict.merge({"filler_clip":-1},false)
		
		trans_table.append(table_dict)
		
	return trans_table

## Função para pegar o método de fade da música
func get_fade_mode(): return fade_mode

## Função para pegar em quantas beats ela faz esse fade
func get_fade_beats(): return fade_beats

func _get_property_list():
	if Engine.is_editor_hint():
		var properties : Array[Dictionary]
		if MainClips is AudioStreamInteractive:
			properties.append({
				"name": &"Interactivity Control",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			})
			properties.append({
				"name": &"default_first_section",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_DEFAULT
			})
			properties.append({
				"name": &"default_track_transition",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Immediate,Next Beat,Next Bar,End"
			})
			properties.append({
				"name": &"fade_mode",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Disabled,Fade In,Fade Out,CrossFade,Automatic"
			})
			properties.append({
				"name": &"fade_beats",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT
			})
		return properties
