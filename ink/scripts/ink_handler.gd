extends Node

@export var story: InkStory

func get_option(choice: Button) -> String:
	var selected_option := choice.text
	return selected_option
	
func continue_story() -> String:
	var content := story.ContinueMaximally()
	return content
	
func go_to_scene(scene_path: String) -> void:
	story.ChoosePathString(scene_path)
	
