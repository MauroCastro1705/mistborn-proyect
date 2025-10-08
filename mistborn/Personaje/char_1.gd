extends CharacterBody2D

@export var move_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var fast_fall_multiplier: float = 2.0
@export var max_fall_speed: float = 500.0
@export var acceleration: float = 10.0

# "Dash" magnético
@export var pull_speed: float = 900.0
@export var push_speed: float = 900.0
@export var dash_time: float = 0.18            # duración del impulso
@export var pull_stop_distance: float = 24.0   # distancia para cortar el pull al llegar

var metal_body: Node2D = null
var can_dash: bool = false

# Estado de dash
var is_dashing: bool = false
var dash_dir: Vector2 = Vector2.ZERO
var dash_speed: float = 0.0
var dash_elapsed: float = 0.0

@onready var line: Line2D = $Line2D
@onready var texto_metal: Label = $texto_metal

func _ready() -> void:
	texto_metal.visible = false
	line.visible = false
	line.clear_points()

func _physics_process(delta: float) -> void:
	if is_dashing:
		# Movimiento exclusivo del dash (sin input ni gravedad)
		dash_elapsed += delta
		velocity = dash_dir * dash_speed

		# Si es PULL y ya estamos muy cerca del metal, cortar
		if is_instance_valid(metal_body) and dash_speed == pull_speed:
			var dist := global_position.distance_to(metal_body.global_position)
			if dist <= pull_stop_distance:
				_stop_dash()

		# Cortar por tiempo
		if dash_elapsed >= dash_time:
			_stop_dash()
	else:
		# INPUT horizontal normal
		var input_direction := Input.get_axis("left", "right")
		velocity.x = input_direction * move_speed

		# Salto + gravedad (con fast-fall)
		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
		else:
			if velocity.y > 0.0:
				velocity.y += gravity * fast_fall_multiplier * delta
			else:
				velocity.y += gravity * delta
			velocity.y = min(velocity.y, max_fall_speed)

		# Disparadores pull/push
		if Input.is_action_just_pressed("pull"):
			_start_pull()
		elif Input.is_action_just_pressed("push"):
			_start_push()

	# Dibujo de línea al metal (localizar a coords locales del jugador)
	if is_instance_valid(metal_body) and can_dash:
		line.visible = true
		line.points = [Vector2.ZERO, to_local(metal_body.global_position)]
	else:
		line.visible = false
		line.clear_points()

	move_and_slide()


func _start_pull() -> void:
	if not (can_dash and is_instance_valid(metal_body)):
		return
	var dir := (metal_body.global_position - global_position).normalized()
	_begin_dash(dir, pull_speed)

func _start_push() -> void:
	if not (can_dash and is_instance_valid(metal_body)):
		return
	var dir := (global_position - metal_body.global_position).normalized()
	_begin_dash(dir, push_speed)

func _begin_dash(dir: Vector2, speed: float) -> void:
	is_dashing = true
	dash_dir = dir
	dash_speed = speed
	dash_elapsed = 0.0

func _stop_dash() -> void:
	is_dashing = false
	dash_dir = Vector2.ZERO
	dash_speed = 0.0
	# opcional: conservar algo de inercia horizontal o frenarlo
	# velocity *= 0.5

# Señales del sensor de metales (Area2D)
func _on_sensor_metales_body_entered(body: Node2D) -> void:
	if body.is_in_group("metal"):
		can_dash = true
		metal_body = body
		if texto_metal:
			texto_metal.text = "hay metales"
			texto_metal.visible = true
		line.visible = true
		print("hay colision con metal en:", body.global_position)

func _on_sensor_metales_body_exited(body: Node2D) -> void:
	if body == metal_body:
		metal_body = null
		can_dash = false
		if texto_metal:
			texto_metal.visible = false
		line.visible = false
		line.clear_points()



	# Opcional: Animaciones
#	var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite")
#	if animated_sprite:
#		if not is_on_floor():
#			if velocity.y < 0:
#				animated_sprite.play("jump")
#			else:
#				animated_sprite.play("fall")
#		elif direction != 0:
#			animated_sprite.play("run")
#		else:
#			animated_sprite.play("idle")
