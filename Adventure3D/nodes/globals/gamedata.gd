extends Node

var data = {}

## Sets a data value with the given property name
func set_data(property: String, value: Variant):
	data[property] = value

## Returns a data value of the given property name
## If no data with the given property name exists, returns null
func get_data(property) -> Variant:
	if property in data:
		return data[property]
	else:
		return null
