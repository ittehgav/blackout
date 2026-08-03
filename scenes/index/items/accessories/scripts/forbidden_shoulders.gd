extends Accessory

const size_x = 4;
const size_y = 2;

const rarity = 3

@export var steal:Status

@export_subgroup("Mask Texture")
@export var mask_texture:Texture;
var insta_kill_applied:bool=false
## because the player may equip them in different slots and 
## alter the order in which they proc

func get_description()->String:
	var description:String = super();
	description += "At the start of battle, steal half of the " + CombatStats.stat_colored_name("defense")+\
	" of the enemy with the highest " + CombatStats.stat_colored_name("defense") +", when that enemy is defeated, this effect activates again.\nEquip alongside [u]forbidden mask[/u] to unlock " +\
	Index.get_color_tag("attack") + "unimaginable power."
	return description;


func battle_start_apply(target:ActiveFighter, first:bool=true)->void:
	var enemy_fighters:Array[ActiveFighter] = target.enemy_team.fighters;
	if len(enemy_fighters):
		var steal_target:ActiveFighter;
		for fighter:ActiveFighter in enemy_fighters:
			@warning_ignore("unassigned_variable")
			if not steal_target or fighter.defense > steal_target.defense:
				steal_target = fighter;
				
		var defense_steal:int = steal_target.defense/2;

		steal.apply_on_target(steal_target, -defense_steal);
		status.apply_on_target(Entities.player_fighter, defense_steal);
		

		steal_vfx(steal_target)

		steal_target.death.connect(target_killed);
	
	if first:
		var other_accessory:Accessory = other_equipped_accessory()
		if other_accessory and "Forbidden Mask" in other_accessory.unique_name and not insta_kill_applied:
			insta_kill_applied = true;
			other_accessory.insta_kill_applied = true;
			other_accessory.forbidden_insta_kill();

func steal_vfx(target:ActiveFighter)->void:
	var sprite:Sprite2D = Sprite2D.new();
	sprite.texture = mask_texture;
	sprite.modulate = Index.get_color("defense");

	target.overlay.floating_icon_anchor.add_child(sprite)
	sprite.scale = Vector2(2, 2)
	
	var tween:Tween = sprite.create_tween();
	tween.tween_property(sprite, "modulate:a", 0, .5);
	tween.parallel().tween_property(sprite, "position:y", sprite.position.y - 30, .5);
	tween.tween_callback(sprite.queue_free)

func target_killed(_killer:ActiveFighter)->void:
	battle_start_apply(Entities.player_fighter, false);
