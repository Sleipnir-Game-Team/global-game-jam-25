extends VBoxContainer

@export var current_story: InkStory

var is_in_a_choice := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InkHandler.story = current_story

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Avançar Texto") and !is_in_a_choice:
		story_simulation()
		
func on_button_pressed_event(choice: InkChoice) -> void:
	InkHandler.select_option(choice.GetIndex())
	story_simulation()
	is_in_a_choice = false
	
	
func story_simulation() -> void:
	for child: Node in get_children():
		child.queue_free()
		
	var content := Label.new()
	content.text = InkHandler.continue_story()
	add_child(content)
	
	if InkHandler.choice_handler().size() > 0:
		for choice: InkChoice in InkHandler.choice_handler():
			is_in_a_choice = true
			var button := Button.new()
			button.text = choice.GetText()
			
			button.pressed.connect(on_button_pressed_event.bind(choice))
			
			add_child(button)
