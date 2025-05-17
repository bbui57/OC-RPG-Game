extends Node

var selected_character = 0

var characters = {
	0: "res://scenes/yuxiel.tscn",
	1: "res://scenes/zach.tscn",
	2: "res://scenes/ciri.tscn",
	3: "res://scenes/brim.tscn"
}

var char_names = {
	0: "Yuxiel",
	1: "Zach",
	2: "Ciri",
	3: "Brim"
}

func _ready():
	get_window().connect("size_changed", _on_window_resized)

func _on_window_resized():
	var window_size = get_window().size
	var ui_root = get_node_or_null("/root/GameUI") # Ensure GameUI exists
	if ui_root:
		ui_root.rect_min_size = window_size # Resize UI dynamically
