extends Node

func acesse_json_file(file_path: String) -> Variant:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var content : Variant = JSON.parse_string(file.get_as_text())
	return content
	
func save_on_json_file(file_path: String,data: Variant) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	file = null
