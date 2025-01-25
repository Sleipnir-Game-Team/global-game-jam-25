extends Node

var json_content: Dictionary
var paste_path := 'res://Jsons/'
var taste: Variant

enum taste_value {
	FOAM = 8,
	MILK = 4,
	SUGAR = 2,
	COLD = 1
}

func  retrive_taste(taste_owner: String) -> Variant:
	var file_path := paste_path + taste_owner + '.json'
	taste = JsonHandler.acesse_json_file(file_path)
	return taste

func save_taste(tastes: Dictionary, taste_owner: String) -> void:
	var file_path := paste_path + taste_owner + '.json'
	JsonHandler.save_on_json_file(file_path, tastes)
	
func create_taste(cold: bool, sugar: bool, milk: bool, foam: bool, taste_owner: String) -> Dictionary:
	var taste_data := {
		"owner": taste_owner,
		"taste": {
			taste_value.COLD: cold,
			taste_value.MILK: milk,
			taste_value.SUGAR: sugar,
			taste_value.FOAM: foam
		}
	}
	
	return taste_data
