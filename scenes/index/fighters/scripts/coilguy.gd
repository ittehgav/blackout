extends FighterBase



const sample_offset = Vector2(10, -26)

const target_type = "nearest_enemy"

const skill_name = "Chain Lightning"
const description = "Fires powerful chain lightning Attacks."
const flavor = "He tells the party-mates that the magnetism only affects people who make fun of his baldness.";


const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	
	var technique_str:String = Index.get_color_tag("technique") + str(snapped(unit.stats.technique/20, .01))+"x[/color]"
	
	var magnetized_color_tag:String = "[color=" + Color.YELLOW.darkened(.2).to_html() + "]"
	
	
	var string:String= magnetized_color_tag+"Magnetizes[/color] the nearest enemy that's not "+magnetized_color_tag+\
	"magnetized[/color], then deals " + damage_str + " to all "+magnetized_color_tag+"magnetized[/color] enemies.\nDeals "\
	 + technique_str + " more damage to all targets for each "+magnetized_color_tag+"magnetized[/color] enemy on the battlefield."
	return string



@export var lightning:Sprite2D;
@export var lightning_animation:AnimationPlayer;
func skill()->void:
	## TODO SPRITE NEEDS TO BE REEXPORTED arm is fucke up
	animation_player.play("coilguy/skill")
	animation_player.queue("fighter_base/idle")


func skill_impact()->void:
	if fighter.dead:
		return;
	var tagged_targets:Array[ActiveFighter] = get_tagged_fighters();
	if not len(tagged_targets):
		## makes sure there's always at least 2 tagged targets
		tag_fighter(fighter.target_unit)

	if not len(fighter.enemy_team.units) == len(tagged_targets):
		var untagged_targets:Array[Node] = fighter.enemy_team.units.filter(func(f:ActiveFighter)->bool:return "magnetized" not in f.special_statuses);
		untagged_targets.sort_custom(closest_to_source)

		var target:ActiveFighter = untagged_targets[0];
		tag_fighter(target)
	
	Combat.deal_damage(fighter, fighter.target_unit);
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
	return "magnetized" in f.special_statuses;

func target_count_amplifier(damage:float)->float:
	for i in len(get_tagged_fighters()):
		damage += damage * fighter.technique/20;
	return damage;


func tag_fighter(target:ActiveFighter)->void:
	## TODO make a more proper special status system where the statuses
	## get icon textures from the source
	target.special_statuses["magnetized"] = {};


func get_tagged_fighters()->Array[ActiveFighter]:
	var enemies:Array[Node] = fighter.enemy_team.units.filter(filter_magnetized)
	var final_array:Array[ActiveFighter]
	final_array.assign(enemies)
	return final_array


func lightning_hit(t1:ActiveFighter, t2:ActiveFighter)->void:
	lightning.global_position = t1.global_position;
	var angle:float = t1.position.angle_to_point(t2.position)
	lightning.global_rotation = angle
	
	Combat.deal_damage(fighter, t2, target_count_amplifier);


func closest_to_source(a:ActiveFighter, b:ActiveFighter)->bool:
	return fighter.position.distance_squared_to(a.position) > fighter.position.distance_squared_to(b.position);
