extends Node

var story: InkStory

func select_option(choice_index: int) -> void:
	story.ChooseChoiceIndex(choice_index)
	
func continue_story() -> Variant:
	var content := story.Continue()
	return content
	
func go_to_scene(scene_path: String) -> void:
	story.ChoosePathString(scene_path)
	
func choice_handler() -> Array:
	var options := story.GetCurrentChoices()
	return options	
