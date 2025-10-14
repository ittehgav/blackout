extends FighterBase

const skill_name = "Chain Lightning"
const description = "Unleashes a powerful chain lightning attack."
const flavor = "He tells the party-mates that the magnetism only affects people who make fun of his headband.";

const skill_range = MELEE_RANGE;
const skill_cooldown = 6;

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	
	var per_target_bonus:String = Index.get_technique_scaled_string(unit, "damage", "", per_target_damage_bonus * 100, "%");

	var static_color_tag:String = "[color=" + Color.YELLOW.darkened(.2).to_html() + "]"
	var final_string:String = "Applies" + static_color_tag + " Static[/color] to enemies, then deals " + damage_str +\
	"to the nearest enemy, then fires a chain lightning attack that damages all enemies with " + static_color_tag+\
	"Static[/color].\nDeals " + per_target_bonus + " more damage for each enemy with " + static_color_tag + " Static[/color]."
	
	return final_string

const per_target_damage_bonus = .05


@export var lightning:Sprite2D;
@export var lightning_animation:AnimationPlayer;
func skill()->void:
	## TODO SPRITE NEEDS TO BE REEXPORTED arm is fucke up
	animation_player.play("coilguy/skill")
	animation_player.queue("fighter_base/idle")


func skill_impact()->void:
	if fighter.dead:
		return;
	if fighter.dead:
		return;
	var tagged_targets:Array = get_tagged_fighters();
	if not len(tagged_targets):
		## makes sure there's always at least 2 tagged targets
		tag_fighter(fighter.target_unit)

	if not len(fighter.enemy_team.units) == len(tagged_targets):
		var targets:Array[ActiveFighter] = fighter.enemy_team.units;
		targets.sort_custom(closest_to_source)
		var target:ActiveFighter;
		for unit:ActiveFighter in targets:
			if "magnetized" not in unit.special_statuses:
				target = unit;
				break;
				
		tag_fighter(target)
	
	Combat.deal_damage(fighter, fighter.target_unit, damage_modifier);
	for i:int in len(tagged_targets) - 1:
		## only t2 is damaged in these
		var t1:ActiveFighter = tagged_targets[i];
		var t2:ActiveFighter = tagged_targets[i + 1]
		if is_instance_valid(t1) and is_instance_valid(t2) and \
			not t1.dead and not t2.dead:
			lightning_hit(t1, t2)
			lightning_animation.play("lightning")
			await get_tree().create_timer(.5).timeout;

func filter_magnetized(f:Node)->bool:
	return "magnetized" in f.special_statuses and not f.dead;

func damage_modifier(damage:float, _unit:FighterUnit=null)->float:
	if not fighter:
		return damage;
	for i in len(get_tagged_fighters()):
		damage += damage * fighter.technique * per_target_damage_bonus;
	return damage;


func tag_fighter(target:ActiveFighter)->void:
	## TODO make a more proper special status system where the statuses
	## get icon textures from the source
	target.special_statuses["magnetized"] = {};



func get_tagged_fighters()->Array[ActiveFighter]:
	var enemies:Array[ActiveFighter] = fighter.enemy_team.units.filter(filter_magnetized)
	return enemies


func lightning_hit(t1:ActiveFighter, t2:ActiveFighter)->void:
	lightning.global_position = t1.global_position;
	var angle:float = t1.position.angle_to_point(t2.position)
	lightning.global_rotation = angle
	
	Combat.deal_damage(fighter, t2, damage_modifier);


func closest_to_source(a:Node, b:Node)->bool:
	return fighter.position.distance_squared_to(a.position) > fighter.position.distance_squared_to(b.position);
