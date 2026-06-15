@abstract
class_name ActiveEquipment
extends Equipment


signal countinuous_started;
signal continuous_released


## this stuff only applies to weapons and modules but it's not enough of a 
## difference to break equipment down into an extra branch of item class
signal ammo_consumed(ammo_type:String, amount:int)
signal ammo_ran_out(ammo_type:String)

@export_range(1, 10) var refinement_level:int;
@export var refinement_component:RefinementComponent;

@export var continuous:bool=false;

@export_enum("food", "fuel","money", "juice", "scrap", "chips") var ammo_type:String="";
## a resource 
## (or anything else in the inventorywouldn't be that much harder to implement?)
@export var ammo_cost:int;


func consume_ammo()->void:
	## overrideable for more complex ammo consumption formulas
	assert(not check_disabled());
	player.inventory.change_resource(ammo_type, -ammo_cost)
	ammo_consumed.emit(ammo_type, ammo_cost)
	if player.inventory[ammo_type] == 0:
		ammo_ran_out.emit(ammo_type)

func check_disabled()->bool:
	## where other things that may disable the weapon will eventually go
	## NEED AMMO CONSUMPTION TO DO THE FULL PROPAGATION ON EVERY SHOT
	if ammo_type:
		if player.inventory[ammo_type] < ammo_cost:
			return true
	return false

## interchangeable bewtween weapons and modules,
## still not worth making an extra branch to separate these from accessories

func impact()->void:
	printerr(name + " MISSING IMPACT")

func start()->void:
	## can just add alt option here if i end up making any weapon with alt continuous fire?
	printerr(name + " MISSING START")
func release()->void:
	printerr(name + " MISSING RELEASE")

func final_cooldown()->float:
	var base_cd:float = self["cooldown"];
	return Scaling.agility_cooldown_reduction(base_cd, player.final_stat("agility"))
