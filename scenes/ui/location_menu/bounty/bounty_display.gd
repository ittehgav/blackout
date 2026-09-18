extends PanelContainer
class_name BountyDisplay

var bounty:Bounty

signal unit_reward_clicked
signal claim_pressed(b:Bounty)

@export var bounty_icon:TextureRect
@export var bounty_name:RichTextLabel;
@export var claimed_rect:ColorRect

@export var resource_rewards:ResourcesDropdown;

@export var unit_reward_sample:UnitSample;

@export var claim_button:Button;

const bt = Bounty.Type

func load_bounty(target:Bounty)->void:
	bounty = target
	if bounty.already_claimed:
		claimed_rect.show()
	else:
		bounty.claimed.connect(claimed_rect.show);
	match target.type:
		bt.clear_dungeon:
			bounty_name.text = "Clear [color=yellow]" + target.dungeon_clear_target.name;
			bounty_icon.texture = target.dungeon_clear_target.map_texture;
		bt.deliver_resource:
			bounty_name.text = "Deliver "+Index.get_color_tag(target.resource_to_deliver) + str(target.resource_amount) + " " + target.resource_to_deliver;
			bounty_icon.texture = Index.textures.icons[target.resource_to_deliver];
		bt.deliver_unit:
			bounty_name.text = "Deliver a level "+Index.get_color_tag("chips") + str(target.unit_level) + "+ " + target.unit_base.name;
			
			var at:AtlasTexture = AtlasTexture.new();
			at.atlas = target.unit_base.texture;
			at.region = Rect2(384, 0, 128, 128)
			bounty_icon.texture = at;
		bt.deliver_item:
			var rtag:String = Index.get_color_tag(target.item_to_deliver.color_tag)
			bounty_name.text = "Deliver a "+rtag + target.item_to_deliver.unique_name;
			bounty_icon.texture = target.item_to_deliver.texture;
			bounty_icon.modulate = Index.get_color(target.item_to_deliver.color_tag)
	
	for r:String in Resources.all_resources:
		var hbox:HBoxContainer = resource_rewards.resource_hboxes[r]
		if not r in target.resources_reward:
			hbox.hide()
		else:
			var label:Label = resource_rewards.resource_icons[r].label;
			hbox.show();
			label.text = str(target.resources_reward[r]);
	if target.money_reward:
		resource_rewards.resource_hboxes.money.show();
		resource_rewards.resource_icons.money.label.text = str(target.money_reward)
		
	if target.unit_reward:
		unit_reward_sample.load_unit(target.unit_reward);
		unit_reward_sample.show()
	else:
		unit_reward_sample.hide();
	
	claim_button.disabled = not bounty.can_claim();


func _on_unit_sample_pressed() -> void:
	unit_reward_clicked.emit(bounty.unit_reward)


func _on_claim_pressed() -> void:
	claim_pressed.emit(bounty)
