extends Control

@onready var score: Label = %score
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var key: TextureRect = %key
@onready var key_3: TextureRect = %key_3
@onready var key_2: TextureRect = %key_2

var keys_in_this_level: Array = []
@onready var keys_found:int = 0

func _ready() -> void:
	Global.score_update.connect(_update_label)
	Global.door_unlocked.connect(_activate_key)
	_update_label()
	get_keys_in_this_level()
	what_keys_to_show()
	turn_keys_to_black(keys_in_this_level)
	animation_player.play("key_rotation")


func _update_label():
	score.text = "Score: " + str(Global.player_score) 

func turn_keys_to_black(keys: Array):
	for k in keys:
		k.modulate = Color(0.1,0.1,0.1,1)



func _activate_key():
	var key_to_operate = keys_in_this_level[0]
	turn_key_to_normal(key_to_operate)
	print("key to remove", key_to_operate)
	keys_in_this_level.erase(key_to_operate)
	print(keys_in_this_level)
	
func turn_key_to_normal(oneKey: TextureRect):
	oneKey.modulate = Color(1,1,1,1)


#recordar : esto quiza deberia estar en otro lado
func get_keys_in_this_level():
	match Global.keys_in_lvl_1:
		1: keys_in_this_level = [key]
		2: keys_in_this_level = [key, key_2]
		3: keys_in_this_level = [key, key_2, key_3]

func what_keys_to_show():
	var amount = keys_in_this_level.size()
	match amount:
		1: _show_1key()
		2: _show_2key()
		3: _show_3key()

func _show_1key():
	key.show()
	key_2.hide()
	key_3.hide()

func _show_2key():
	key.show()
	key_2.show()
	key_3.hide()

func _show_3key():
	key.show()
	key_2.show()
	key_3.show()
