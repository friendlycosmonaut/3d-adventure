class_name Save

## The following class functions provide:
## 1. Read/Write to the player's Save folder
## 2. Read Resources from project folder
## Godot supplies JSON encoding and parsing, used here for save/load
## You may want to explore encryption & other formats for large or sensitive data

## Creates a file at the given path containing dictionary data
## You do not need to include ".json" in the path name; this is appended 
## Example: creates items.json containing an inventory dictionary
## save_data({ item: "banana" }, "items")
static func save_to_json(dict: Dictionary, path: String) -> void:
	path += ".json"
	var data = JSON.stringify(dict, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)

## Loads a dictionary from the given path
## Consider using load_data for gameplay to ensure consistency
## Will return an empty dictionary if no file is found
## If you do not specify full path, it will default to the project path
static func load_from_json(path) -> Dictionary:
	path += ".json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var text = file.get_as_text()
		var data = JSON.parse_string(text)
		return data
	else:
		return {}

## Wipes everything in the user's save area
static func global_wipe() -> void:
	if DirAccess.dir_exists_absolute(""):
		_remove_recursive("")

## Recursively removes all content from a given folder/path
static func _remove_recursive(path: String) -> void:
	var directory = DirAccess.open(path)
	
	## List directory content
	directory.list_dir_begin()
	var file_name = directory.get_next()
	while file_name != "":
		if directory.current_is_dir():
			_remove_recursive(path + "/" + file_name)
		else:
			directory.remove(file_name)
		file_name = directory.get_next()
	directory.remove(path)
