extends Node
signal score_update
signal level_restarted


var player_score:int = 0
var can_push:bool = false
var can_pull:bool = true

var keys_in_lvl_1:int = 2


func _ready() -> void:
	score_update.connect(_logica_score)
	level_restarted.connect(_restart_level)
	_reset_values()
	
	
func _logica_score():
	player_score += 1
	print("señal recibida")
	print("puntos" , player_score)

func _restart_level():
	_reset_values()
	print("reinicio de nivel")


func _reset_values():
	player_score = 0
