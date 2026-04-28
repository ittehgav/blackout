extends ColorRect


const evolution_cost=50;

@export var player_juice_counter:Label;

@export var menu:EvolutionMenu

@export var before_sample:UnitSample;
@export var before_stats_dropdown:StatsDropdown

@export var after_sample:UnitSample;
@export var after_stats_dropdown:StatsDropdown;

@export var after_name:Label;
@export var after_skill_name:Label;
@export var after_skill_cd:Label;
@export var after_skill_description:RichTextLabel

@export var post_after_stats_dropdown:StatsDropdown;

@export var post_after_name:Label;
@export var post_after_skill_name:Label;
@export var post_after_skill_cd:Label;
@export var post_after_skill_description:RichTextLabel

@export var confirmation_panel:PanelContainer
@export var evolution_animation:Control;
@export var evolution_animation_player:AnimationPlayer

@export var animation_before_sprite:Sprite2D;
@export var animation_after_sprite:Sprite2D;

@export var evolve_btn:Button

var current_unit:FighterUnit;
var current_evolution:FighterBase;

func _ready()->void:
	set_process_input(false)

func prompt_evolution_confirmation(unit:FighterUnit, new_base:FighterBase)->void:
	current_unit = unit;
	current_evolution = new_base
	
	var unit_after:FighterUnit = Index.scenes.fighter_unit.instantiate();
	unit_after.base = new_base;
	unit_after.level = unit.level
	unit_after.update_stats()
	
	animation_before_sprite.texture = unit.base.texture;
	animation_after_sprite.texture = new_base.texture;
	
	before_sample.load_unit(unit);
	before_stats_dropdown.load_stats(unit.final_stats());

	var after_stats:CombatStats = unit_after.final_stats()
	after_sample.load_unit(unit_after);

	after_stats_dropdown.load_stats(after_stats)
	post_after_stats_dropdown.load_stats(after_stats)
	
	after_name.text = new_base.name;
	after_skill_name.text = "Skill: " + new_base.skill.name;
	var cd:float = snapped(unit_after.final_skill_cooldown(), .01)
	
	after_skill_cd.text = "Coooldown: "+str(cd)+"s"
	after_skill_description.text = new_base.full_skill_description(unit)
	
	post_after_name.text = new_base.name;
	post_after_skill_name.text = "Skill: " + new_base.skill.name;
	post_after_skill_cd.text = "Coooldown: "+str(cd)+"s"
	post_after_skill_description.text = new_base.full_skill_description(unit)
	
	evolve_btn.disabled = menu.player.inventory.juice < evolution_cost
	
	Tweens.ui_fade_in(self)


func _on_cancel_pressed() -> void:
	Tweens.ui_fade_out(self)


func _on_confirm_evolution_pressed() -> void:
	menu.player.inventory.change_resource("juice", -50);
	
	await Tweens.tween_count_label(player_juice_counter, menu.player.inventory.juice).finished;
	
	confirmation_panel.hide();
	
	current_unit.base = current_evolution;
	
	evolution_animation.show()
	evolution_animation_player.play("evolution_animation");
	set_process_input(true);

func _input(e:InputEvent)->void:
	if e is InputEventMouseButton and e.pressed:
		evolution_animation.hide();
		confirmation_panel.show();
		Tweens.ui_fade_out(self);
		menu.start_evolution_menu()
		set_process_input(false)
