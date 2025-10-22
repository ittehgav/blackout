extends Panel


signal leveling_finished;
## emmited AFTER ALL PERKS ARE CHOSEN/ANIMATED/APPLIED

## try to make this in away where it interrupts everything then resumes 
## after the player picks their reward
@export var perk_pool:Array[Perk]
var perks:Array[Perk];


@export var level_up_sfx:AudioStreamPlayer;
@export var perk_animation_display:ColorRect

@export var perks_container:HBoxContainer
@export var perk_option_btn:Button



## amount of times this need to be played, comes after EXP gains when the player levels
var queue:int = 0;

func player_leveled_up()->void:
	queue += 1;

func display_perks(repeat:bool=false)->void:
	queue -= 1
	var fade_in_time:float = .5;
	if repeat:
		fade_in_time = .25;
	
	perk_animation_display.hide()
	
	Tweens.ui_fade_in(self, fade_in_time)
	level_up_sfx.play();
	roll_perks()
	for c:Node in perks_container.get_children():
		c.queue_free();

	for perk:Perk in perks:
		generate_perk_option(perk)

func roll_perks()->void:
	perks = [];
	var name_pool:Array[String]
	while len(perks) < 3:
		var new_perk:Perk = perk_pool.pick_random();
		
		if new_perk.name not in name_pool:
			name_pool.append(new_perk.name)
			## duplicating them to make the ones that with RNG
			## get unique rolls when the player levels up 
			## multiple times in a single post-battle
			perks.append(new_perk.duplicate())


func generate_perk_option(perk:Perk)->void:
	var btn:Button = perk_option_btn.duplicate();
	btn.build_option(perk);
	perks_container.add_child(btn);
	btn.pressed.connect(perk_chosen.bind(perk));
	btn.show()


func perk_chosen(perk:Perk)->void:
	## make this in a way where it can do multiple perks in one lifecycle
	perk_animation_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in perk_animation_display.get_children():
		c.queue_free();
	perk.animation_callback(perk_animation_display);
	perk.apply();
	await Tweens.ui_fade_in(perk_animation_display).finished;
	perk_animation_display.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_perk_animation_display_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		if queue:
			perk_animation_display.mouse_filter = Control.MOUSE_FILTER_IGNORE;

			await Tweens.ui_fade_out(self, .25).finished;
			display_perks(true)
		else:
			Tweens.ui_fade_out(self)
			leveling_finished.emit();
