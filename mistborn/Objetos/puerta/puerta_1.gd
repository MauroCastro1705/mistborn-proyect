extends Node2D
@onready var label: Label = $Label
var keys_found:int
var keys_to_find:int
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	collision_shape_2d.disabled = false

func update_label(found:int, to_find:int):
	label.text = str(found) + " / " + str(to_find)

func open_door():
	collision_shape_2d.disabled = true
