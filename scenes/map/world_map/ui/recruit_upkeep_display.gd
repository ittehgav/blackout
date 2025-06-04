extends Control

signal payment_avoided;
signal payment_commited

@export var exp_bar:ExperienceBar;

@export var sample:SpriteSample;

@export var costs_container:GridContainer;
@export var name_label:Label;

@export var food_hbox:HBoxContainer;
@export var food_label:Label;

@export var fuel_hbox:HBoxContainer;
@export var fuel_label:Label;

@export var money_hbox:HBoxContainer;
@export var money_label:Label;

@export var juice_hbox:HBoxContainer;
@export var juice_label:Label;

@export var scrap_hbox:HBoxContainer;
@export var scrap_label:Label;

@export var skip_payment_btn:Button
var paying:bool=true;
var costs:Dictionary;


func setup(unit:FighterUnit)->void:
	exp_bar.build_from_unit(unit);
	sample.set_sample(unit.base);
	sample.target_base.scale = Vector2.ONE
	for r:String in Index.all_resources:
		costs[r] = 0;
	name_label.text = "Lvl. " + str(unit.level) + " " + unit.base.name;
	for tag:String in unit.base.tags:
		var tag_costs:Dictionary = Scaling.tag_upkeep_costs(tag)
		for key:String in tag_costs.keys():
			costs[key] += tag_costs[key]
			
	costs["money"] = Scaling.unit_upkeep_money_cost(unit.level);
	
	for r:String in Index.all_resources:
		if costs[r]:
			self[r+"_hbox"].show();
			self[r+"_label"].text = str(costs[r]);



func toggle_payment(target:bool=not paying, from_all:bool=false) -> void:
	if target == not paying:
		paying = target
		if not paying:
			self_modulate.a = .1
			sample.modulate.a = .1
			costs_container.modulate.a = .1
			skip_payment_btn.text = "Make Payment"
			payment_avoided.emit(costs, not from_all)
		else:
			modulate.a = 1;
			sample.modulate.a = 1;
			costs_container.modulate.a = 1;
			skip_payment_btn.text = "Cancel Payment";
			payment_commited.emit(costs, not from_all)

func commit_payment(exp_gain:int)->void:
	exp_bar.gain_exp(exp_gain);
