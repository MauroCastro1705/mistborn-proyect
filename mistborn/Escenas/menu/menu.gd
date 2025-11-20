extends Node2D
var version = ProjectSettings.get_setting("application/config/version")
@onready var version_label: Label = $CanvasLayer/version
var mainLevel:PackedScene = preload("res://Escenas/primer_area/nivel 1 - area 1.tscn")
const creditos := "res://Escenas/creditos/creditos.tscn"

func _ready() -> void:
	version_label.text = "Verison: " + str(version)
	
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(mainLevel)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_creditos_pressed() -> void:
	get_tree().change_scene_to_file(creditos)
