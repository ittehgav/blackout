extends Sprite2D
@export var base:FighterBase
@export var animation_player:AnimationPlayer;
@export var hit_scan:Area2D;


func sow()->void:
	hit_scan.set_collision_mask_value(base.fighter.enemy_team.team_n, true)
	show();
	animation_player.play("growth")

func explode()->void:
	Combat.aoe_damage(base.fighter, hit_scan)
	base.skill_finished.emit()## right now it's ok to emit it multiple times but that might cause trouble later
