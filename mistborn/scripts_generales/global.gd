extends Node
signal score_update
signal level_restarted
signal door_unlocked
signal key_grabbed

var player_score:int = 0
var can_push:bool = false
var can_pull:bool = true

var key_1_id
var key_2_id
var key_3_id
var keys_found:int = 0
var keys_in_lvl_1:int = 2


func _ready() -> void:
	score_update.connect(_logica_score)
	level_restarted.connect(_restart_level)
	door_unlocked.connect(unlock_current_door)
	key_grabbed.connect(se_agarro_llave)
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

func unlock_current_door():
	pass
	
func se_agarro_llave():
	if keys_found <= keys_in_lvl_1:
		keys_found += 1
	if keys_found == keys_in_lvl_1:
		emit_signal("door_unlocked")
	
