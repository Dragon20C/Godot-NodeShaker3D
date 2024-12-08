extends Node3D

@export var node_shaker_3d : NodeShaker3D
@export var multi_node_shaker_3d : MultiNodeShaker3D
@export var test_cube_1 : Node3D
@export var test_cube_2 : Node3D

func _ready() -> void:
	multi_node_shaker_3d.add_target(test_cube_1)
	multi_node_shaker_3d.add_target(test_cube_2)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		multi_node_shaker_3d.induce_stress(test_cube_1)
		multi_node_shaker_3d.induce_stress(test_cube_2)
