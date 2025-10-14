extends CharacterBody2D

@onready var ui_controls: Control = $UiControls

@export var move_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var fast_fall_multiplier: float = 1.8
@export var max_fall_speed: float = 500.0

# "Dash" magnético
@export var pull_speed: float = 900.0
@export var push_speed: float = 900.0
@export var dash_time: float = 0.18 # duración del impulso
@export var pull_stop_distance: float = 24.0   # distancia para cortar el pull al llegar
@export var post_dash_cooldown: float = 0.18 
@export var ground_accel: float = 3000.0
@export var air_accel: float = 1500.0
@export var friction: float = 2500.0

# Estado de dash
var is_dashing: bool = false
var dash_dir: Vector2 = Vector2.ZERO
var dash_speed: float = 0.0
var dash_elapsed: float = 0.0
var post_dash_timer: float = 0.0

var metal_body: Node2D = null
var metal_box: Node2D = null
var can_dash: bool = false
var can_push_box:bool = false
var es_liviano:bool = false
var es_pesado:bool = false
var push_box_force:float = 1000

@onready var sensor_metales: Area2D = $sensor_metales
@onready var sensor_metales_shape: CollisionShape2D = $sensor_metales/collisionShape
@export var mostrar_sensor_debug: bool = true
var color_sensor: Color = Color(0.2, 0.6, 1.0, 0.3) # azul transparente


@onready var line: Line2D = $Line2D


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var run_threshold: float = 12.0   # velocidad mínima en X para considerar "run"
@export var use_flip_h: bool = true       # girar el sprite según dirección


func _ready() -> void:
	line.visible = false
	line.clear_points()
	ui_controls.hide()
	
func _process(_delta: float) -> void:
	if mostrar_sensor_debug:
		queue_redraw()
		
func _physics_process(delta: float) -> void:
	if is_dashing:
		# --- Movimiento exclusivo del dash ---
		dash_elapsed += delta
		velocity = dash_dir * dash_speed

		# Si es PULL y ya estamos muy cerca del metal → cortar
		if is_instance_valid(metal_body) and dash_speed == pull_speed:
			var dist := global_position.distance_to(metal_body.global_position)
			if dist <= pull_stop_distance:
				_stop_dash()

		# Cortar por tiempo
		if dash_elapsed >= dash_time:
			_stop_dash()

	else:
		# --- Post dash: conservar inercia y dirección original ---
		if post_dash_timer > 0.0:
			post_dash_timer -= delta
			# Sin input horizontal. Solo gravedad y rozamiento leve.
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0.0, friction * delta * 0.25)

		else:
			# Movimiento normal con aceleración progresiva
			var input_direction := Input.get_axis("left", "right")
			var target_speed := input_direction * move_speed

			var accel: float
			if is_on_floor():
				accel = ground_accel
			else:
				accel = air_accel

			velocity.x = move_toward(velocity.x, target_speed, accel * delta)

			# Disparadores pull/push
			if Input.is_action_just_pressed("pull"):
				_start_pull()
			elif Input.is_action_just_pressed("push"):
				_start_push()

		# --- Gravedad y salto ---
		if is_on_floor():
			if post_dash_timer <= 0.0 and Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
			elif post_dash_timer > 0.0:
				velocity.x = move_toward(velocity.x, 0.0, friction * delta * 0.25)
		else:
			if velocity.y > 0.0:
				velocity.y += gravity * fast_fall_multiplier * delta
			else:
				velocity.y += gravity * delta

			if velocity.y > max_fall_speed:
				velocity.y = max_fall_speed

	# --- Línea al metal ---
	if is_instance_valid(metal_body) and can_dash:
		line.visible = true
		line.points = [Vector2.ZERO, to_local(metal_body.global_position)]
	else:
		line.visible = false
		line.clear_points()
		

	move_and_slide()
	var input_axis := Input.get_axis("left", "right")
	_update_animation(input_axis)

func _start_pull() -> void:
	if not (can_dash and is_instance_valid(metal_body)):
		return
	var dir := (metal_body.global_position - global_position).normalized()
	_begin_dash(dir, pull_speed)

func _start_push() -> void:
	if not (can_dash and is_instance_valid(metal_body)):
		return
	if can_dash and es_pesado:
		var dir := (global_position - metal_body.global_position).normalized()
		_begin_dash(dir, push_speed)
	elif can_push_box and es_liviano and is_instance_valid(metal_box):
		var dir := (metal_box.global_position - global_position).normalized() # del jugador a la caja
		_push_boxes(dir, metal_box)

func _push_boxes(dir, body:RigidBody2D):
	var impulse = dir * push_box_force
	body.apply_impulse(impulse)
	body.apply_torque_impulse(impulse.length() * 0.1)

	print("Empujando caja:", body.name, " con impulso ", impulse)

func _begin_dash(dir: Vector2, speed: float) -> void:
	is_dashing = true
	dash_dir = dir
	dash_speed = speed
	dash_elapsed = 0.0
	velocity.y = 0.0

func _stop_dash() -> void:
	is_dashing = false
	post_dash_timer = post_dash_cooldown

# Señales del sensor de metales (Area2D)
func _on_sensor_metales_body_entered(body: Node2D) -> void:
	ui_controls.show()
	if body.is_in_group("metal"):
		_entro_metal(body)
		if body.is_in_group("pesado"):
			es_pesado = true
			print("es pesado" , body)
	if body.is_in_group("cajas"):
		_entro_caja(body)
		body.sleeping = false
		if body.is_in_group("liviano"):
			es_liviano = true
			print("es liviano" , body)

func _on_sensor_metales_body_exited(body: Node2D) -> void:
	ui_controls.hide()
	if body == metal_body:
		_salio_metal(body)
		if body.is_in_group("pesado"):
			es_pesado = false
	if body == metal_box:
		metal_box = null
		if body.is_in_group("liviano"):
			es_liviano = false
		
func _entro_metal(body):
	can_dash = true
	metal_body = body
	line.visible = true

func _salio_metal(_body):
	metal_body = null
	can_dash = false
	line.visible = false
	line.clear_points()

func _entro_caja(body:RigidBody2D):
	metal_box = body
	can_push_box = true
	print("entro caja" , body.name)


func _draw() -> void:
	if not mostrar_sensor_debug:
		return

	if is_instance_valid(sensor_metales_shape) and sensor_metales_shape.shape is CircleShape2D:
		var circle: CircleShape2D = sensor_metales_shape.shape
		var radius: float = circle.radius

		var offset: Vector2 = sensor_metales.position
		draw_arc(offset, radius, 0.0, TAU, 64, Color(0.2, 0.6, 1.0, 0.1), 2.0)

func _update_animation(input_axis: float) -> void:
	var target := ""
	# Aire primero: decide por velocidad vertical
	if not is_on_floor():
		if velocity.y < 0.0:
			target = "jump"
		else:
			target = "fall"
	else:
		# Piso: ¿se está moviendo en X?
		if abs(velocity.x) > run_threshold or is_dashing:
			target = "run"
		else:
			target = "idle"
	# Evita reinicios constantes si ya está en esa anim
	if anim.animation != target:
		anim.play(target)
	elif not anim.is_playing():
		anim.play()
	if use_flip_h:# Flip horizontal (opcional)
		var dir := input_axis
		if dir == 0.0 and abs(velocity.x) > 0.01:
			dir = sign(velocity.x)
		if dir != 0.0:
			anim.flip_h = dir < 0.0
