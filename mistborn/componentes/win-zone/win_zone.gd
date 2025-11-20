extends Area2D

const WIN_LEVEL := "res://Escenas/win_level/win_level.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player gano")
		call_deferred("_change_scene_win")
		

func _change_scene_win() -> void:
	get_tree().change_scene_to_file(WIN_LEVEL)
