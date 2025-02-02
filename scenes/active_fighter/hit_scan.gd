extends Area2D

@export var fighter:ActiveFighter;


func _physics_process(_delta: float) -> void:
	if fighter.target_unit:
		look_at(fighter.target_unit.global_position);
