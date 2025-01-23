extends Area2D

@export var fighter:CharacterBody2D;


func _physics_process(_delta: float) -> void:
	if fighter.target_unit:
		look_at(fighter.target_unit.global_position);
