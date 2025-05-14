extends CharacterBody2D

@export var move_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var fast_fall_multiplier: float = 2.0
var max_fall_speed : float = 500.0
var acceleration: float = 10.0
#DASH
@export var dash_force: float = 900.0 # Fuerza del impulso
var metal_body: Node2D = null
var can_dash:bool = false
var is_dashing: bool = false
var target_velocity = Vector2.ZERO
#LI
@onready var line = $Line2D
@onready var player = get_tree().get_nodes_in_group("player")[0]
var metal_position: Vector2 = Vector2.ZERO # Almacena la posición del metal


func _on_ready():
	$texto_metal.visible = false
	
func _physics_process(delta: float) -> void:
	# Entrada horizontal
	var input_direction := Input.get_axis("left", "right")
	velocity.x = input_direction * move_speed
	# Salto
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		if velocity.y > 0:  # Está cayendo
			velocity.y += gravity * fast_fall_multiplier * delta
		else:
			velocity.y += gravity * delta
	 # Limitar velocidad máxima de caída
		velocity.y = min(velocity.y, max_fall_speed)

	move_and_slide()
	# Pull y Push
	if Input.is_action_just_pressed("pull"): 
		pull_towards_metal()
	if Input.is_action_just_pressed("push"):
		push_away_from_metal()
	#dibuja lineas de metales
	if is_instance_valid(metal_body):
		var start_pos = Vector2.ZERO  # Posición local del jugador
		var end_pos = to_local(metal_body.global_position)  # Convertimos posición global a local
		line.points = [start_pos, end_pos]
	else:
		line.clear_points()



func _on_sensor_metales_body_entered(body: Node2D) -> void:
	if body.is_in_group("metal"):
		can_dash = true
		metal_body = body
		if $texto_metal:
			$texto_metal.text = "hay metales"
			$texto_metal.visible = true
		print("hay colision con metal en:", body.global_position)
		line.visible = true

func _on_sensor_metales_body_exited(body: Node2D) -> void:
	if body == metal_body:
		metal_body = null  # Se fue el metal detectado
		can_dash = false
		if $texto_metal:
			$texto_metal.visible = false
		line.visible = false
		line.clear_points()

#FUNCION DE PULL
func pull_towards_metal() -> void:
	if can_dash and metal_body.global_position != Vector2.ZERO:
		var direction: Vector2 = (metal_body.global_position - global_position).normalized()
		direction.y *= 0.5
		direction.x *= 25.5
		velocity = direction * dash_force
		is_dashing = true
		

func push_away_from_metal() -> void:
	if can_dash and metal_body.global_position != Vector2.ZERO:
		var direction: Vector2 = (global_position - metal_body.global_position).normalized()
		direction.y *= 0.5
		direction.x *= 25.5
		velocity = direction * dash_force
		is_dashing = true


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
