extends Perk

@export var party_icon:PartyIcon

var base:FighterBase
var level:int
@onready var player:Player = get_tree().get_first_node_in_group("player")

func _ready()->void:
	if not (get_parent() is Control):
		return
	print("_R??? ", name)
	base = Index.fighters.random_fighter_base(true);
	level = randi_range(player.level/2, player.level * 1.25);
	description = "Add a [color="+title_color.to_html()+"] Level " + str(level) + " " + base.name + "[/color] to your party.";
	icon.atlas = base.texture



func floating_party_icon()->void:

	party_icon.show();
	var tween:Tween = create_tween();
	tween.tween_property(party_icon, "position:y", party_icon.position.y-20, .5);
	tween.tween_property(party_icon, "modulate:a", 0, .5);
	tween.tween_callback(party_icon.queue_free)
	await tween.finished;
	animation_finished.emit()


func animation_callback(display:Control)->void: 
	## just show the unit and their stats?
	panel.reparent(display)
	panel.show()
	
	await get_tree().create_timer(.5).timeout;
	sfx.play()
	panel.scale *= 2;
	floating_party_icon()
	var tween:Tween = create_tween();
	tween.tween_property(panel, "scale", Vector2.ONE, 1);
	await tween.finished;
	animation_finished.emit()

func apply()->void:
	var unit:FighterUnit = Index.scenes.fighter_unit.instantiate();
	unit.base = base;
	unit.level = level;
	unit.setup();
	player.roster.add_unit(unit)
