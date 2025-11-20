extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("llave1")
	
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		unlock()

func unlock():
	Global.emit_signal("key_grabbed")
	print("se agarro llave")
	queue_free()
	
#recordar: sistema de apertura
