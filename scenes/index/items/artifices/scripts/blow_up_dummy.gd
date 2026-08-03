extends Artifice

@export var dummy_unit:FighterUnit;



const size_x = 3
const size_y = 2;

const rarity = 2

func get_description()->String:
	return "Use in combat to place a dummy to distract enemies."


func use()->bool:
	throw();
	return consume()

func detonate_callback(hit_location:Vector2)->void:
	Combat.summon_unit(Entities.player_fighter, dummy_unit, hit_location)
	detonate_sfx.play()
