extends VBoxContainer

@export var current_story: InkStory

var is_in_a_choice := false
var story_data: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InkHandler.story = current_story
	InkHandler.data_line.connect(retrive_story_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Avançar Texto") and !is_in_a_choice:
		story_simulation()
		
func retrive_story_data(dict: Dictionary) -> void:
	story_data = dict
		
func on_button_pressed_event(choice: InkChoice) -> void:
	InkHandler.select_option(choice.GetIndex())
	story_simulation()
	is_in_a_choice = false
	
	
func story_simulation() -> void:
	for child: Node in get_children():
		child.queue_free()
		
	var content := Label.new()
	InkHandler.continue_story()
	content.text = story_data['content']
	add_child(content)
	
	InkHandler.choice_handler()
	if story_data['options'].size() > 0:
		for choice: InkChoice in story_data['options']:
			is_in_a_choice = true
			var button := Button.new()
			button.text = choice.GetText()
			
			button.pressed.connect(on_button_pressed_event.bind(choice))	
			
			add_child(button)
