extends Node3D

@export var node_shaker_3d : NodeShaker3D
@export var test_cube : Node3D

func _ready() -> void:
	node_shaker_3d.set_target(test_cube)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		node_shaker_3d.induce_stress(1.0)
