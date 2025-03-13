extends Leader

class_name Player;

@export var leadership_stats:Node;

signal resources_changed;
signal morale_changed;

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


var morale:float=4.56664;

func _ready()->void:
	Entities.player = self;
	
