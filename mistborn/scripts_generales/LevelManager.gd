extends Node
## Nivel 1
#maneja la info dentro del nivel

@onready var puerta_1: Node2D = %Puerta1
@onready var llave_1= $"../Llave1"
@onready var llave_3= $"../Llave3"
@onready var score_label: Control = %ScoreLabel


@onready var keys_found:int = 0
@onready var keys_to_find:int = Global.keys_in_lvl_1

func _ready():
	llave_1.key_agarrada.connect(_se_agarro_una_llave)
	llave_3.key_agarrada.connect(_se_agarro_una_llave)
	puerta_1.update_label(keys_found, keys_to_find)
	todo_listo()
	
func todo_listo():
	score_label.get_keys_in_this_level()
	
func _se_agarro_una_llave():
	print("LEVEL MANAGER LLAVE")
	score_label._activate_key()
	puerta_1.update_label(keys_found, keys_to_find)
	update_keys_count()
	
func update_keys_count():
	if keys_found < keys_to_find:
		keys_found += 1
	elif keys_found == keys_to_find:
		puerta_1.open_door()
