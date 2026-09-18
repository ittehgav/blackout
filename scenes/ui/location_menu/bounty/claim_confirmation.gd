extends ColorRect
class_name ClaimBountyConfirmation

var bounty_to_confirm:Bounty

@export var confirmation_panel:PanelContainer
@export var confirmation_label:RichTextLabel

@export var choose_a_unit:PanelContainer;
@export var deliver_unit_choices:HBoxContainer;


@export var player_resources:ResourcesDropdown;
@export var player_resources_panel:PanelContainer
@export var new_unit_sprite:Sprite2D
@export var claim_sfx:AudioStreamPlayer;

@export var claim_animation_container:Control

const bt = Bounty.Type

func refresh()->void:
	choose_a_unit.hide()




@export var money_gain_icon:ResourceIcon
@export var food_gain_icon:ResourceIcon
@export var fuel_gain_icon:ResourceIcon
@export var juice_gain_icon:ResourceIcon
@export var scrap_gain_icon:ResourceIcon
@export var chips_gain_icon:ResourceIcon

@export var item_to_deliver_sample:ItemSample
@export var unit_to_deliver_sample:UnitSample
@export var resource_to_deliver_icon:ResourceIcon;

func start_confirmation(b:Bounty, u:FighterUnit=null)->void:
	item_to_deliver_sample.hide();
	unit_to_deliver_sample.hide()
	resource_to_deliver_icon.get_parent().hide()
	Tweens.ui_fade_in(self)
	confirmation_panel.show()
	bounty_to_confirm = b
	
	match b.type:
		bt.clear_dungeon:
			assert(false);
		bt.deliver_item:
			item_to_deliver_sample.load_item(b.item_to_deliver, 4)
			item_to_deliver_sample.show()
			var item_name:String = Index.get_color_tag(b.item_to_deliver.color_tag) + b.item_to_deliver.unique_name
			confirmation_label.text = "Deliver "+item_name +"?"
		bt.deliver_resource:
			resource_to_deliver_icon.get_parent().show()
			resource_to_deliver_icon.resource = b.resource_to_deliver;
			resource_to_deliver_icon.setup();
			resource_to_deliver_icon.label.text = str(b.resource_amount);
			
			confirmation_label.text = "Deliver " + Index.get_color_tag(b.resource_to_deliver)\
			+str(b.resource_amount) + " " + b.resource_to_deliver + "[/color]?"
		bt.deliver_unit:
			Tweens.ui_fade_out(choose_a_unit);
			confirmation_label.text = "Deliver your [color=yellow]Level " + str(u.level) + " " + str(u.base.name) + "?"
			unit_to_deliver_sample.load_unit(u);
			unit_to_deliver_sample.show()

var unit_to_deliver:FighterUnit;
func deliver_unit_confirmation(b:Bounty)->void:
	Tweens.ui_fade_in(self)
	var deliverable:Array[FighterUnit] = get_deliverable_units(b);
	if len(deliverable) == 1:
		start_confirmation(b, deliverable[0])
	else:
		confirmation_panel.hide()
		choose_a_unit.show()
		for c in deliver_unit_choices.get_children():
			c.queue_free()
		
		for f in deliverable:
			var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
			sample.load_unit(f);
			deliver_unit_choices.add_child(sample);
			sample.pressed.connect(start_confirmation.bind(b, f));

	get_parent().recursive_connect_ui_feedback(self)
		


func get_deliverable_units(b:Bounty)->Array[FighterUnit]:
	return Entities.player.roster.units.filter(
		func(f:FighterUnit)->bool:
				return f.base == b.unit_base and f.level >= b.unit_level)



func deliver_resource_confirmation(b:Bounty)->void:
	bounty_to_confirm = b


func claim_animation(b:Bounty)->void:
	claim_animation_container.show()
	confirmation_panel.hide()
	claim_sfx.play();
	
	## will animate first then apply the chanes
	var fade_in:Tween = Tweens.ui_fade_in(self)

	player_resources.update();
	new_unit_sprite.hide()
	var to_tween:Dictionary[Label, int]
	if b.money_reward or not b.resources_reward.is_empty():
		player_resources_panel.show()
		for r:String in Resources.all_resources:
			var gain_icon:ResourceIcon = self[r+"_gain_icon"]
			var gain_hbox:HBoxContainer = gain_icon.get_parent();
			gain_hbox.hide()
			
			var hbox:HBoxContainer = player_resources.resource_hboxes[r]
			var label:Label = player_resources.resource_icons[r].label;
			hbox.hide();
			if r == "money" and b.money_reward:
					gain_icon.label.text = "+" + str(b.money_reward)
					gain_hbox.show()
					
					hbox.show()
					var new_value:int = Entities.player.inventory.money + b.money_reward
					to_tween[label] = new_value
			else:
				if r in b.resources_reward:
					gain_icon.label.text = "+"+ str(b.resources_reward[r])
					gain_hbox.show()
					
					hbox.show()
					var new_value:int = Entities.player.inventory[r] + b.resources_reward[r]
					to_tween[label] = new_value
		player_resources_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
		player_resources_panel.position += Vector2(10, 40)
	

	if b.unit_reward:
		new_unit_sprite.texture = b.unit_reward.base.texture;
		new_unit_sprite.show()
	player_resources_panel.size = Vector2.ZERO
	
	await fade_in.finished;

	for l:Label in to_tween.keys():
		var tween:= create_tween();
		tween.tween_property(l, "theme_override_font_sizes/font_size", 96, .2);
		tween.tween_property(l, "theme_override_font_sizes/font_size", 64, .2);
		tween.tween_property(player_resources_panel, "size", Vector2.ZERO, .2)
		Tweens.tween_count_label(l, to_tween[l])


func _on_cancel_pressed() -> void:
	Tweens.ui_fade_out(self)


func _on_confirm_pressed() -> void:
	await claim_animation(bounty_to_confirm)
	
	bounty_to_confirm.claim()


func _on_continue_pressed() -> void:
	await Tweens.ui_fade_out(self).finished
	claim_animation_container.hide()


func _on_cancel_deliver_unit_pressed() -> void:
	await Tweens.ui_fade_out(self).finished
	choose_a_unit.hide()
