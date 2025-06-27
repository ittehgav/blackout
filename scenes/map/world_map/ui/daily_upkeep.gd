extends UIRoot

signal daily_upkeep_prompted;
signal daily_upkeep_finished;

@export var food_before:Label;
@export var food_after:Label;

@export var fuel_before:Label;
@export var fuel_after:Label;

@export var money_before:Label;
@export var money_after:Label;

@export var juice_before:Label;
@export var juice_after:Label;

@export var scrap_before:Label;
@export var scrap_after:Label;

@export var pay_all_btn:Button;
@export var cancel_all_btn:Button;
@export var auto_pick_btn:Button;

@export var recruit_upkeep_display_scene:PackedScene;
@export var grid:GridContainer


@export var confirm_btn:Button;

var total_costs:Dictionary[String, int];
var total_cancelled:int;
var total_displays:int;



func _on_world_map_hour_passed() -> void:
	if Entities.world_map.current_hour == 12:
		daily_upkeep()

func daily_upkeep()->void:
	if Entities.current_settlement:
		Entities.player.left_settlement.connect(daily_upkeep, CONNECT_ONE_SHOT)
		return
	Entities.world_map.pause_map();
	
	ui_sfx.play_stream("daily_upkeep");
	total_cancelled = 0;
	total_displays = 0;
	daily_upkeep_prompted.emit()
	for r:String in Index.all_resources:
		total_costs[r] = 0;
		
	for c in grid.get_children():
		c.queue_free();
	
	Tweens.ui_fade_in(self);
	for unit:FighterUnit in Entities.player.roster.units:
		total_displays += 1;
		var display:Control = recruit_upkeep_display_scene.instantiate();
		display.setup(unit);
		recursive_connect_ui_feedback(display)
		grid.add_child(display);
		
		for r:String in Index.all_resources:
			total_costs[r] += display.costs[r];
		display.payment_avoided.connect(avoid_payment);
		display.payment_commited.connect(commit_payment)
	
	for r:String in Index.all_resources:
		if r != "chips":
			self[r+"_before"].text = str(Entities.player.inventory[r]) + ' -> ';
	
	refresh_costs();
	
func refresh_costs(refresh_labels:bool=true)->void:
	pay_all_btn.disabled = total_cancelled == 0;
	cancel_all_btn.disabled = total_cancelled == total_displays;
	
	confirm_btn.disabled =  false;
	if refresh_labels:
		for r:String in Index.all_resources:
			if r != "chips":
				var after:int = Entities.player.inventory[r] - total_costs[r];
				self[r+"_before"].text = str(Entities.player.inventory[r]);
				self[r+"_after"].text =  "-" + str(total_costs[r]) + "="+str(after);
				if after < 0:
					confirm_btn.disabled = true
					self[r+"_before"].modulate.a = .2;
					self[r+"_after"].modulate.a = .2;
				else:
					self[r+"_before"].modulate.a = 1;
					self[r+"_after"].modulate.a = 1;
		
	
func avoid_payment(costs:Dictionary, refresh_labels:bool)->void:
	total_cancelled += 1;
	for r:String in Index.all_resources:
		total_costs[r] -= costs[r]
	refresh_costs(refresh_labels)

func commit_payment(costs:Dictionary, refresh_labels:bool)->void:
	total_cancelled -= 1;
	for r:String in Index.all_resources:
		total_costs[r] += costs[r];
	refresh_costs(refresh_labels)

func cancel_all()->void:
	for c in grid.get_children():
		c.toggle_payment(false, true);
	refresh_costs();

func pay_all()->void:
	for c in grid.get_children():
		c.toggle_payment(true, true)
	refresh_costs()


func auto_pick() -> void:
	var all_displays:Array=grid.get_children();
	for display:Control in all_displays:
		display.toggle_payment(true, true)
	
	var to_save:String = find_insufficient_resource();
	while to_save:
		var to_cancel:Control = null;
		for display:Control in all_displays:
			if display.paying and display.costs[to_save]:
				if not to_cancel or display.costs[to_save] > to_cancel.costs[to_save]:
					to_cancel = display
		to_cancel.toggle_payment(false, true);
		to_save = find_insufficient_resource();
	refresh_costs();

func find_insufficient_resource()->String:
	var current_difference:int = 0;
	var current_resource:String = "";
	for r:String in Index.all_resources:
		var difference:int = (Entities.player.inventory[r] - total_costs[r])* - 1
		if difference > current_difference:
			current_resource = r;
			current_difference = difference;
	return current_resource


func _on_confirm_pressed() -> void:
	confirm_btn.disabled = true
	if total_displays - total_cancelled:
		var tween:Tween=create_tween();
		ui_sfx.play_stream("daily_upkeep_paid")
		for r:String in Index.all_resources:
			if r != "chips":
				self[r+"_after"].hide();
				var before:int = Entities.player.inventory[r]
				Entities.player.inventory.change_resource(r, total_costs[r] * -1)
				tween.parallel().tween_method(set_before_label.bind(r), before, Entities.player.inventory[r], 1);
		
		var experience:int = get_upkeep_exp();
		
		for display:Control in grid.get_children():
			if display.paying:
				display.commit_payment(experience);
		await tween.finished;
		daily_upkeep_finished.emit();
		Entities.world_map.unpause_map();
		Tweens.ui_fade_out(self);
	else:
		ui_sfx.play_stream("daily_upkeep_missed")
		Tweens.ui_fade_out(self)

func set_before_label(value:int, resource:String)->void:
	var label:Label = self[resource + "_before"];
	label.text = str(value);

func get_upkeep_exp()->int:
	var highest_level:int = 0;
	for unit:FighterUnit in Entities.player.roster.units:
		if unit.level > highest_level:
			highest_level = unit.level;
	
	var total_exp_gain:int = int((highest_level + total_displays - total_cancelled)  * 2/(total_displays - total_cancelled));
	return total_exp_gain
