extends Camera3D

@export var zoom_speed = 5.0  # ✅ Adjust zoom speed
@export var min_fov = 30.0    # ✅ Prevent excessive zoom-in
@export var max_fov = 90.0    # ✅ Prevent excessive zoom-out

func _input(event):
	if event is InputEventMouseMotion:
		return  # Ignore mouse movement events

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		fov = max(min_fov, fov - zoom_speed)  # ✅ Zoom in

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		fov = min(max_fov, fov + zoom_speed)  # ✅ Zoom out
