extends Camera3D

#TODO write docs for this rotation angle lerp
@export var player: Node3D
@export var camera_pivot: Node3D
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

#TODO rename this - what are the wrapping points?
@export var camera_damping = 0.25

@onready var spring_arm = camera_pivot.get_node("SpringArm3D")
@onready var spring_arm_start_length = spring_arm.spring_length
@onready var spring_arm_start_x = spring_arm.position.x
@onready var camera_pivot_rotation_goal := Vector3(camera_pivot.rotation)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spring_arm.add_excluded_object(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## During dialogue change spring arm pivot and zoom
	if Global.is_dialogue_active():
		spring_arm.spring_length = lerp(spring_arm.spring_length, spring_arm_start_length - 1.0, 0.1)
		spring_arm.position.x = lerp(spring_arm.position.x, spring_arm_start_x + 0.5, 0.1)
	else:
		spring_arm.spring_length = lerp(spring_arm.spring_length, spring_arm_start_length, 0.1)
		spring_arm.position.x = lerp(spring_arm.position.x, spring_arm_start_x, 0.1)
	
	## Rotate towards our goal
	camera_pivot.rotation = camera_pivot.rotation.lerp(camera_pivot_rotation_goal, camera_damping)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_pivot_rotation_goal.y += -event.relative.x * mouse_sensitivity
		camera_pivot_rotation_goal.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		camera_pivot_rotation_goal.x = clampf(camera_pivot_rotation_goal.x, -tilt_limit, tilt_limit)
