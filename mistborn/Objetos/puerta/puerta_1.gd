extends Node2D
##puerta del nivel
##metodos : door_opened:bool, update_label(int, int) y open_door()
@onready var label: Label = $Label
var door_opened := false
@onready var puerta: StaticBody2D = $puerta


func _ready() -> void:
	pass
	
func update_label(found:int, to_find:int):
	label.text = str(found) + " / " + str(to_find)
	print("door label updated")

func open_door():
	door_opened = true
	self.queue_free()
