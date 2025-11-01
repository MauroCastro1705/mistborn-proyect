extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_update_score_and_screen()

func _update_score_and_screen():
	Global.score_update.emit()
	print("señal emitida en pickup")
	queue_free()
