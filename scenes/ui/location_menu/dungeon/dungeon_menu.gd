@icon("res://assets/visual/editor_ui/IconGodotNode/control/icon_skull.png")
extends UIRoot

class_name DungeonMenu;

signal exited;
signal battle_started(wave:Roster)


@export var dungeon_name_label:Label;
@export var content_hbox:HBoxContainer

@export var wave_hboxes:Array[HBoxContainer]

@export var wave_power_icon:PartyPowerIcon;
@export var dungeon_power_label:Label;

@export var whole_skull_texture:Texture;
@export var broken_skull_texture:Texture;

var dungeon:Dungeon
var current_wave_index:int;

func load_dungeon(target:Dungeon)->void:
	dungeon = target
	Entities.current_dungeon = dungeon
	
	dungeon_name_label.text = dungeon.name;
	current_wave_index = dungeon.current_wave - 1;
	
	var current_wave:NpcRoster = dungeon.get_current_wave();
	var current_wave_level:int = current_wave.get_level();
	var current_wave_danger:int = dungeon.get_current_wave().get_danger_level()
	
	dungeon_power_label.text = str(current_wave_level);
	
	
	var target_modulate:Color
	match current_wave_danger:
		1:
			target_modulate = Color.GREEN_YELLOW;
		2:
			target_modulate = Color.WHITE;
		3:
			target_modulate = Color.PALE_VIOLET_RED;
			dungeon_power_label.text += "!"
		4:
			target_modulate = Color.FIREBRICK
			dungeon_power_label.text += "!!!"
	
	wave_power_icon.modulate = target_modulate;
	dungeon_power_label.modulate = target_modulate
	var i:int = 0;
	for wave:NpcRoster in dungeon.waves:
		var hbox:HBoxContainer=wave_hboxes[i];
		i += 1
		var shown_bases:Array[FighterBase]
		var skull:TextureRect = hbox.get_parent().get_node("skull")
		if i <= current_wave_index:
			skull.texture = broken_skull_texture;
			skull.get_node("cleared").show()
		else:
			skull.texture = whole_skull_texture
			skull.get_node("cleared").hide();
		
		for unit:FighterUnit in wave.units:
			if unit.base not in shown_bases:
				shown_bases.append(unit.base);
				var preview:TextureRect = generate_unit_preview(unit.base);
				hbox.add_child(preview)
				
	slide_in()
				
func slide_in()->void:
	show()
	content_hbox.add_theme_constant_override("separation", 400);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 20, .75)

func slide_out()->void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 400, .5)
	tween.parallel().tween_property(self, "modulate:a", 0, .5);
	tween.tween_callback(hide);
	tween.tween_callback(set_modulate.bind(Color.WHITE))


const atlas_rect:Rect2 = Rect2(640, 0, 128, 128)
func generate_unit_preview(base:FighterBase)->TextureRect:
	var rect:TextureRect = TextureRect.new();
	rect.texture = AtlasTexture.new();
	rect.texture.atlas = base.texture;
	rect.texture.region = atlas_rect;
	return rect


@onready var initial_wave_hbox_modulate:Color = wave_hboxes[0].modulate;
func _on_start_next_wave_mouse_entered() -> void:
	wave_hboxes[current_wave_index].get_node("highlight_animation").play("highlight")


func _on_start_next_wave_mouse_exited() -> void:
	wave_hboxes[current_wave_index].get_node("highlight_animation").stop()


func _on_start_next_wave_pressed() -> void:
	State.set_substate(State.Substate.pre_battle)


func _on_exit_btn_pressed() -> void:
	slide_out();
	exited.emit()

func show_post_fight(won:bool)->void:
	if not dungeon:return ## keep the tutorial location from popping up
	load_dungeon(dungeon)
	wave_cleared();

func wave_cleared()->void:
	var just_cleared_wave:int = dungeon.current_wave;
	dungeon.current_wave += 1;
	current_wave_index += 1;
	

	var hbox:HBoxContainer = wave_hboxes[just_cleared_wave - 1]
	var animation:AnimationPlayer = hbox.find_child("highlight_animation")
	animation.play("wave_cleared")

	
