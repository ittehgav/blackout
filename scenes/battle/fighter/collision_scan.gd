extends Area2D

class_name CollisionScan;

@export var source:ActiveFighter
@export var shape:CollisionShape2D

func _on_hurtbox_child_entered_tree(node: Node) -> void:
	## not connected in player fighter bc its always the same shape as the 
	## hurtbox that's already in the scene
	assert(node is CollisionShape2D);
	var new_shape: Shape2D = node.shape;
	shape.shape = new_shape.duplicate()
