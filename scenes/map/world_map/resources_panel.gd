extends PanelContainer

@export var hud:Control;

@export var food_label:Label;
@export var fuel_label:Label;
@export var money_label:Label;

@export var juice_label:Label;
@export var scrap_label:Label;
@export var chips_label:Label;

@export var floating_change:Control;
@export var sfx:AudioStreamPlayer;

var current_tween:Tween;
var tween_queue:Array;


func _on_player_resource_changed(resource: String, change:float) -> void:
	var fchange:Control = floating_change.duplicate();
	fchange.get_node("resource_icon").resource = resource;
	fchange.get_node("value").text = str(change)
	if change  < 0:
		fchange.get_node("value").modulate = Color.RED;
	else:
		fchange.get_node("value").modulate = Color.GREEN
	
	const tween_duration = .75
	if not current_tween or not current_tween.is_running():
		if change < 0:
			sfx.play_sound_by_key("resource_loss");
		else:
			sfx.play_sound_by_key("resource_gain")

		fchange.show();
		add_sibling(fchange)
		
		current_tween = create_tween();
		current_tween.tween_property(fchange, "position:y", fchange.position.y - 50, tween_duration);
		current_tween.parallel().tween_property(fchange, "modulate:a", 0, tween_duration);
		current_tween.tween_callback(fchange.queue_free);
	else:
		current_tween.tween_callback(add_sibling.bind(fchange))
		current_tween.tween_callback(fchange.show);
		
		if change < 0:
			current_tween.tween_callback(sfx.play_sound_by_key.bind("resource_loss"));
		else:
			current_tween.tween_callback(sfx.play_sound_by_key.bind("resource_gain"));
		
		current_tween.tween_property(fchange, "position:y", fchange.position.y - 50, tween_duration);
		current_tween.parallel().tween_property(fchange, "modulate:a", 0, tween_duration);
		current_tween.tween_callback(fchange.queue_free);
		
func animate_resource_change(resource:String, change:int)->void:
	if resource == "money":
		hud.sfx.play_sound_by_key('money_change');
	
	var label:Label = self[resource+"_label"];
	var current_value:int = int(label.text);
	var target_value :int= current_value + change;
	
	label.add_theme_font_size_override("font_size", 128);
	
	var tween:Tween = create_tween();
	tween.tween_method(set_resource_label_text.bind(label), current_value, target_value, .75);
	tween.tween_property(label, "theme_override_font_sizes/font_size", 64, .1)


func set_resource_label_text(value:int, label:Label)->void:
	label.text = str(value);
