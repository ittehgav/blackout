extends PanelContainer

@export var choice_1:Button
@export var choice_2:Button;

var evolution_1:FighterBase;
var evolution_2:FighterBase


@export var arrow_1:TextureRect;
@export var arrow_2:TextureRect

@export var confirmation:Control

var current_unit:FighterUnit

func _ready()->void:
	arrow_blink_loop(arrow_1);
	arrow_blink_loop(arrow_2)

func arrow_blink_loop(target:TextureRect)->void:
	var tween:Tween = create_tween();
	tween.tween_property(target, "modulate:a", .25, .5);
	tween.tween_property(target, "modulate:a", 1, .5);
	tween.tween_callback(arrow_blink_loop.bind(target))

func display_evolutions(unit:FighterUnit)->void:
	current_unit = unit
	var base:FighterBase = unit.base
	assert(base.evolutions)
	
	evolution_1 = Index.fighters.find_base(base.evolutions[0]);
	evolution_2 = Index.fighters.find_base(base.evolutions[1])
	
	choice_1.show_evolution(unit, evolution_1);
	choice_2.show_evolution(unit, evolution_2);
	Tweens.ui_fade_in(self)


func _on_return_btn_pressed() -> void:
	Tweens.ui_fade_out(self);

func show_confirmation(target_unit:FighterUnit, target_base:FighterBase)->void:
	confirmation.target_unit = target_unit
	confirmation.initial_base = target_unit.base;
	confirmation.evolved_base = target_base
	confirmation.show_confirmation()
	hide()


func _on_evolution_1_choice_pressed() -> void:
	show_confirmation(current_unit, evolution_1)


func _on_evolution_2_choice_pressed() -> void:
	show_confirmation(current_unit, evolution_2)
