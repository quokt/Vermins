extends Spell

export var base_amount : int = 3
export var crit_amount : int = 4
export var delay = 0.5

var amount : int = base_amount

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	amount = base_amount if not crit else crit_amount
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			for i in amount:
				_deal_damage(target)
				yield(get_tree().create_timer(delay), "timeout")
