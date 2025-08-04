extends Roster
class_name BuildingRoster
## roster with exported options for unit recruiting customization

## level range do how?
@export_group("Available Tags")
## TODO make this more dynamic somehow
@export var bodybuilder_recruiting:bool=false;
@export var brawler_recruiting:bool=false;
@export var cyborg_recruiting:bool=false;
@export var scientist_recruiting:bool=false;
@export var mechanic_recruiting:bool=false;
@export var hunter_recruiting:bool=false;
@export var doctor_recruiting:bool=false;
@export var juggernaut_recruiting:bool=false;
@export var disruptor_recruiting:bool=false;

func refresh_recruits()->void:
	units.clear();
	
	## pricing is done as the recruiting menu starts
	var tags:Array[String];
	var base_pool:Array[FighterBase]
	
	for tag:String in Index.all_fighter_tags:
		if self[tag+"_recruiting"]:
			tags.append(tag);
			
	for base:FighterBase in Index.fighters.all_fighter_bases:
		for tag:String in base.tags:
			if tag in tags and not base in base_pool:
				base_pool.append(base);
				
	var unit:FighterUnit = Index.scenes.fighter_unit.instantiate()
	unit.base = base_pool.pick_random();
	unit.update_stats();
	units.append(unit);
