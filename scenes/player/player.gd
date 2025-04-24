extends Leader

class_name Player;

@export var leadership_stats:Node;

signal resources_changed;
signal morale_changed;
signal party_changed;

## leadership skills will be a special tree that grants a special bonus at each level
## you can win leadership EXP by fighting (based on the amount of units is the party?)
## and by completing quests (auto-generated tasks from settlements?)
@export var leadership_level:int = 0;
@export var leadership_exp:int = 0;


## combat exp will be gained in parallel with leadership levels, 
## you win combat EXP when fighting
@export var combat_level:int = 0;
@export var combat_exp:int = 0;

## ANY ITEMS THAT BELONG TO THE PLAYER WILL BE CHILDREN OF THE INVENTORY NODE
@export var equipped_weapon:Weapon;
@export var alternative_weapon:Weapon=null;

@export var equipped_module:Module;


var memos:Array[Memo];


var morale:float=3.7;

func _ready()->void:
	Entities.player = self;
	
func battle_victory_morale()->void:
	## for now just make all morale changes go through this script
	morale += .5;
	
func battle_defeat_morale()->void:
	morale -= .5


func _on_resources_changed() -> void:
	pass # Replace with function body.
