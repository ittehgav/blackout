extends Control

@export var dungeon_name_label:Label;
@export var current_wave_label:Label;

@export var wave_divider:TextureRect;
@export var wave_sample_scene:PackedScene;

@export var waves_hbox:HBoxContainer

@export var loot_sfx:AudioStreamPlayer
@export var cleared_sfx:AudioStreamPlayer

@export var cleared_overlay:ColorRect
@export var time_until_reset:Label;

@export var close_btn:Button


var wave_samples:Array[Control]

var dungeon_level:int;

var dungeon:Dungeon

@export var loot_overlay:TextureRect;



func load_dungeon(target:Dungeon)->void:
	clear_data()
	dungeon = target;
	if dungeon.cleared:
		load_cleared();
	else:
		
		current_wave_label.text = "Wave " + str(target.current_wave) + "/" + str(len(target.waves))
		
		for i:int in len(target.waves):
			var sample:WaveSample = wave_sample_scene.instantiate();
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

	Entities.main.set_substate("dungeon_prompt")
	Tweens.ui_fade_in(self);
	
func clear_data()->void:
	cleared_overlay.hide()
	wave_samples.clear()
	for c:Node in waves_hbox.get_children():
		c.queue_free();

func load_cleared()->void:
	refresh_cleared_overlay();
	cleared_overlay.show();

func refresh_cleared_overlay()->void:
	var hours:int = dungeon.hours_for_next_reset();
	var days:int = 0;
	var text:String = "Resets in "
	while hours > 24:
		days += 1
		hours -= 24;
	if days:
		text += str(days) + " D, "
	text += str(hours) + " h"
	time_until_reset.text = text;
	

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
	close_btn.disabled = true
	await Tweens.ui_fade_in(self).finished;
	if won:
		## here the dungeon has already advanced the wave so the 
		## just-defeated wave's index is the current one -2
		var sample_index:int =  dungeon.current_wave - 2
		var sample:Control = wave_samples[sample_index]
		var tween:Tween = sample.cleared_animation();
		if dungeon.current_wave < len(dungeon.waves):
			tween.tween_callback(refresh_wave_n)
		else:
			tween.tween_callback(loot_animation.bind(sample))

func refresh_wave_n()->void:
	current_wave_label.text = "Wave "+str(dungeon.current_wave)+'/'+str(len(dungeon.waves))

func loot_animation(sample:WaveSample)->void:
	var tween:Tween = create_tween();
	tween.tween_property(sample.chest, "custom_minimum_size", sample.chest.custom_minimum_size * 2, 1);
	tween.tween_callback(dungeon_final_loot.bind(sample));

func dungeon_final_loot(sample:WaveSample)->void:
	sample.custom_minimum_size /= 2;
	sample.size = sample.custom_minimum_size;
	loot_sfx.play();
	loot_overlay.display_loot(dungeon)

func dungeon_cleared_animation()->void:
	Entities.player_party.current_settlement.refresh()
	Entities.main.set_substate("dungeon_prompt")
	## setting it back from space request (even when it's unchanged)
	refresh_cleared_overlay()
	await Tweens.ui_fade_in(cleared_overlay).finished;
	close_btn.disabled = false
	cleared_sfx.play()


func _on_close_prompt_pressed() -> void:
	Tweens.ui_fade_out(self);
	Entities.main.set_substate("main");
