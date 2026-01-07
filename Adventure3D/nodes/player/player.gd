extends CharacterBody3D

enum State {
	None,
	Default,
	Emote
}

@export var MAX_SPEED = 8.0
@export var JUMP_VELOCITY = 6.0
#TODO rename this - is it drag? momentum? 
@export var momentum_scalar = 0.01
# TODO rename this - what are the parameters and wrapping points
@export var turn_scalar = 4.0

@onready var camera_pivot := $CameraPivot
@onready var body = $Mesh/Bee
@onready var anim = body.get_node("AnimationPlayer")

var speed = 0.0
var input_dir
var running = false

var current_state = State.None
var state
var quit_timer = 0.0
var direction = Vector3()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim.set_blend_time("Idle", "Fly", 0.5)
	anim.set_blend_time("Fly", "Idle", 0.5)
	
	change_state(State.Default)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		if Input.is_action_just_pressed("pause"):
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			quit_timer = 0.0
		elif quit_timer > 10.0:
			get_tree().quit()
		else:
			quit_timer += 1.0
	
	state.call(delta)

func change_state(new_state):
	match current_state:
		State.Default:
			pass
		
		State.Emote:
			anim.disconnect("animation_finished", return_to_default_state)

	current_state = new_state
	match new_state:
		State.Default:
			state = default_state
		
		State.Emote:
			state = emote_state
			anim.play("Clicked")
			anim.connect("animation_finished", return_to_default_state)

func return_to_default_state(_animation):
	change_state(State.Default)

func emote_state(delta):
	pass

func default_state(delta):
	if is_on_floor():
		if Input.is_action_just_pressed("emote"):
			change_state(State.Emote)
			return
	else:
		velocity = lerp(velocity, Vector3.ZERO, 0.1)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir:
		direction = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_floor():
			speed = lerpf(speed, 0.0, 0.1)
		else:
			speed = lerpf(speed, MAX_SPEED, 0.02)
	else:
		speed = lerpf(speed, 0.0, 0.1)
	
	# Handle fly.
	var x_rotation = speed * 0.05
	if Input.is_action_pressed("fly"):
		velocity.y = lerp(velocity.y, JUMP_VELOCITY, 0.1)
		body.global_rotation.x = lerp_angle(body.global_rotation.x, x_rotation - 0.2, 0.05)
	elif not is_on_floor() and Input.is_action_pressed("sink"):
		velocity.y = lerp(velocity.y, -JUMP_VELOCITY, 0.1)
		body.global_rotation.x = lerp_angle(body.global_rotation.x, x_rotation + 0.2, 0.05)
	else:
		body.global_rotation.x = lerp_angle(body.global_rotation.x, x_rotation, 0.07)
		# Add the gravity.
		velocity += get_gravity() * delta
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if velocity and direction:
		#TODO implement "old" way of turning
		#body.look_at(global_position + direction)
		#body.rotation.x = 0
		#TODO define turn_scalar -- note this seems to wrap at a certain point
		#define specifically what the value is
		turn_towards(body, direction, delta * turn_scalar)
	else:
		#TODO tidy this! we cannot just do velocity.move_toward because the y
		# is not relevant. we need to exclude it
		#Come to a stop - but only on the x and z
		velocity.x = move_toward(velocity.x, 0.0, momentum_scalar)
		velocity.z = move_toward(velocity.z, 0.0, momentum_scalar)
	
	# Handle animations
	if is_on_floor():
		if(input_dir == Vector2.ZERO):
			if anim.current_animation != "Idle": 
				anim.play("Idle")
		else:
			if anim.current_animation != "Idle": 
				anim.play("Idle")
	else:
		if anim.current_animation != "Fly": 
			anim.play("Fly")
	
	move_and_slide()

func turn_towards(node, direction, weight):
	#returns the angle in radians that a vector is pointing
	#Note that it is atan2(y, x)
	var theta = atan2(-direction.x, -direction.z)
	node.rotation.y = lerp_angle(node.rotation.y, theta, weight)
