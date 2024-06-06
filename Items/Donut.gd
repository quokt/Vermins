extends Item

export var bonus_range : int = 2
export var stamina_debuff : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.range_modif += bonus_range
	actor.bonus_stamina -= stamina_debuff
	
