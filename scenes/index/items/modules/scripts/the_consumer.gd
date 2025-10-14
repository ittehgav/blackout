extends Module

const rarity = 3

const base_damage = 50;

@export var ticker:Timer;

@export var hit_scan:Area2D

func get_description()->String:
	return "Hold to continuously spend money and drain HP from enemies in an increasingly larger area.";

func start()->void:
	use_sfx.play();
	ammo_cost = 5;
	hit_scan.show()
	ticker.start()

func release()->void:
	use_sfx.stop()
	use_sfx.pitch_scale = 1
	if growth_tween and growth_tween.is_running():
		growth_tween.kill()
	
	hit_scan.hide()
	hit_scan.scale = Vector2.ONE
	ticker.stop()

var growth_tween:Tween
func _on_ticker_timeout() -> void:
	if use_sfx.pitch_scale < 7:
		use_sfx.pitch_scale *= 1.1

	Combat.aoe_damage(Entities.player_fighter, hit_scan, ticker_damage);
	consume_ammo();
	ammo_cost += 1
	
	var target_scale:Vector2 = hit_scan.scale * 1.1
	growth_tween = create_tween();
	growth_tween.tween_property(hit_scan, "scale", target_scale, .45)




func ticker_damage(_damage:int)->int:
	return base_damage;


func _on_equipped() -> void:
	hit_scan.reparent(Entities.player_fighter)
	hit_scan.position = Vector2.ZERO
