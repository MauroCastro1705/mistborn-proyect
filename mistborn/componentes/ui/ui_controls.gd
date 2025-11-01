extends Control
@onready var push: Control = $push
@onready var pull: Control = $pull

func _ready() -> void:
	check_variables()
	
	
	
func check_variables():
	if Global.can_pull:
		pull.show()
	else: pull.hide()
	if Global.can_push:
		push.show()
	else: push.hide()
