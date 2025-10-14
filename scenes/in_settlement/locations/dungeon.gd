extends Location
class_name Dungeon
## dungeons will be where all fights will be fought in this version

var cleared:bool=false

## for transitioning between waves/into main menu
var current_wave:int = 0;

@export var highest_level_target:int;

@export var waves:Array[DungeonRoster];
@export var tile_layout_scene:PackedScene


func generate_waves() -> void:
	cleared = false;
	for i:int in len(waves):
		var wave:Roster = waves[i]
		wave.generate_units(highest_level_target/(len(waves) - i))

func get_danger_level()->int:
	var frac:float = highest_level_target/Entities.player.get_party_level()
	if frac <= .5:
		return 1;
	elif frac <= 2:
		return 2;
	elif frac <= 3:
		return 3;
	else:
		return 4;
