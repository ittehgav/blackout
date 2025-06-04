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

var resource_tweens:Dictionary[String, Tween];
var tween_queue:Array;

func _ready()->void:
	for r:String in Index.all_resources:
		resource_tweens[r] = create_tween();
		resource_tweens[r].kill()

		
func animate_resource_change(resource:String, change:int)->void:
	if resource == "money":
		hud.sfx.play_sound_by_key('money_change');

	
	if not resource_tweens[resource].is_running():
		var label:Label = self[resource+"_label"];
		var current_value:int = int(label.text);
		var target_value :int = current_value + change;
		
		label.add_theme_font_size_override("font_size", 128);
		
		var previous_alpha:float = modulate.a;
		var previous_z:int = z_index;
		z_index += 10
		modulate.a = 1;
		
		if change < 0:
			label.add_theme_color_override("font_color", Color.RED)
		resource_tweens[resource] = create_tween();
		resource_tweens[resource].tween_method(set_resource_label_text.bind(label), current_value, target_value, .75);
		resource_tweens[resource].tween_property(label, "theme_override_font_sizes/font_size", 64, .1)
		await resource_tweens[resource].finished;
		label.add_theme_color_override("font_color", Index.resource_colors[resource])
		modulate.a = previous_alpha;
		z_index = previous_z
func set_resource_label_text(value:int, label:Label)->void:
	label.text = str(value);
