extends SfxPlayer2D
class_name NpcSkillSfxPlayer

@export var source:NpcFighter

@export var melee_attack:AudioStream;
@export var ranged_attack:AudioStream;

@export var crowd_control:AudioStream;


func _ready()->void:
	if source.base and source.base.skill.effects == [SkillComponent.Effect.special]:
		source.skill_used.disconnect(_on_npc_fighter_skill_used)

func _on_npc_fighter_skill_used() -> void:
	const r = FighterBase.SkillRange

	if source.base.skill_range == r.melee_range:
		play_sound_obj(melee_attack);
	else:
		play_sound_obj(ranged_attack)
