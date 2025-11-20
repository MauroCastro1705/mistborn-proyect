extends Resource
class_name DashStats

# "Dash" magnético
@export var pull_speed: float = 900.0
@export var push_speed: float = 900.0
@export var dash_time: float = 0.18 # duración del impulso
@export var pull_stop_distance: float = 24.0   # distancia para cortar el pull al llegar
@export var post_dash_cooldown: float = 0.18 
@export var ground_accel: float = 3000.0
@export var air_accel: float = 1500.0
@export var friction: float = 2500.0

var can_dash: bool = false
var can_push_box:bool = false
var es_liviano:bool = false
var es_pesado:bool = false
@export var push_box_force:float = 1000

# Estado de dash
var is_dashing: bool = false
var dash_dir: Vector2 = Vector2.ZERO
var dash_speed: float = 0.0
var dash_elapsed: float = 0.0
var post_dash_timer: float = 0.0
