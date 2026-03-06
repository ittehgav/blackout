extends Equipment;

class_name Weapon;

const type = "weapon"

signal unequipped;

signal use_finished ## to start the cooldown timer, controlled by the weapon's script
signal hit; ## hit only triggers once for multiple sychronous AOE hits


## active_texture swaps in at battle start if the weapon has it

@export var base_damage:int;
@export var cooldown:float;
@export var alt_cooldown:float;

@export_group("Common weapon settings")
@export var hit_scan:Area2D;
@export var alt_hit_scan:Area2D;

@export var projectile:Projectile;

@export_group("More specific adjustments")
@export var angle_adjust:int;
@export var melee:bool=false;



@export_group("Feedback, visuals, sounds")
## used directly via script rather than by other parts.
@export var projections:Array[CanvasItem]

@export var animation_player:AnimationPlayer
@export var use_sfx:AudioStreamPlayer
@export var alt_use_sfx:AudioStreamPlayer;

@export var hit_sfx:AudioStreamPlayer
@export var alt_hit_sfx:AudioStreamPlayer

@export var active_texture:Texture;
## for when the item's own texture is not the same that appears next to the player
var item_texture:Texture = texture;
## easier to do this and use an instance of the item as the weapon 
## than adding an extra layer of setting up the weapon into play

@export_enum("camera_lunge", "camera_recoil", "none") var use_feedback:String = "camera_lunge"
@export_enum("freeze_frame") var hit_feedback:String = "freeze_frame";


func use(_alt:bool=false)->void:
	## these are gonna look a lot similar between eachother but i'd 
	## still rather have them all on their own scripts 
	printerr(name + " MISSING USE")
	
func final_damage()->int:
	## ONLY FOR WEAPONS NOT COMBAT
	## during combat the player's stats will be set dynamically
	var damage:int = Entities.player.final_stats().attack;
	damage += base_damage;
	if applied_modifier:
		if applied_modifier.stat_modifiers:
			damage += applied_modifier.stat_modifiers.attack;
	return damage
