extends PanelContainer

@export var sprite_container:Control;
@export var bar:ExperienceBar
@export var level_label:Label;

var unit:FighterUnit

func load_unit(target:FighterUnit)->void:
	unit = target
	
	var base:FighterBase = unit.base.duplicate()
	base.set_material(null)

	base.centered = false;
	bar.build(unit)
	level_label.text = "Level: " + str(unit.level)
	sprite_container.add_child(base);
	base.position = Vector2(-20, -20)
	show()

func _on_exp_bar_level_up() -> void:
	level_label.text = "Level: " + str(unit.level)
