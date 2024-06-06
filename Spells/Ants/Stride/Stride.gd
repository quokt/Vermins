extends Spell

#onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]

export var slide_strength = 2
export var crit_slide_strength = 3

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:

	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target)
			if crit:
				request_slide(target.position, caster, crit_slide_strength)
			else:
				request_slide(target.position, caster, slide_strength)
