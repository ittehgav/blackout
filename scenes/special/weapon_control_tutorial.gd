extends WeaponControl

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("use_weapon") and not equipment.holder.stunned:
		use_weapon_command()
	elif Input.is_action_just_pressed("weapon_alt") and not equipment.holder.stunned:
		use_weapon_command(true);
	elif Input.is_action_just_released("use_weapon") and holding_continuous:
		release_weapon_command()
	
	## weapon switching only at start of tutorail
	
