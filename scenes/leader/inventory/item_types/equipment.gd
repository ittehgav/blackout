extends Item;

class_name Equipment

signal equipped

## ammo stuff only applies to weapons and modules but it's not enough of a difference to
## break equipment down into an extra branch of item class
signal ammo_consumed(ammo_type:String, amount:int)

@export_enum("food", "fuel","money", "juice", "scrap", "chips") var ammo_type:String="";
## a resource 
## (or anything else in the inventorywouldn't be that much harder to implement?)
@export var ammo_cost:int;

func consume_ammo()->void:
	## overrideable for more complex ammo consumption formulas
	assert(not check_disabled());
	Entities.player.inventory.change_resource(ammo_type, -ammo_cost)
	ammo_consumed.emit(ammo_type, ammo_cost)

func check_disabled()->bool:
	## where other things that may disable the weapon will eventually go
	## NEED AMMO CONSUMPTION TO DO THE FULL PROPAGATION ON EVERY SHOT
	if ammo_type:
		if Entities.player.inventory[ammo_type] < ammo_cost:
			return true
	return false
	
