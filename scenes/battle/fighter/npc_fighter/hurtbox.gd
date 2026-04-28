@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_circle.png")
extends Area2D
class_name HurtBox

@export var source:CombatEntity

func _ready()->void:
	source.death.connect(source_died)

func source_died()->void:
	## source always gets freed, this is just so the hurtbox disappears right away
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	monitorable = false;
