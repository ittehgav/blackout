@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_skull.png")
extends Settlement
class_name Dungeon
## settlement where you fight

var cleared:bool=false

## for transitioning between waves/into main menu
## starts at 1 so the number curresponds to how they're enumerated to the player
@export var current_wave:int = 1;
## exporting for testing 

@onready var location:Location = get_parent()


@export var waves:Array[NpcRoster];
@export var tile_layout_scene:PackedScene

@export var final_loot:LootInventory;



func refresh()->void:
	## called when generated as well as when needed and pending
	for wave:NpcRoster in waves:
		wave.loot.generate_loot(wave.get_level());
	pending_refresh = false


func get_danger_level()->int:
	return waves[current_wave].get_danger_level()

func get_current_wave()->NpcRoster:
	## current_wave starts a 1 because that's how that data will appear to the player
	return waves[current_wave-1]

func wave_defeated()->void:
	current_wave += 1;
	if current_wave > len(waves):
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
