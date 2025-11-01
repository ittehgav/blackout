extends Accessory

const size_x = 3;
const size_y = 2;

const rarity = 3;
var insta_kill_applied:bool=false

@export var self_buff:Status
## because the player may equip them in different slots and 
## alter the order in which they proc


func get_description()->String:
	var description:String = super();
	description += "At the start of battle, steal half of the " + Index.stat_colored_name("attack")+\
	" of the enemy with the highest " + Index.stat_colored_name("attack") +", when that enemy is defeated, this effect activates again.\nEquip alongside [u]forbidden shoulders[/u] to unlock " +\
	Index.get_color_tag("attack") + "unimaginable power."
	return description;

func battle_start_apply(target:ActiveFighter, first:bool=true)->void:
	var enemy_units:Array[ActiveFighter] = target.enemy_team.units;
	if len(enemy_units):
		var steal_target:ActiveFighter;
		for unit:ActiveFighter in enemy_units:
			@warning_ignore("unassigned_variable")
			if not steal_target or unit.attack > steal_target.attack:
				steal_target = unit;
				
		var attack_steal:int = steal_target.attack/2;
		
		status.apply_on_target(steal_target, -attack_steal)
		self_buff.apply_on_target(Entities.player_fighter, attack_steal);
		

		steal_vfx(steal_target)

		steal_target.death.connect(target_killed);

	if first:
		var other_accessory:Accessory = other_equipped_accessory()
		if other_accessory and "Forbidden Shoulders" in other_accessory.name and not insta_kill_applied:
			insta_kill_applied = true;
			other_accessory.insta_kill_applied = true;
			forbidden_insta_kill();

func forbidden_insta_kill()->void:
	var target:ActiveFighter;
	var enemy_fighters:Array[ActiveFighter] = Entities.player_fighter.enemy_team.units;
	for fighter:ActiveFighter in enemy_fighters:
		@warning_ignore("unassigned_variable")
		if not target or fighter.level > target.level:
			target = fighter;
	
	Combat.deal_damage(Entities.player_fighter, target, Callable(), 99999)


func steal_vfx(target:ActiveFighter)->void:
	var sprite:Sprite2D = Sprite2D.new();
	sprite.texture = texture;
	sprite.modulate = Index.get_color("attack");

	target.overlay.floating_icon_anchor.add_child(sprite)
	sprite.scale = Vector2(2, 2)
	
	var tween:Tween = sprite.create_tween();
	tween.tween_property(sprite, "modulate:a", 0, .5);
	tween.parallel().tween_property(sprite, "position:y", sprite.position.y - 30, .5);
	tween.tween_callback(sprite.queue_free)

func target_killed(_killer:ActiveFighter)->void:
	battle_start_apply(Entities.player_fighter, false);
