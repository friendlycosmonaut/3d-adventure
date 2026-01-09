extends MarginContainer
@export var resolutions_array : Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(960, 540),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2048, 1152),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]

## Gameplay
func _on_fov_slider_value_changed(value: float) -> void:
	$Camera.fov = value

# Mouse Sensitivity

# Invert Mouse Y Axis

## Audio
func _on_volume_slider_changed(value):
	AudioServer.set_bus_volume_db(0, value)

## Display
func _ui_scale(index):
	# For changing the UI, we take the viewport size, which we set in the project settings.
	var new_size
	if index == 0: # Smaller (66%)
		new_size *= 1.5
	elif index == 1: # Small (80%)
		new_size *= 1.25
	elif index == 2: # Medium (100%) (default)
		new_size *= 1.0
	elif index == 3: # Large (133%)
		new_size *= 0.75
	elif index == 4: # Larger (200%)
		new_size *= 0.5
	get_tree().root.set_content_scale_size(new_size)

func _on_quality_slider_value_changed(value: float) -> void:
	get_viewport().scaling_3d_scale = value

func _set_max_fps_spinbox(value):
	Engine.set_max_fps(value)

func _on_window_mode(value):
	#WindowMode.WINDOW_MODE_WINDOWED = 0
	#WindowMode.WINDOW_MODE_MINIMIZED = 1
	#WindowMode.WINDOW_MODE_MAXIMIZED = 2
	#WindowMode.WINDOW_MODE_FULLSCREEN = 3
	DisplayServer.window_set_mode(value)

func _on_vsync_toggle(value):
	#VSyncMode.VSYNC_DISABLED = 0
	#VSyncMode.VSYNC_ENABLED = 1
	#VSyncMode.VSYNC_ADAPTIVE = 2
	DisplayServer.window_set_vsync_mode(value)

func _on_resolutions_item_selected(text: String):
	# The resolution options are written in the form "XRESxYRES".
	# Using `split_floats` we get an array with both values as floats.
	var values := text.split_floats("x")
	var resolution = Vector2i(values[0], values[1])
	DisplayServer.window_set_size(resolution)
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, settings.resolution)
