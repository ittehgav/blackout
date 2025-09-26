extends FighterBase

const skill_name = "Domain of Thorns"
const description = "Creates thorns that damage and reduce the agility of enemies in its area";
const flavor = "He plants and manufactures his own hair dye.";

const skill_range = MELEE_RANGE;
const skill_cooldown = 3;

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.get_unit_damage_string(unit);
	var thorns_str:String = "[color="+Color.DARK_OLIVE_GREEN.to_html(false) + "]Thorns[/color]";
	
	
	var final_str:String = "Creates " +thorns_str +\
	 " on the ground beneath the nearest enemy, if there's already "+thorns_str+\
	 " in that area, those "+thorns_str+" are expanded instead.\nEnemies standing on " +\
	thorns_str+ " take " + damage_string + " every second and have their " + Index.get_color_tag("agility")+\
	"agility[/color] reduced by 30%.";
	## TODO FINISH IMPLEMENTING THE SKILL
	
	
	return final_str

func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if unit:
		return damage/5 + damage/5 * unit.stats.technique;
	else:
		return damage/5 + damage/5 * fighter.stats.technique;

@export var thorns:ColorRect;

var all_thorns:Array[ColorRect];## thorns are colorrects because they're easier to resize at will
const thorns_initial_offset = Vector2(25, 25); ## so it's centralized 
## pivot offset is weird i cant make it work properly

func _ready()->void:
	hit_scan.global_position = Vector2.ZERO;

func skill()->void:
	## pass this stuff to npcfighter if everyone ends up getting some version of it?:
	Combat.set_windup_angle(fighter)

	animation_player.play("dryad/skill")
	animation_player.queue("fighter_base/idle")

func skill_impact()->void:
	if hit_scan.overlaps_body(fighter.target_unit):
		var thorns_rect:ColorRect = find_overlapping_thorns(fighter.target_unit.global_position);
		thorns_rect.expand(fighter.target_unit.global_position)
	else:
		var new_thorns:ColorRect = thorns.duplicate();
		fighter.ally_team.projectiles.add_child(new_thorns)
		new_thorns.global_position = fighter.target_unit.global_position;
		new_thorns.hit_scan.global_position = fighter.target_unit.global_position + thorns_initial_offset;
		new_thorns.show();
		all_thorns.append(new_thorns);
		

func find_overlapping_thorns(spot:Vector2)->ColorRect:
	var current:ColorRect=null
	var current_rect:Rect2
	for area:ColorRect in all_thorns:
		var rect:Rect2 = area.get_global_rect();
		if rect.has_point(spot):
			if not current or center_is_closer(rect, current_rect, spot):
				current = area;
				current_rect = rect;
	assert(current);
	return current;
	

func center_is_closer(rect:Rect2, current:Rect2, spot:Vector2)->bool:
	var d1:float = rect.get_center().distance_to(spot);
	var d2:float = current.get_center().distance_to(spot);
	return d1 < d2;
