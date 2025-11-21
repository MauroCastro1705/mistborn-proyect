extends Area2D
signal hover_changed(new_hover: Node2D, prev_hover: Node2D)

@export var candidate_groups: Array[String] = ["metal", "cajas"]

var _hover: Node2D = null

func _ready() -> void:
	monitoring = true
	input_pickable = false  # not needed since we use physics
	
func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _on_body_entered(body: Node2D) -> void:
	if _is_candidate(body):
		if _hover == null:
			_set_hover(body)

func _on_body_exited(body: Node2D) -> void:
	if body == _hover:
		var prev := _hover
		_hover = null
		hover_changed.emit(null, prev)

func _is_candidate(body: Node2D) -> bool:
	if body == null or not is_instance_valid(body):
		return false
	for g in candidate_groups:
		if body.is_in_group(g):
			return true
	return false

func _set_hover(b: Node2D) -> void:
	if b == _hover:
		return
	var prev := _hover
	_hover = b
	hover_changed.emit(_hover, prev)

func get_hover() -> Node2D:
	return (_hover if is_instance_valid(_hover) else null)
