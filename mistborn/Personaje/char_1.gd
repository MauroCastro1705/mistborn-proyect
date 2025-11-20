extends CharacterBody2D

@onready var ui_controls: Control = $UiControls
@export var dash:DashStats

@export var move_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var fast_fall_multiplier: float = 1.8
@export var max_fall_speed: float = 500.0

var metal_body: Node2D = null
var metal_box: Node2D = null

@onready var sensor_metales = %sensor_metales
@onready var sensor_metales_shape: CollisionShape2D = $sensor_metales/collisionShape
@export var mostrar_sensor_debug: bool = true
var color_sensor: Color = Color(0.2, 0.6, 1.0, 0.3) # azul transparente
@onready var line: Line2D = $Line2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var run_threshold: float = 12.0   # velocidad mínima en X para considerar "run"
@export var use_flip_h: bool = true       # girar el sprite según dirección
@onready var pick_up_efect: TextureRect = $pick_up_efect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_clear_line_points()
	ui_controls.hide()
	Global.score_update.connect(_flash_effect)
	
func _clear_line_points():
	line.visible = false
	line.clear_points()
	
func _process(_delta: float) -> void:
	if mostrar_sensor_debug:
		queue_redraw()
		
func _physics_process(delta: float) -> void:
	if dash.is_dashing:
		_frenar_dash_segun(delta)
	else:
		_hacer_dash_y_moverse(delta)
		# --- Gravedad y salto ---
		if is_on_floor():
			salto_desde_el_piso(delta)
		else:
			caida_estando_en_aire(delta)
	# --- Línea al metal ---
	_update_line_drawn(metal_body)
	move_and_slide()
	var input_axis := Input.get_axis("left", "right")
	_update_animation(input_axis)

func _update_line_drawn(a_metal_body):
	if is_instance_valid(a_metal_body) and dash.can_dash:
		line.visible = true
		line.points = [Vector2.ZERO, to_local(a_metal_body.global_position)]
	else:
		_clear_line_points()


func salto_desde_el_piso(delta):
	if dash.post_dash_timer <= 0.0 and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	elif dash.post_dash_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, dash.friction * delta * 0.25)
		
func caida_estando_en_aire(delta):
	if velocity.y > 0.0:
		velocity.y += gravity * fast_fall_multiplier * delta
	else:
		velocity.y += gravity * delta
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed
		
func _movimiento_normal(delta):
	# Movimiento normal con aceleración progresiva
	var input_direction := Input.get_axis("left", "right")
	var target_speed := input_direction * move_speed
	var accel: float
	if is_on_floor():
		accel = dash.ground_accel
	else:
		accel = dash.air_accel
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	# Disparadores pull/push
	if Input.is_action_just_pressed("pull"):
		_start_pull()
	elif Input.is_action_just_pressed("push"):
		_start_push()
		
func _frenar_dash_segun(delta):
	# --- Movimiento exclusivo del dash ---
	dash.dash_elapsed += delta
	velocity = dash.dash_dir * dash.dash_speed
	# Si es PULL y ya estamos muy cerca del metal → cortar
	if is_instance_valid(metal_body) and dash.dash_speed == dash.pull_speed:
		stop_dash_por_distancia(metal_body)
	# Cortar por tiempo
	if dash.dash_elapsed >= dash.dash_time:
		_stop_dash()

func stop_dash_por_distancia(a_metal_body):
	var dist := global_position.distance_to(a_metal_body.global_position)
	if dist <= dash.pull_stop_distance:
		_stop_dash()

func _hacer_dash_y_moverse(delta):
	# --- Post dash: conservar inercia y dirección original ---
	if dash.post_dash_timer > 0.0:
		dash.post_dash_timer -= delta
		# Sin input horizontal. Solo gravedad y rozamiento leve.
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, dash.friction * delta * 0.25)
	else:
		_movimiento_normal(delta)



func _start_pull() -> void:
	if not (dash.can_dash and is_instance_valid(metal_body)):
		return
	if Global.can_pull:
		var dir := (metal_body.global_position - global_position).normalized()
		_begin_dash(dir, dash.pull_speed)

func _start_push() -> void:
	if not (dash.can_dash and is_instance_valid(metal_body)):
		return
	if Global.can_push and dash.can_dash and dash.es_pesado:
		var dir := (global_position - metal_body.global_position).normalized()
		_begin_dash(dir, dash.push_speed)
	elif dash.can_push_box and dash.es_liviano and is_instance_valid(metal_box):
		var dir := (metal_box.global_position - global_position).normalized() # del jugador a la caja
		_push_boxes(dir, metal_box)

func _push_boxes(dir, body:RigidBody2D):
	var impulse = dir * dash.push_box_force
	body.apply_impulse(impulse)
	body.apply_torque_impulse(impulse.length() * 0.1)
	print("Empujando caja:", body.name, " con impulso ", impulse)

func _begin_dash(dir: Vector2, speed: float) -> void:
	dash.is_dashing = true
	dash.dash_dir = dir
	dash.dash_speed = speed
	dash.dash_elapsed = 0.0
	velocity.y = 0.0

func _stop_dash() -> void:
	dash.is_dashing = false
	dash.post_dash_timer = dash.post_dash_cooldown

# Señales del sensor de metales (Area2D)
func _on_sensor_metales_body_entered(body: Node2D) -> void:
	ui_controls.show()
	if body.is_in_group("metal"):
		_entro_metal(body)

	if body.is_in_group("cajas"):
		_entro_caja(body)
		body.sleeping = false
		if body.is_in_group("liviano"):
			dash.es_liviano = true
			print("es liviano" , body)

func _on_sensor_metales_body_exited(body: Node2D) -> void:
	ui_controls.hide()
	if body == metal_body:
		_salio_metal(body)
		if body.is_in_group("pesado"):
			dash.es_pesado = false
	if body == metal_box:
		metal_box = null
		if body.is_in_group("liviano"):
			dash.es_liviano = false

func _entro_metal(body):
	dash.can_dash = true
	metal_body = body
	line.visible = true
	if body.is_in_group("pesado"):
		dash.es_pesado = true
		print("es pesado" , body)

func _salio_metal(_body):
	metal_body = null
	dash.can_dash = false
	_clear_line_points()

func _entro_caja(body:RigidBody2D):
	metal_box = body
	dash.can_push_box = true
	print("entro caja" , body.name)


func _draw() -> void:
	if not mostrar_sensor_debug:
		return
	if is_instance_valid(sensor_metales_shape) and sensor_metales_shape.shape is CircleShape2D:
		_dibujar_circulo()
		
func _dibujar_circulo():
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
		if abs(velocity.x) > run_threshold or dash.is_dashing:
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

func _flash_effect():
	animation_player.play("flash_effect")
