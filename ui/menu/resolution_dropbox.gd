extends OptionButton

var resolution_ids := {[1920,1080] : 1, [1600, 900] : 2, [1366, 768] : 3, [1280, 720] : 4}
var pc_resolution := Config_Handler.pc_resolution

func _ready() -> void:
	Config_Handler.window_resolution_changed.connect(_on_window_resolution_changed)
	var actual_resolution := [pc_resolution[0], pc_resolution[1]]
	var actual_resolution_text := "%s x %s" %[actual_resolution[0], actual_resolution[1]]
	resolution_ids[actual_resolution] = 0
	add_item(actual_resolution_text, 0)
	for resolution:Array in resolution_ids.keys():
		if resolution_ids[resolution] != 0:
			add_item("%s x %s"%[resolution[0], resolution[1]], resolution_ids[resolution])


func _on_window_resolution_changed(resolution: Array) -> void:
	select_item([resolution[0], resolution[1]])

func select_item(resolution: Array) -> void:
	var selected_index := get_item_index(resolution_ids[resolution])
	select(selected_index)
	

func get_selected_item(index: int) -> Variant:
	return resolution_ids.find_key(get_item_id(index))
