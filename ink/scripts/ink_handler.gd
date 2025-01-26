extends Node

signal data_line(data_line_dict: Dictionary)

var story: InkStory

func select_option(choice_index: int) -> void:
	story.ChooseChoiceIndex(choice_index)
	
func continue_story() -> void:
	var content := story.Continue()
	var dict := {}
	
	dict['tags'] = story.GetCurrentTags()
	dict['content'] = story.GetCurrentText()
	
	data_line.emit(dict)
	
func go_to_scene(scene_path: String) -> void:
	story.ChoosePathString(scene_path)
	
func choice_handler() -> void:
	var options := story.GetCurrentChoices()
	var dict := {}
	
	dict['options'] = options
	
	data_line.emit(dict)
	
