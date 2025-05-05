extends Node

var selected_character = "Yuxiel"

var characters = {
	"Yuxiel": "res://Entities/Yuxiel/yuxiel.tscn",
	"Zach": "res://Entities/Zach/zach.tscn",
	"C'iri": "res://Entities/Ciri/ciri.tscn",
	"Brim": "res://Entities/Brim/brim.tscn"
}

func _ready():
	get_window().connect("size_changed", _on_window_resized)

func _on_window_resized():
	var window_size = get_window().size
	var ui_root = get_node_or_null("/root/GameUI") # Ensure GameUI exists
	if ui_root:
		ui_root.rect_min_size = window_size # Resize UI dynamically
