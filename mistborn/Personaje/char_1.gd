extends CharacterBody2D

@export var move_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var air_friction: float = 0.8
@export var dash_force: float = 600.0 # Fuerza del impulso
@export var dash_duration: float = 0.3 # Duración del impulso en segundos
@export var fast_fall_gravity_multiplier: float = 2.0
var is_dashing: bool = false
var dash_timer: float = 10.0

func _on_ready():
	$texto_metal.visible = false

func _physics_process(delta: float) -> void:
	if is_dashing:
		dash_timer += delta
		if dash_timer >= dash_duration:
			is_dashing = false
			velocity *= air_friction # Aplicar un poco de fricción al final del dash
		move_and_slide()
		return # No procesar movimiento normal durante el dash

	# Aplicar gravedad (con caída rápida)
	if not is_on_floor():
		if velocity.y > 0: # Si está cayendo
			velocity.y += gravity * fast_fall_gravity_multiplier * delta
		else: # Si está subiendo o en el aire inicialmente
			velocity.y += gravity * delta
		velocity.x *= air_friction
	else:
		velocity.y = 0
	# Capturar entrada horizontal
	var direction: float = Input.get_axis("left", "right")
	velocity.x = direction * move_speed
	# Saltar
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# ---PULL----
	if Input.is_action_just_pressed("pull"): # Asume que tienes una acción "dash" configurada
		pull_towards_mouse()
	#---PUSH----
	if Input.is_action_just_pressed("push"): # Usa la nueva acción aquí
		push_away_from_mouse()
		
	# Mover el personaje
	move_and_slide()

#FUNCION DE PULL
func pull_towards_mouse() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_position - global_position).normalized()
	velocity = direction * dash_force
	is_dashing = true
	dash_timer = 0.0
	#FUNCION DE PUSH
func push_away_from_mouse() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (global_position - mouse_position).normalized() # Invertimos la resta
	velocity = direction * dash_force
	is_dashing = true
	dash_timer = 0.0


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


func _on_sensor_metales_body_entered(body: Node2D) -> void:
	if body.is_in_group("metal"):
		$texto_metal.text = "hay metales"
		$texto_metal.visible = true
		print("hay colision")

func _on_sensor_metales_body_exited(body: Node2D) -> void:
	if body.is_in_group("metal"):
		$texto_metal.visible = false
		print("ya no hay colision")
