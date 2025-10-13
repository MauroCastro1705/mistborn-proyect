extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("detecte jugador")
		restart()

func restart():
	await get_tree().process_frame
	get_tree().reload_current_scene()
