@abstract
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_sword.png")
extends ActiveEquipment;
class_name Weapon;

const type = "weapon"

signal unequipped;

signal use_finished ## to start the cooldown timer, controlled by the weapon's script
signal hit; ## hit only triggers once for multiple sychronous AOE hits
## emit AFTER combat calls (for hit_targets consistency)
@export var display:WeaponDisplay;

## active_texture swaps in at battle start if the weapon has it
@export var animation_root_key:String = "melee"
## WEAPON ANIMATIONS ALWAYS HAVE THE SAME NAMES BETWEEN LIBRARIES
## right now either melee or ranged
## or overrides from the default ones
## ATTACK ANIMATION KEYS
## attack <- NEEDS TO CALL THE WEAPON'S IMPACT FN
## after_attack
## idle
## walk
## TODO make a clear way to override timing of specific keys
## so weapons become more customizable:?

@export var base_damage:int;
@export var cooldown:float;
@export var alt_cooldown:float;

@export_group("Common weapon settings")
@export var hit_scan:Area2D;
@export var alt_hit_scan:Area2D;

@export var projectile:Projectile;

@export_group("More specific adjustments")
@export var melee:bool=false;


@export_group("Feedback, visuals, sounds")
## used directly via script rather than by other parts.
@export var projections:Array[CanvasItem]

@export var animation_player:AnimationPlayer
@export var use_sfx:AudioStreamPlayer
@export var alt_use_sfx:AudioStreamPlayer;


@export var active_texture:Texture;


## for when the item's own texture is not the same that appears next to the player
var item_texture:Texture = texture;
## easier to do this and use an instance of the item as the weapon 
## than adding an extra layer of setting up the weapon into play



var pending_impact:bool=false;

func use(_alt:bool=false)->void:
	## these are gonna look a lot similar between eachother but i'd 
	## still rather have them all on their own scripts 
	printerr(name + " MISSING USE")
	
func final_damage()->int:
	## ONLY FOR WEAPONS NOT COMBAT
	## during combat the player's stats will be set dynamically

	var damage:int = player.final_stats().attack;
	damage += base_damage;
	if applied_modifier:
		if applied_modifier.stat_modifiers:
			damage += applied_modifier.stat_modifiers.attack;
	return damage

func ammo_cost_string()->String:
	assert(ammo_cost);
	return Index.colored_text(ammo_type, ammo_cost, " " + ammo_type)
	
func damage_string()->String:
	return Index.colored_text("attack", str(final_damage()) + " damage");



func get_animation_key(track:String)->String:
	return animation_root_key+"/"+track
