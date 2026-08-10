extends Artifice

const size_x = 1;
const size_y = 2;

const rarity = 2

var assigned_target:CombatEntity;
## only for point-click artifices?
@export var adrenaline_sfx:AudioStream;



func get_description()->String:
	return "In battle, throw this on any unit to double their attack and halven their defense for the rest of the battle."

func use()->bool:
	throw()
	return consume();

func hit_callback(hit_target:ActiveFighter)->void:
	status.apply_on_target(hit_target)
	hit_sfx.play()
	## TODO make adrenaline play off of target's ASP2D
