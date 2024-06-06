extends Spell

#onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]

export var push_strength = 2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:

	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.position == target_dict["origin"]:
				continue
			if crit:
				_deal_damage(target, crit_min_power, crit_max_power)
			else:
				_deal_damage(target)
			request_push(caster.position, target, push_strength)
