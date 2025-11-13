extends Control

@onready var score: Label = %score
@onready var key: TextureRect = %key
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	Global.score_update.connect(_update_label)
	Global.door_unlocked.connect(_activate_key)
	_update_label()
	turn_keys_to_black(key)
	animation_player.play("key_rotation")
	
	
func _update_label():
	score.text = "Score: " + str(Global.player_score) 

func turn_keys_to_black(someKey:TextureRect):
	someKey.modulate = Color(0.1,0.1,0.1,1)

func turn_key_to_normal(oneKey: TextureRect):
	oneKey.modulate = Color(1,1,1,1)

func _activate_key():
	turn_key_to_normal(key)
