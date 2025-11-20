extends Area2D
## llave para desbloquear puertas

@onready var animation_player: AnimationPlayer = $AnimationPlayer
signal key_agarrada

func _ready() -> void:
	animation_player.play("llave1")
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		unlock()

func unlock():
	emit_signal("key_agarrada")
	print("se agarro llave")
	queue_free()
	
#recordar: sistema de apertura
