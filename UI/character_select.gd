extends Control

@onready var preview_sprite = $Panel/PreviewSprite
@onready var preview_art = $Panel/PreviewArt

func _on_yuxiel_button_pressed():
	Global.selected_character = "Yuxiel"
	preview_art.texture = load("res://Entities/Yuxiel/yuxiel_art.png")
	_update_preview()
	
func _on_zach_button_pressed():
	Global.selected_character = "Zach"
	preview_art.texture = load("res://Entities/Zach/zach_art.png")
	_update_preview()
	
func _on_ciri_button_pressed():
	Global.selected_character = "Ciri"
	preview_art.texture = load("res://Entities/Ciri/ciri_art.png")
	_update_preview()

func _on_brim_button_pressed():
	Global.selected_character = "Brim"
	preview_art.texture = load("res://Entities/Brim/brim_art.png")
	_update_preview()
	
func _update_preview():
	preview_sprite.play(Global.selected_character, 0.5)
	preview_sprite.visible = true
	preview_art.visible = true
	$Panel/StartGame.visible = true
	
func _on_start_button_pressed():
	print("Character Selected: " + Global.selected_character)
	get_tree().change_scene_to_file("res://overworld.tscn")
