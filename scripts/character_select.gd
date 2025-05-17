extends Control

@onready var preview_sprite = $Panel/PreviewSprite
@onready var preview_art = $Panel/PreviewArt

var selected_char

func _on_yuxiel_button_pressed():
	Global.selected_character = 0
	selected_char = "Yuxiel"
	preview_art.texture = load("res://entities/Yuxiel/yuxiel_art.png")
	_update_preview()
	
func _on_zach_button_pressed():
	Global.selected_character = 1
	selected_char = "Zach"
	preview_art.texture = load("res://entities/Zach/zach_art.png")
	_update_preview()
	
func _on_ciri_button_pressed():
	Global.selected_character = 2
	selected_char = "Ciri"
	preview_art.texture = load("res://entities/Ciri/ciri_art.png")
	_update_preview()

func _on_brim_button_pressed():
	Global.selected_character = 3
	selected_char = "Brim"
	preview_art.texture = load("res://entities/Brim/brim_art.png")
	_update_preview()
	
func _update_preview():
	preview_sprite.play(selected_char, 0.5)
	preview_sprite.visible = true
	preview_art.visible = true
	$Panel/StartGame.visible = true
	
func _on_start_button_pressed():
	SceneManager.change_scene("res://scenes/overworld.tscn")
	UI.get_node("HUD").visible = true
