@tool
extends Node3D
class_name MultiNodeShaker3D

@export var disable_positional_shake : bool = false
@export var disable_rotational_shake : bool = false

@export_range(0.1,5) var recovery_speed : float = 1.5
@export var frequency : float = 8.0
@export var trauma_exponent : float = 2.0
@export var positional_scaler : Vector3 =  Vector3(0.5,0.5,0.2)
@export var rotational_scaler : Vector3 = Vector3(0.5,0.5,0.2)
@onready var noise : FastNoiseLite = FastNoiseLite.new()

var shake_index : int = 0
var shakables : Dictionary

func _ready() -> void:
	randomize()
	noise.seed = randi_range(0,1000)
	noise.frequency = 0.2

class Shakeable extends Resource:
	var nodeshaker_parent : MultiNodeShaker3D
	
	var id : int = -1
	var shake_index : int = 0
	
	var inital_position : Vector3 = Vector3.ZERO
	var inital_rotation : Vector3 = Vector3.ZERO
	
	var trauma : float = 0.0
	var shake : float = 0.0
	
	var target : Node3D = null:
		set(value):
			target = value
			if (target):
				self.inital_position = target.position
				self.inital_rotation = target.rotation
				self.id = target.get_instance_id()
	
	func _init(nodeshaker_parent : MultiNodeShaker3D,_shake_index : int) -> void:
		self.nodeshaker_parent = nodeshaker_parent
		self.shake_index = _shake_index
	
	func induce_stress(stress : float = 1.0) -> void:
		self.trauma += stress
		self.trauma = clampf(self.trauma,0.0,1.0)

	func set_target(_target : Node3D) -> void:
		if _target:
			target = _target
	
	func handle_shake(delta : float) -> void:
		self.shake = pow(self.trauma,self.nodeshaker_parent.trauma_exponent)
	
		## Return when trauma is zero, meaning no shake is happening and avoids running unnecessary code.
		if self.trauma == 0.0 or not self.target:
			return
		
		## Handle Translational shake
		var positional_shake : Vector3 = Vector3(
			nodeshaker_parent.noise.get_noise_2d(nodeshaker_parent.noise.seed + self.shake_index,(Time.get_ticks_msec() / 1000.0) * nodeshaker_parent.frequency),
			nodeshaker_parent.noise.get_noise_2d(nodeshaker_parent.noise.seed + self.shake_index + 1,(Time.get_ticks_msec() / 1000.0) * nodeshaker_parent.frequency),
			nodeshaker_parent.noise.get_noise_2d(nodeshaker_parent.noise.seed + self.shake_index + 2,(Time.get_ticks_msec() / 1000.0) * nodeshaker_parent.frequency)) *  nodeshaker_parent.positional_scaler
		## Handle rotational shake
		var rotational_shake : Vector3 = Vector3(
			nodeshaker_parent.noise.get_noise_2d(nodeshaker_parent.noise.seed + self.shake_index + 3,(Time.get_ticks_msec() / 1000.0) * nodeshaker_parent.frequency),
			nodeshaker_parent.noise.get_noise_2d(nodeshaker_parent.noise.seed + self.shake_index + 4,(Time.get_ticks_msec() / 1000.0) * nodeshaker_parent.frequency),
			nodeshaker_parent.noise.get_noise_2d(nodeshaker_parent.noise.seed + self.shake_index + 5,(Time.get_ticks_msec() / 1000.0) * nodeshaker_parent.frequency)) * nodeshaker_parent.rotational_scaler
		
		if not nodeshaker_parent.disable_positional_shake and self.target:
			self.target.position = self.inital_position + positional_shake * self.shake
		if not nodeshaker_parent.disable_rotational_shake and self.target:
			self.target.rotation = self.inital_rotation + rotational_shake * self.shake
		
		self.trauma -= nodeshaker_parent.recovery_speed * delta
		self.trauma = clampf(self.trauma,0.0,1.0)
		
		## if the trauma is zero, set the targets position to inital to avoid floating point percision.
		if self.trauma == 0.0:
			self.target.position = self.inital_position
			self.target.rotation = self.inital_rotation

func add_target(target : Node3D) -> void:
	var _shake_index = shakables.size() * 5
	var shaker : Shakeable = Shakeable.new(self,_shake_index)
	shaker.set_target(target)
	shakables[target.get_instance_id()] = shaker

func induce_stress(target : Node3D, stress : float = 1.0) -> void:
	shakables[target.get_instance_id()].induce_stress(stress)

func _process(delta: float) -> void:
	for shaker in shakables:
		shakables[shaker].handle_shake(delta)
