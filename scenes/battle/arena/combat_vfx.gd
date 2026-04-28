class_name CombatVFX
extends Sprite2D


## class for any VFX that will play in combat 
## besides skill windup highlights

## WILL GET THEIR OWN SEPARATE FOLDER AND GET BUILT MODULARLY
## first batch will be for recruits
## player's version will have modifiers to stick out more 
## in a scripted way that still lets you just drag and drop them on the item/unit

@export var animation_player:AnimationPlayer;
## animation player is limited
## (can't make a directed motion in a modular way based on the 
## direction the unit is facing)
## WILL ALWAYS CONTROL: 
## Y frame coord
## scale (and anchor will likely need to be adjusted on X frame change?)

enum Activator{start, impact, finished, manual}
## right now only matters to fighter bases but can apply the same principles to weapons
## manual implies calls through code or more specific signals
@export var activator:Activator=Activator.impact;

var skill:SkillComponent;
@export var motion_offset:int = 0;
@export var track_source_angle:bool=true;
@export var rotation_offset:float; ## in degrees and gets converted into radians afterward
## so it's easier to type in


var angle_source:Sprite2D
func _ready() -> void:
	## TODO make this stuff run only in combat
	set_sprite_root()
	
func set_sprite_root()->void:
	## setup that dynamically does a lot of stuff that would be a bitch to
	## connect manually/keep track of if connecting signals in the UI
	## right now only works for fightertbases

	var parent:Node = get_parent();
	while not (parent is Sprite2D or parent is Item):
		parent = parent.get_parent();
		assert (not (parent is Arena)) ## catches misplaced vfx node
	
	if track_source_angle:
		if parent is FighterBase:
			angle_source = parent;
			angle_source.frame_changed.connect(match_source_angle);
		elif parent is Weapon:
			animation_player.speed_scale = .75
			## just to keep this adjustment from being called twice when weapon is duplicated
			if rotation_offset and rotation_offset > PI:
				rotation_offset = deg_to_rad(rotation_offset)
				
			parent.animation_player.animation_started.connect(match_weapon_angle_and_play)


	if angle_source is FighterBase:
		skill = angle_source.skill;
		match activator:
			Activator.start:
				skill.start.connect(play_vfx)
			Activator.impact:
				skill.impact.connect(play_vfx)
			Activator.finished:
				skill.finished.connect(play_vfx)

func play_vfx()->void:
	animation_player.play("vfx");
	if motion_offset:
		var angle:Vector2 = Index.isometric_angle_indexes[frame_coords.x];
		offset = angle * motion_offset;
		await animation_player.animation_finished
		offset = Vector2.ZERO

func match_source_angle()->void:
	## likely will have to add more adjustments?
	frame_coords.x = angle_source.frame_coords.x;

func match_weapon_angle_and_play(_a:Variant)->void:
	var eq_rotation:float = Entities.player_fighter.equipment.rotation;
	
	rotation = eq_rotation + rotation_offset
	global_position = Entities.player_fighter.position + Vector2.RIGHT.rotated(eq_rotation) * motion_offset;
	animation_player.play("vfx");
