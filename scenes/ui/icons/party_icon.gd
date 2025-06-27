extends TextureRect

class_name PartyIcon
@export var upgrade_arrow:Sprite2D;
@export var display_upgradeable:bool=false;

@export var count_label:Label;
var leader:Leader;

func _ready()->void:
	if Entities.player:
		Entities.player.party_changed.connect(refresh)
		refresh();
	if display_upgradeable:
		arrow_origin = upgrade_arrow.position;
		arrow_loop();
	else:
		upgrade_arrow.queue_free();

var arrow_origin:Vector2
func arrow_loop()->void:
	upgrade_arrow.position = arrow_origin;
	var tween:Tween = create_tween();
	tween.tween_property(upgrade_arrow, "position:y", arrow_origin.y - 15, .5);
	tween.tween_interval(.5);
	tween.tween_callback(arrow_loop);

func refresh()->void:
	if count_label:
		if not leader:
			leader = Entities.player;
		count_label.text = str(len(leader.roster.units));
	if display_upgradeable:
		refresh_arrow();
func refresh_arrow()->void:
	upgrade_arrow.hide();
	upgrade_arrow.modulate.v = 0;
	upgrade_arrow.modulate.a = .5
	for unit:FighterUnit in Entities.player.roster.units:
		if unit.upgrade_available():
			upgrade_arrow.show()
			if unit.upgrade_affordable():
				upgrade_arrow.modulate.v = 1;
				upgrade_arrow.modulate.a = 1;



func _on_visibility_changed() -> void:
	if leader:
		refresh();
