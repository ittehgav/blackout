extends Control

@export var dungeon_name_label:Label;
@export var dungeon_level_label:Label;

@export var skull_1:TextureRect;
@export var skull_2:TextureRect;
@export var skull_3:TextureRect;

var dungeon_level:int;

var dungeon:Dungeon

func load_dungeon(target:Dungeon)->void:
	dungeon = target;
	if not dungeon.cleared:
		dungeon.generate_waves();
		dungeon_name_label.text = dungeon.name;
		dungeon_level = dungeon.waves[-1].get_level()
		dungeon_level_label.text = str(dungeon_level)

		setup_skulls();
	
	Tweens.ui_fade_in(self);

func setup_skulls()->void:
	var danger_level:int = dungeon.get_danger_level()
	match danger_level:
		1:
			skull_2.hide();
			skull_3.hide();
			## they all have the same material so i can just call it from skull_1 and it 
			## changes the material's properties in all of them
			skull_1.material.set_shader_parameter("color:a",0);
		2:
			skull_2.show();
			skull_3.hide();
			
			skull_1.material.set_shader_parameter("color:a",0);
		3:
			skull_2.show();
			skull_3.show();

			skull_1.material.set_shader_parameter("color:a",0);
		4:
			skull_2.show();
			skull_3.show();
		
			skull_1.material.set_shader_parameter("color:a", 1);

	
	


func _on_enter_pressed() -> void:
	Entities.player_sheet.pre_battle_sheet();
	Tweens.ui_fade_out(self);

func _on_return_pressed() -> void:
	Tweens.ui_fade_out(self);
	Entities.player_party.visit_settlement()


func _on_player_sheet_start_battle_pressed() -> void:
	Entities.current_dungeon = dungeon;
	Entities.main.set_scenario("battle")
