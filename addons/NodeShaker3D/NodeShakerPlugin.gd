@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("NodeShaker3D", "Node3D", preload("Scripts/NodeShaker3D.gd"), preload("Icons/NodeShaker3D.svg"))
	add_custom_type(" MultiNodeShaker3D", "Node3D", preload("Scripts/MultiNodeShaker3D.gd"), preload("Icons/NodeShaker3D.svg"))

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("NodeShaker3D")
	remove_custom_type("MultiNodeShaker3D")
