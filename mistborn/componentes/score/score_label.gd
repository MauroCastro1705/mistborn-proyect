extends Control
@onready var label: Label = $Label

func _ready() -> void:
	Global.score_update.connect(_update_label)
	_update_label()
	
func _update_label():
	label.text = "Score: " + str(Global.player_score) 
