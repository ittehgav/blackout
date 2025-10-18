extends Control

@export var dungeon_name_label:Label;
@export var current_wave_label:Label;

@export var wave_divider:TextureRect;
@export var wave_sample_scene:PackedScene;

@export var waves_hbox:HBoxContainer

var wave_samples:Array[Control]

var dungeon_level:int;

var dungeon:Dungeon

func load_dungeon(target:Dungeon)->void:
	clear_data()
	
	dungeon = target;
	current_wave_label.text = "Wave " + str(target.current_wave) + "/" + str(len(target.waves))

	
	for i:int in len(target.waves):
		var sample:Control = wave_sample_scene.instantiate();
		sample.load_roster(target, i + 1);
		waves_hbox.add_child(sample);
		wave_samples.append(sample)
		
		if i < len(target.waves) - 1:
			var divider:TextureRect = wave_divider.duplicate();
			waves_hbox.add_child(divider)
			divider.show()
			if i < target.current_wave -1 :
				divider.modulate.a = .5;
				divider.modulate.v = .5;

	Tweens.ui_fade_in(self);
	
func clear_data()->void:
	wave_samples.clear()
	for c:Node in waves_hbox.get_children():
		c.queue_free();



func _on_enter_pressed() -> void:
	Entities.player_sheet.pre_battle_sheet();
	Tweens.ui_fade_out(self);

func _on_return_pressed() -> void:
	Tweens.ui_fade_out(self);
	Entities.player_party.visit_settlement()


func _on_player_sheet_start_battle_pressed() -> void:
	Entities.current_dungeon = dungeon;
	Entities.main.set_scenario("battle")
	Entities.arena.battle_ended.connect(dungeon.on_battle_ended, CONNECT_ONE_SHOT)
	Entities.world_map.returned_from_battle.connect(post_battle)
	
func post_battle(won:bool)->void:
	
	await Tweens.ui_fade_in(self).finished;
	if won:
		## here the dungeon has already advanced the wave so the 
		## just-defeated wave's index is the current one -2
		var sample_index:int =  dungeon.current_wave - 2
		var sample:Control = wave_samples[sample_index]
		sample.cleared_animation();
		

		
