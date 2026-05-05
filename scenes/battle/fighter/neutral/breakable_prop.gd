class_name Prop
## for now just putting them on team_2 and only player can break it
extends CombatEntity;

func _ready()->void:
	if not sprite:
		for c:Node in get_children():
			## not unheard of to have random sprite2D nodes in these?
			if c is Sprite2D:
				sprite = c;
				return


func _on_death(_killer: ActiveFighter) -> void:
	dead = true;
	modulate.v = .5;
	modulate.a = .5;

	var tween:Tween = create_tween();
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), .3);
	tween.parallel().tween_property(self, "modulate:a", 0, .3)
	tween.tween_callback(queue_free)
