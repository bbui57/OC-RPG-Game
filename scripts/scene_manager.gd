extends Node

func change_scene(new_scene_path):
	var new_scene = load(new_scene_path).instantiate()
	get_tree().get_root().add_child(new_scene)
	
	for child in get_tree().get_root().get_children():
		if child.name == "CurrentScene":
			child.queue_free()
			
	new_scene.name = "CurrentScene"
