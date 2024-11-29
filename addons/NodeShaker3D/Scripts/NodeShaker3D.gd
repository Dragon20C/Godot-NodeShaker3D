@tool
extends Node3D
class_name NodeShaker3D

@export var disable_positional_shake : bool = false
@export var disable_rotational_shake : bool = false
@export var target : Node3D:
	set(value):
		target = value
		inital_position = target.position
		inital_rotation = target.rotation
@export var shake_once : bool = false:
	set(value):
		shake_once = false
		induce_stress()
@export var recovery_speed : float = 1.5
@export var frequency : float = 8.0
@export var trauma_exponent : float = 2.0
@export var positional_scaler : Vector3 =  Vector3(0.5,0.5,0.2)
@export var rotational_scaler : Vector3 = Vector3(0.5,0.5,0.2)
@onready var noise : FastNoiseLite = FastNoiseLite.new()
var inital_position : Vector3 = Vector3.ZERO
var inital_rotation : Vector3 = Vector3.ZERO

var trauma : float = 0.0
var shake : float = 0.0

func _ready() -> void:
	
	randomize()
	noise.seed = randi_range(0,1000)
	noise.frequency = 0.2
	if not Engine.is_editor_hint():
		inital_position = target.position
		inital_rotation = target.rotation

func induce_stress(stress : float = 1.0) -> void:
	trauma += stress
	trauma = clampf(trauma,0.0,1.0)

func _process(delta: float) -> void:
	
	shake = pow(trauma,trauma_exponent)
	
	## Handle Translational shake
	var positional_shake : Vector3 = Vector3(
		noise.get_noise_2d(noise.seed,(Time.get_ticks_msec() / 1000.0) * frequency),
		noise.get_noise_2d(noise.seed + 1,(Time.get_ticks_msec() / 1000.0) * frequency),
		noise.get_noise_2d(noise.seed + 2,(Time.get_ticks_msec() / 1000.0) * frequency)) *  positional_scaler
	## Handle rotational shake
	var rotational_shake : Vector3 = Vector3(
		noise.get_noise_2d(noise.seed + 3,(Time.get_ticks_msec() / 1000.0) * frequency),
		noise.get_noise_2d(noise.seed + 4,(Time.get_ticks_msec() / 1000.0) * frequency),
		noise.get_noise_2d(noise.seed + 5,(Time.get_ticks_msec() / 1000.0) * frequency)) * rotational_scaler
	
	if not disable_positional_shake and target:
		target.position = inital_position + positional_shake * shake
	if not disable_rotational_shake and target:
		target.rotation = inital_rotation + rotational_shake * shake
	
	trauma -= recovery_speed * delta
	trauma = clampf(trauma,0.0,1.0)
	
