extends Node3D

enum State {
	None,
	Idle,
	Dialogue,
}

@export var root: Node3D
@export var dialogue: Resource
@export var dialogue_title: String
@export_enum(
	"Sticky", 
	"Sigourney",
	"Frank",
	"Beatrice", 
	"Wiley",
	"Buzzling", 
	"Monty",
) var character_name: String

@onready var interact_radius: Area3D = %InteractRadius
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var idle_rotation: Vector3
var current_state: State = State.None
var state_callable: Callable = _state_empty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	idle_rotation = root.rotation
	
	Global.character_animation.connect(
		func(character: String, animation: String):
			if character == character_name:
				animation_player.play(animation)
	)
	
	change_state(State.Idle)

## Change the current state
func change_state(new_state):
	# Cleanup old state
	match current_state:
		State.Idle:
			pass
		State.Dialogue:
			pass
	
	# Set new state callable
	match new_state:
		State.None:
			state_callable = _state_empty
		State.Idle:
			state_callable = _state_idle
		State.Dialogue:
			state_callable = _state_dialogue
	
	current_state = new_state

## Main process will run the current_state's callable
func _process(delta):
	state_callable.call(delta)

## Empty state - do nothing
static func _state_empty(_delta):
	pass

## Default state
func _state_idle(_delta):
	if not animation_player.is_playing():
		animation_player.play("Idle")
	
	# If player comes close, turn towards them
	var player = _get_nearby_player()
	if player != null: 
		Global.turn_node_towards(root, player - root.global_position, 0.2)
		
		if not Global.is_dialogue_active():
			# If the player is emoting, emote back!
			if Input.is_action_just_pressed("emote"):
				# First wait for a small random amount of time
				var rng = RandomNumberGenerator.new()
				await get_tree().create_timer(rng.randf_range(0.4, 0.8)).timeout
				animation_player.play("Attack")
			if dialogue != null and Input.is_action_just_pressed("interact"):
				Global.create_dialogue(dialogue, dialogue_title)
				change_state(State.Dialogue)
	else:
		# Otherwise, return to rotation at spawning
		root.rotation.y = lerp_angle(root.rotation.y, idle_rotation.y, 0.1)

## Dialogue state
func _state_dialogue(_delta):
	# If no other animation is playing, play idle
	if not animation_player.is_playing():
		animation_player.play("Idle")
	
	# Turn towards player
	if Global.is_dialogue_active():
		var player = _get_nearby_player()
		if player != null: 
			Global.turn_node_towards(root, player - root.global_position, 0.2)
		else:
			# If player walks out, end the dialogue
			Global.end_current_dialogue()
	else:
		change_state(State.Idle)

## Returns the player if they are within character's interact radius, else null
func _get_nearby_player():
	var bodies = interact_radius.get_overlapping_bodies()
	if !bodies.is_empty():
		return bodies[0].global_position
	return null
