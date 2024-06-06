extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			for buff in get_tree().get_nodes_in_group("buffs"):
				if buff.target == target:
					if not singleplayer:
						buff.rpc("pass_turn")
					else:
						buff.pass_turn()
