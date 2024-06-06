extends Item

export var bonus_stamina : int = 1
export var damage_reduction_debuff : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_stamina += bonus_stamina
	actor.damage_input_flat_modif += damage_reduction_debuff
	
