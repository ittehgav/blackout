extends UIRoot;

class_name PlayerSheet;

@export var bg:ColorRect;
 
@export_group("elements")
@export var left_tab_container:TabContainer;
@export var container:HBoxContainer;
@export var gear:Control;
@export var morale_label:Label;

@export var consumables_inventory:GridContainer;
@export var trinkets_inventory:GridContainer;
@export var weapons_inventory:GridContainer;

@export var item_feedback:Panel;
@export var recruit_full_view:Control;

@export_subgroup("sounds")
@export var open_sound:AudioStream;
@export var close_sound:AudioStream;
@export var rummage:AudioStream;
@export var consumable_used:AudioStream;
@export var equip:AudioStream;

@export_category("Elements")
@export_subgroup("Resource Labels")
@export var food_label:Label;
@export var fuel_label:Label;
@export var money_label:Label;
@export var juice_label:Label;
@export var scrap_label:Label;
@export var chips_label: Label;

@export_subgroup("Combat Stat Labels")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var agility_label:Label;
@export var technique_label:Label;

@export_subgroup("Packed Scenes")
@export var item_icon_scene:PackedScene;

const resources_names = [
	"food", "fuel", "money", "scrap", "juice", "scrap", "chips"
]

@export_subgroup("Levels")
@export var leadership_level_label:Label;
@export var leadership_level_progress:ProgressBar;

@export var combat_level_label:Label;
@export var combat_level_progress:ProgressBar;

@export_subgroup("Leadership Stat Labels")
@export var charisma_label:Label;
@export var navigation_label:Label;
@export var tactics_label:Label;
@export var logistics_label:Label;


func _ready()->void:
	super();
	Entities.player_sheet = self;
	Entities.player.resources_changed.connect(refresh_data)

func _input(e:InputEvent)->void:
	if e.is_action_pressed("show_player_sheet") and not visible:
		show_player_sheet()
	elif visible and not recruit_full_view.visible and (e.is_action_pressed("ui_cancel")\
	 or e.is_action_pressed("show_player_sheet")):
		hide_player_sheet();

func show_player_sheet(left_tab_view:int=0)->void:
	left_tab_container.get_child(left_tab_view).show()
	ui_sfx.play_stream_obj(open_sound)
	show()
	refresh_data();
	Entities.in_map_player.stop_movement(false)
	get_tree().paused = true;
	Entities.world_map.pause_map()
	bg.self_modulate.a = 0;
	
	const tween_duration = .4;
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bg, "self_modulate:a", 1, tween_duration);
	tween.parallel().tween_property(container, "theme_override_constants/separation", 20, tween_duration)


func hide_player_sheet()->void:
	ui_sfx.play_stream_obj(close_sound)
	const tween_duration = .25;
	var tween:Tween = create_tween();
	tween.tween_property(container, "theme_override_constants/separation", 1700, tween_duration);
	tween.parallel().tween_property(bg, "self_modulate:a", 0, tween_duration)
	await tween.finished
	Entities.world_map.unpause_map()
	hide()


func refresh_data()->void:
	## will show upkeep costs when upkeep is implemented
	morale_label.text = "Morale: " + str(snapped(Entities.player.morale, .01));
	
	gear.refresh_samples()
	var inv:Inventory = Entities.player.inventory;
	food_label.text = "Food: " + str(inv.food);
	fuel_label.text = "Fuel: " + str(inv.fuel);
	money_label.text = "Money: $" + str(inv.money);
	
	juice_label.text = "Juice: " + str(inv.juice);
	scrap_label.text = "Scrap: " + str(inv.scrap);
	chips_label.text = "Chips: " + str(inv.chips);

	var stats: LeadershipStats = Entities.player.leadership_stats;
	charisma_label.text = "Charisma: " + str(stats.charisma);
	navigation_label.text = "Navigation: " + str(stats.navigation);
	tactics_label.text = "Tactics: " + str(stats.tactics);
	logistics_label.text = "Logistics: " + str(stats.logistics)

	leadership_level_label.text = "Leadership Level: " + str(Entities.player.leadership_level);
	combat_level_label.text = "Combat Level: " + str(Entities.player.combat_level);

	leadership_level_progress.max_value = Scaling.exp_for_next_level(Entities.player.leadership_level);
	leadership_level_progress.value = Entities.player.leadership_exp;

	combat_level_progress.max_value = Scaling.exp_for_next_level(Entities.player.combat_level);
	combat_level_progress.value = Entities.player.combat_exp;
	
	var cstats:CombatStats = Entities.player.combat_stats;

	max_hp_label.text = "Max HP: " + str(cstats.max_hp);
	attack_label.text = "Base Attack: " + str(cstats.attack);
	defense_label.text = "Defense: " + str(cstats.defense);
	agility_label.text=  "Agility: " + str(cstats.agility);
	technique_label.text = "Technique: " + str(cstats.technique);
	for c in consumables_inventory.get_children():
		c.queue_free();
	for t  in trinkets_inventory.get_children():
		t.queue_free();
	for w in weapons_inventory.get_children():
		w.queue_free();

	var inventory:Inventory = Entities.player.inventory;
	for item:Item in inventory.consumables +inventory.trinkets + inventory.weapons:
		var icon:ItemIcon = item_icon_scene.instantiate();
		icon.item = item;
		if item is Consumable:
			consumables_inventory.add_child(icon)
			icon.gui_input.connect(use_consumable.bind(item))
	
		if item is Trinket:
			trinkets_inventory.add_child(icon)
		if item is Weapon and not item.get_instance_id() == Entities.player.equipped_weapon.get_instance_id():
			weapons_inventory.add_child(icon);
			icon.gui_input.connect(equip_weapon.bind(item));
	
func use_consumable(e:InputEvent, item:Consumable)->void:
	if e.is_action_pressed("use_item"):
		if item.use():
			ui_sfx.play_stream_obj(rummage)
			await item_feedback.use_animation(item);
			ui_sfx.play_stream_obj(consumable_used)
			Entities.player.inventory.remove_child(item);
			refresh_data()


func equip_weapon(e:InputEvent, weapon:Weapon)->void:
	if e.is_action_pressed("use_item"):
		ui_sfx.play_stream_obj(equip)
		Entities.player.equipped_weapon = weapon
		refresh_data()
