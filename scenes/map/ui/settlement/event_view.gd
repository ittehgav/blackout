extends Control

@export var settlement_ui:Control;

@export var stat_gain_sfx:AudioStreamPlayer;
@export var resource_gain_sfx:AudioStreamPlayer;

@export var sky_view:Control;

@export var confirmation_panel:Panel;
@export var conclusion_panel:Panel;


@export_group("Confirmation View Elements")
@export var samples_container:GridContainer;

@export var name_label:Label;
@export var description_label:RichTextLabel;
@export var available_units_label:Label;

@export var money_cost_label:Label;
@export var time_cost_label:Label;

@export var confirm_btn:Button;

@export_group("Conclusion View Elements")

@export var resrource_gains_container:VBoxContainer;
@export var conclusion_samples_container:GridContainer;

var conclusion_samples:Dictionary[FighterUnit, SpriteSample]
var resource_gains_to_show:Array[HBoxContainer]


var event:LocalEvent;

func _ready()->void:
	money_cost_label.add_theme_color_override("font_color", Index.get_color("money"));


func setup_event_confirmation(target:LocalEvent)->void:
	Tweens.ui_fade_in(confirmation_panel)
	conclusion_panel.hide();
	event = target;
	
	name_label.text = event.name;
	description_label.text = event.description;
	available_units_label.text = "Available " + event.tag.capitalize() + "s";
	
	time_cost_label.hide();
	money_cost_label.hide();
	
	if event.time_cost:
		time_cost_label.show();
		time_cost_label.text = "Time: " + str(event.time_cost) + " hours";
	if event.money_change < 0:
		money_cost_label.show();
		money_cost_label.text = "Price: $" + str(-event.money_change);
	
	if Entities.player.inventory.money < -event.money_change:
		confirm_btn.text = "Not enough money";
		confirm_btn.disabled = true;
	else:
		confirm_btn.text = "Confirm";
		confirm_btn.disabled = false;
	
	
	for c:Node in samples_container.get_children():
		c.free()
	
	for unit:FighterUnit in Entities.player.roster.units:
		if event.tag in unit.base.tags:
			add_sample(unit);
	


func add_sample(unit:FighterUnit)->void:
	var sample:SpriteSample = Index.sprite_sample_scene.instantiate()
	sample.set_sample(unit.base);
	samples_container.add_child(sample)
	var level_label:Label = Label.new();
	level_label.text = "Lvl. " + str(unit.level);
	level_label.set_anchors_preset(PRESET_BOTTOM_LEFT);
	sample.add_child(level_label);


func _on_confirm_pressed() -> void:
	if event.time_cost:
		Tweens.ui_fade_out(confirmation_panel);
		var tween:Tween = await sky_view.pass_time(event.time_cost)
		await tween.finished;
		setup_conclusion()
		var return_tween:Tween = sky_view.return_camera();
		await return_tween.finished;
		conclude_event();
	else:
		setup_conclusion();
		conclude_event();

func setup_conclusion()->void:
	var affected_units:Array[FighterUnit] = Entities.player.roster.units.filter\
	(func(u:FighterUnit)->bool:return event.tag in u.base.tags);
	for unit:FighterUnit in affected_units:
		var sample:SpriteSample = Index.sprite_sample_scene.instantiate();
		sample.set_sample(unit.base);
		conclusion_samples_container.add_child(sample)
		conclusion_samples[unit] = sample;
	
	
	for r:String in Index.all_resources:
		var hbox:HBoxContainer = resrource_gains_container.get_node(r);
		hbox.hide()
		if event[r+"_change"] > 0:
			resource_gains_to_show.append(hbox);
			var label:Label = resrource_gains_container.get_node(r+"/"+r);
			label.text = str(event[r+'_change'])


func conclude_event()->void:
	if event.money_change < 0:
		Entities.player.inventory.change_resource("money", event.money_change)
	Tweens.ui_fade_in(conclusion_panel)
	
	var floating_changes:Array[Array];
	for stat:String in Index.all_combat_stats:
		var gain:int = event["units_"+stat+ "_gain"];
		if gain:
			var current_array:Array[HBoxContainer] = []
			floating_changes.append(current_array);
			for unit:FighterUnit in conclusion_samples.keys():
				var sample:SpriteSample = conclusion_samples[unit];
				
				var stat_change:float = Scaling.event_stat_value_multipliers[stat] * gain;
				unit.gain_stat_modifier(stat, stat_change)
			
				var container:HBoxContainer = HBoxContainer.new();
				var icon:StatIcon = Index.stat_icon_scene.instantiate();
				icon.stat = stat;
				
				var label:Label = Label.new();
				label.text = str(stat_change)
				label.modulate = Index.stat_colors[stat];
				
				container.add_child(icon);
				container.add_child(label);
				container.hide();
				sample.add_child(container);
				current_array.append(container);

	for array:Array in floating_changes:
		for container:HBoxContainer in array:
			stat_gain_sfx.play()
			container.show();
			var tween:Tween = create_tween();
			tween.tween_property(container, "position:y", container.position.y-20, .25);
			tween.parallel().tween_property(container, "modulate:a", 0, .35);
			tween.tween_callback(container.queue_free);
		await get_tree().create_timer(.5).timeout
	
	for r:String in Index.all_resources:
		var change:int = event[r+"_change"];
		if change > 0:
			$conclusion/resource_gains/resource_gain_message.show();
			Entities.player.inventory.change_resource(r, change);
			get_node("conclusion/resource_gains/" + r).show();
			resource_gain_sfx.play()
			await get_tree().create_timer(.5).timeout
			


func _on_cotinue_pressed() -> void:
	settlement_ui.current_settlement.local_event = null;
	settlement_ui.local_event_btn.hide();
	settlement_ui.show_main_view()
