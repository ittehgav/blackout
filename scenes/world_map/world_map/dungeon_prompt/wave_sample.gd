extends Control

@export var broken_skull:TextureRect
@export var skull:TextureRect
@export var chest:TextureRect

@export var wave_cleared_sfx:AudioStreamPlayer
@export var tooltip:Tooltip

func load_roster(dungeon:Dungeon, wave_n:int)->void:
	## NEEDS TO RUN BEFORE ENTERING TREE
	tooltip.hardcoded_name = "Wave " + str(wave_n)
	if dungeon.current_wave > wave_n:
		load_cleared()
		return;
		

	var roster:DungeonRoster = dungeon.waves[wave_n-1];
	var danger_level:int = roster.get_danger_level();
	## so it doesn't apply outline changes to every other wave sample
	skull.material = skull.material.duplicate()
	tooltip.hardcoded_description = "Power Level: " + str(roster.get_level())

	match danger_level:
		1:
			skull.show();
		2:
			skull.show();
			skull.material.set_shader_parameter("color:a", 1);
		3:
			skull.show();
			skull.material.set_shader_parameter("color:a", 1)
			skull.material.set_shader_parameter("width", 2)
		4:
			skull.show();
			skull.custom_minimum_size = Vector2(96, 96);
			skull.material.set_shader_parameter("color", Color.RED)
			skull.material.set_shader_parameter("width", 2)
	if roster.loot.rare_count:
		chest.show()

func load_cleared()->void:
	broken_skull.show();
	tooltip.hardcoded_description = "You have already defeated this wave.";

func cleared_animation()->void:
	var tween:Tween = create_tween();
	tween.tween_property(skull, "scale", skull.scale * 1.5, .5)
	tween.parallel().tween_property(skull, "material:shader_parameter/width", 4, .5);
	tween.tween_property(skull, "scale", skull.scale, .25);
	tween.parallel().tween_property(skull, "modulate:a", 0, .25)
	tween.tween_callback(turn_cleared)


func turn_cleared()->void:
	wave_cleared_sfx.play();
	skull.hide();
	broken_skull.show();
	
	var parent:Node = get_parent()
	var child_count:int = parent.get_child_count()
	
	for i:int in child_count:
		var to_check:Node = parent.get_child(i);
		if to_check == self:
			if i < child_count - 1:
				var divider:TextureRect = parent.get_child(i + 1);
				divider.modulate.v = .5;
				divider.modulate.a = .5;
				break
	var prompt:Control = find_dungeon_prompt();
	var shift:Vector2 = Vector2(randi_range(-10, 10), randi_range(-10, 10));
	prompt.position += shift;
	var tween:Tween = create_tween();
	tween.tween_property(prompt, "position", prompt.position - shift, .25);
	
	
	
func find_dungeon_prompt()->Control:
	var parent:Node = get_parent();
	while(parent.name != "dungeon_prompt"):
		parent = parent.get_parent();
	return parent
