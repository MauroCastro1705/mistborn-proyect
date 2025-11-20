extends Node2D
@onready var label: Label = $Label
var keys_found:int
var keys_to_find:int
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	collision_shape_2d.disabled = false
	Global.key_grabbed.connect(check_keys)
	Global.door_unlocked.connect(open_door)
	find_keys()
	
	
func find_keys():
	keys_found = Global.keys_found
	keys_to_find = Global.keys_in_lvl_1
	update_label()

func update_label():
	label.text = str(keys_found) + " / " + str(keys_to_find)

func check_keys():
	update_label()

func open_door():
	collision_shape_2d.disabled = true
