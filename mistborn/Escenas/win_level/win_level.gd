extends Node2D
const MAIN_MENU_SCENE := "res://Escenas/menu/menu.tscn"

func _ready() -> void:
	set_process_input(true)	# Atajo: ESC para volver
	
func _on_button_pressed() -> void:
	_go_back()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back()

func _go_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
