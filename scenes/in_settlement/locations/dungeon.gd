extends Location
class_name Dungeon
## dungeons will be where all fights will be fought in this version

var cleared:bool=false

## for transitioning between waves/into main menu
## starts at 1 so the number curresponds to how they're enumerated to the player
var current_wave:int = 1;

@onready var settlement:Settlement = get_parent()

@export var highest_level_target:int;

@export var waves:Array[DungeonRoster];
@export var tile_layout_scene:PackedScene

@export var final_loot:LootInventory;



func refresh()->void:
	## called when generated as well as when needed and pending
	generate_waves()
	pending_refresh = false
	settlement.refresh()

func generate_waves() -> void:
	cleared = false;
	for i:int in len(waves):
		var wave:Roster = waves[i];
		var target_level:int = highest_level_target/(len(waves) - i)
		wave.generate_units(target_level)
		wave.loot.generate_loot(wave.get_level())


func get_danger_level()->int:
	var frac:float = highest_level_target/Entities.player.get_party_level()
	if frac <= .5:
		return 1;
	elif frac < .75:
		return 2;
	elif frac <= 2:
		return 3;
	else:
		return 4

func get_current_wave()->DungeonRoster:
	## current_wave starts a 1 because that's how that data will appear to the player
	return waves[current_wave-1]

func wave_defeated()->void:
	current_wave += 1;
	print("cwave? ", current_wave)
	if current_wave > len(waves):
		print("clear?")
		cleared = true
	
func on_battle_ended(player_won:bool)->void:
	if player_won:
		wave_defeated();

func roll_loot()->Array[Item]:
	var loot:Array[Item];
	while len(loot) < 3:
		## where tweaks to rarity rates will happen as the game escalatees?
		## dungeon level related?
		var roll:Item = final_loot.item_pool.pick_random();
		if not (roll in loot):
			loot.append(roll.duplicate(DUPLICATE_USE_INSTANTIATION));
	return loot;
