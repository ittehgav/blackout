extends GridContainer
class_name MechanicValuesGrid

@export var icon_scene:PackedScene

var covered_mechanics:Array[CombatMechanicIcon.Mechanics];
func setup(unit:FighterUnit)->void:
	for c in get_children():
		c.queue_free()
	var skill:SkillComponent = unit.base.skill;
	if skill.base_cooldown > 0:
		var hbox:HBoxContainer = generate_hbox(CombatMechanicIcon.Mechanics.cooldown, str(snapped(unit.final_skill_cooldown(), .01)));
		add_child(hbox)
	covered_mechanics.clear()
	
	var range_string:String;
	match unit.base.skill_range:
		FighterBase.MELEE_RANGE:
			range_string = "Melee";
		FighterBase.MID_RANGE:
			range_string = "Medium Range"
		FighterBase.LONG_RANGE:
			range_string = "Long Range";
		
	var range_hbox:HBoxContainer = generate_hbox(CombatMechanicIcon.Mechanics.range, range_string)
	add_child(range_hbox)

	for effect:SkillComponent.Effect in skill.effects:
		match effect:
			SkillComponent.Effect.direct_damage,\
			SkillComponent.Effect.aoe_damage:
				## TODO MAKE THIS TAKE DMG MODIFIERS INTO ACCOUNT
				var mechanic:CombatMechanicIcon.Mechanics = CombatMechanicIcon.Mechanics.damage
				if not mechanic in covered_mechanics:
					covered_mechanics.append(mechanic)
					var hbox:HBoxContainer = generate_hbox(mechanic, str(unit.final_stat("attack")));
					add_child(hbox)
			SkillComponent.Effect.direct_status,\
			SkillComponent.Effect.aoe_status:
				assert(skill.status)
				if skill.status.type != "special":
					var hbox:HBoxContainer = generate_status_hbox(skill.status, unit)
					add_child(hbox)
			SkillComponent.Effect.knockback,\
			SkillComponent.Effect.aoe_knockback,\
			SkillComponent.Effect.radial_knockback:
				var mechanic:CombatMechanicIcon.Mechanics = CombatMechanicIcon.Mechanics.knockback
				if not mechanic in covered_mechanics:
					var hbox:HBoxContainer = generate_hbox(mechanic, skill.knockback_strength_string())
					add_child(hbox)
			
func generate_status_hbox(status:Status, unit:FighterUnit)->HBoxContainer:
	match status.type:
		'stun':
			var mechanic:CombatMechanicIcon.Mechanics = CombatMechanicIcon.Mechanics.stun;
			if mechanic in covered_mechanics:
				return
			covered_mechanics.append(mechanic)

			var stun_duration:float = status.duration;
			var scaled:float = CombatStats.technique_scaled_value(stun_duration, unit.final_stat("technique"), "stun")
			var duration_str:String = str(snapped(scaled, .01))+"s"
			return generate_hbox(mechanic, duration_str);
		'stat_change':
			if status.value < 0:
				var mechanic:CombatMechanicIcon.Mechanics = CombatMechanicIcon.Mechanics.stat_down;
				if mechanic in covered_mechanics:
					return
				covered_mechanics.append(mechanic)

				return generate_hbox(mechanic, str(status.value * -1), status.stat);
			else:
				var mechanic:CombatMechanicIcon.Mechanics = CombatMechanicIcon.Mechanics.stun;
				if mechanic in covered_mechanics:
					return
				covered_mechanics.append(mechanic)

				return generate_hbox(CombatMechanicIcon.Mechanics.stat_up, str(status.value), status.stat);
		_:
			assert(false)
			return generate_hbox(CombatMechanicIcon.Mechanics.stat_up, status.stat);
	
func generate_hbox(mechanic:CombatMechanicIcon.Mechanics, text:String, stat:String = "")->HBoxContainer:
		var hbox:HBoxContainer = HBoxContainer.new()

		var icon:CombatMechanicIcon = icon_scene.instantiate();
		icon.mechanic = mechanic;
		if stat:
			icon.stat = stat

		var label:Label = Label.new();
		icon.label = label;
		label.text = text
		hbox.add_child(icon);
		hbox.add_child(label)
		return hbox
