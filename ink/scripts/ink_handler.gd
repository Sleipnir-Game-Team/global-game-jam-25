extends Node

signal data_line(data_line_dict: Dictionary)

var story: InkStory
const story_path := 'res://ink/Teste.ink'

func _ready() -> void:
	var story_instance := preload(story_path)
	story = story_instance
	 
func start_story(scene_path: String) -> void:
	story.ChoosePathString(scene_path)

func select_option(choice_index: int) -> void:
	story.ChooseChoiceIndex(choice_index)
	
func continue_story() -> void:
	var content := story.Continue()
	var dict := {}
	
	dict['type'] = story.GetCurrentTags()
	dict['content'] = story.GetCurrentText()
	
	data_line.emit(dict)
	
func choice_handler() -> void:
	var options := story.GetCurrentChoices()
	var dict := {}
	var options_dict := {}
	
	for choice: InkChoice in options:
		options_dict[choice.GetIndex()] = choice.GetText()
	
	dict['type'] = 'choice'
	dict['content'] = options_dict
	
	data_line.emit(dict)
	
