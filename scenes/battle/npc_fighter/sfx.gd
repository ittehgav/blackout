extends AudioStreamPlayer2D


@onready var fighter:ActiveFighter = get_parent()

@export var ally_death:AudioStream;
@export var enemy_death:AudioStream;

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

func _ready():
	if fighter is NpcFighter:
		for sfx:String in fighter.base.skill_use_sfx:
			fighter.skill_used.connect(play_sfx.bind(sfx))
			
		for sfx:String in fighter.base.skill_hit_sfx:
			fighter.skill_hit.connect(skill_hit_sfx.bind(sfx))

func play_sfx(key:String)->void:
	stream = self[key];
	play();



func _on_death(killer: ActiveFighter) -> void:
	if fighter.ally_team == Entities.in_fight_player.ally_team:
		play_sfx("ally_death");
	else:
		play_sfx("enemy_death");

func skill_hit_sfx(target_hit:ActiveFighter, key:String):
	target_hit.npc_sfx.play_sfx(key)
