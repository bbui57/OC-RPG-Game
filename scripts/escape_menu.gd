extends CanvasLayer

func _input(event):
	if event.is_action_pressed("ui_cancel") and SceneManager.get_scene() == "res://scenes/overworld.tscn": # Escape key
		toggle_pause()

func toggle_pause():
	if Engine.time_scale == 1:
		Engine.time_scale = 0
		visible = true
	else:
		_on_resume_button_pressed()

func _on_resume_button_pressed():
	Engine.time_scale = 1
	visible = false

func _on_quit_button_pressed():
	get_tree().quit()
