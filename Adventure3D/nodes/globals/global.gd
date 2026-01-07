extends Node

var dialogue_instance
var quests = {}
var dialogue_selected = []

signal character_emote(character_name: String, emote: String)
signal character_animation(character_name: String, animation: String)

func set_quest(quest_name: String, value: int):
	pass

func set_dialogue_selected(selection: String):
	dialogue_selected.push_back(selection)

func get_dialogue_selected(selection: String):
	return not dialogue_selected.has(selection)

func get_quest(quest_name: String):
	if quest_name in quests:
		return quests[quest_name]
	else:
		return false

func is_dialogue_active():
	return is_instance_valid(dialogue_instance)

func create_dialogue(dialogue_resource: Resource, title: String):
	if not is_dialogue_active():
		dialogue_instance = DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
		return dialogue_instance
	return null

func end_current_dialogue():
	dialogue_instance.queue_free()

func turn_node_towards(node, direction, weight):
	#returns the angle in radians that a vector is pointing at
	var theta = atan2(-direction.x, -direction.z)
	node.rotation.y = lerp_angle(node.rotation.y, theta, weight)
