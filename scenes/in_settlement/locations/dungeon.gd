extends Location
class_name Dungeon
## dungeons will be where all fights will be fought in this version

var cleared:bool=false

## for transitioning between waves/into main menu
var current_wave:int = 1;

@export var highest_level_target:int;

@export var waves:Array[DungeonRoster];
@export var tile_layout_scene:PackedScene


func refresh()->void:
	## adopt this standart to all locations
	if pending_reset:
		generate_waves()
		

func generate_waves() -> void:
	cleared = false;
	for i:int in len(waves):
		var wave:Roster = waves[i]
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
	
func on_battle_ended(player_won:bool)->void:
	if player_won:
		wave_defeated();

func day_passed()->void:
	pending_reset = true
