extends Area2D

signal target_changed(new_target: Node2D, prev_target: Node2D)
signal metal_target(body: Node2D)
signal caja_target(body: Node2D)

@export var candidate_groups: Array[String] = ["metal", "cajas"]
@export var mouse_picker_path: NodePath

var _candidates: Array[Node2D] = []              # who is INSIDE the area
var _current: Node2D = null
var _picker: Node = null

@onready var _player := get_parent() as Node2D

func _ready() -> void:
	monitoring = true
	if mouse_picker_path != NodePath():
		_picker = get_node(mouse_picker_path)
		if _picker and _picker.has_signal("hover_changed"):
			_picker.hover_changed.connect(_on_hover_changed)

func _physics_process(_delta: float) -> void:
	# purge invalids; keeps the list clean
	for i in range(_candidates.size() - 1, -1, -1):
		if not is_instance_valid(_candidates[i]):
			_candidates.remove_at(i)
	_update_preferred_target()


func _on_body_entered(body: Node2D) -> void:
	if _is_candidate(body):
		if not _candidates.has(body):
			_candidates.append(body)
		_update_preferred_target()

func _on_body_exited(body: Node2D) -> void:
	# 1) remove from the inside list
	_candidates.erase(body)

	# 2) if that body was current, clear it
	if body == _current:
		var prev := _current
		_current = null
		target_changed.emit(null, prev)
		# (optional) tell listeners to reset state (e.g., hide UI / reset dash flags)

	# 3) if mouse/lock is tracking that body, ignore it now
	if _picker and _picker.has_method("get_hover"):
		var h = _picker.get_hover()
		if h == body:
			# let _update_preferred_target() pick a new one or null
			pass

	_update_preferred_target()

func _on_hover_changed(_new: Node2D, _prev: Node2D) -> void:
	_update_preferred_target()

func _is_candidate(body: Node2D) -> bool:
	if body == null or not is_instance_valid(body):
		return false
	for g in candidate_groups:
		if body.is_in_group(g):
			return true
	return false

func _update_preferred_target() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	# --- prioritize mouse ONLY if it is also inside the area ---
	var prefer: Node2D = null
	if _picker and _picker.has_method("get_hover"):
		var hovered = _picker.get_hover()
		if hovered and is_instance_valid(hovered) and _candidates.has(hovered):
			prefer = hovered

	# --- else pick nearest among INSIDE candidates ---
	if prefer == null:
		var best: Node2D = null
		var best_d2 := INF
		var p := _player.global_position
		for b in _candidates:
			if not is_instance_valid(b):
				continue
			var d2 := p.distance_squared_to(b.global_position)
			if d2 < best_d2:
				best_d2 = d2
				best = b
		prefer = best

	if prefer != _current:
		var prev := _current
		_current = prefer
		target_changed.emit(_current, prev)
		if _current != null:
			if _current.is_in_group("metal"):
				metal_target.emit(_current)
			elif _current.is_in_group("cajas"):
				caja_target.emit(_current)
