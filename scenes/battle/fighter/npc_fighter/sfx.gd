extends SfxPlayer2D


@onready var fighter:ActiveFighter = get_parent()

@export_group("skill SFX")
@export var swing:AudioStream;
@export var lightning_small:AudioStream;
@export var lightning_big:AudioStream;
@export var defense_up:AudioStream;
@export var engine:AudioStream;
@export var shoot:AudioStream;
@export var gravity:AudioStream;

@export var heal:AudioStream;
@export var projectile_hit:AudioStream;
@export var metal:AudioStream;
@export var small_hit:AudioStream;
@export var slam:AudioStream;

func _ready()->void:
	if fighter.base and not fighter.base.special:
		for sfx:String in fighter.base.skill_use_sfx:
			fighter.skill_used.connect(play_sound_by_key.bind(sfx))
			
		for sfx:String in fighter.base.skill_hit_sfx:
			fighter.skill_hit.connect(skill_hit_sfx.bind(sfx))






func skill_hit_sfx(target_hit:ActiveFighter, key:String)->void:
	if target_hit is NpcFighter:
		target_hit.npc_sfx.play_sound_by_key(key)
