extends Module;

const rarity = 2;

@export var motion_trails:Array[MotionTrail]

const juice_cost = 5
@export var agility_buff:Status

func get_description()->String:
	return "Consumes " +Index.get_color_tag("food")+ str(ammo_cost)+ " food[/color] to give the 3 most damaged units in party a"\
	+Index.get_color_tag("max_hp")+" regeneration buff.";
	

func consume_ammo()->void:
	super()
	if modifier == 2:
		if Entities.player.inventory.juice < juice_cost:
			Entities.player.inventory.change_resource("juice", -juice_cost)
			
func use()->void:
	consume_ammo()
	var most_damaged:Array[ActiveFighter];
	
	for e:CombatEntity in Entities.player_fighter.ally_team.fighters:
		most_damaged.sort_custom(func(a:CombatEntity, b:CombatEntity)->bool:return (a.max_hp - a.hp) > (b.max_hp - b.hp));
		if len(most_damaged) < 3:
			most_damaged.append(e);
		else:
			var less_damaged_index:int = most_damaged.find_custom(func(c:CombatEntity)->bool:return (c.max_hp - c.hp) < (e.max_hp - e.hp))
			if less_damaged_index != -1:
				most_damaged[less_damaged_index] = e
	
	for i:int in len(most_damaged):
		status.apply_on_target(most_damaged[i]);
		if modifier == 2:
			agility_buff.apply_on_target(most_damaged[i])
		motion_trails[i].trail_jump(Entities.player_fighter.global_position, most_damaged[i].global_position);


const m1_description = "Consumes 50% less food."
const m1_prefix = "Frugal";

const m2_description = "Also consumes some 5 juice (if you have it) and gives all allies an agility buff.";
const m2_prefix = "Spicy"

func apply_m1()->void:
	ammo_cost /= 2;

func apply_m2()->void:
	for t:MotionTrail in motion_trails:
		t.trail.default_color.h = 30/360
