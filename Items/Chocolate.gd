extends Item

export var damage_reduction_debuff : int = 1
export var bonus_stamina : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_input_flat_modif += damage_reduction_debuff
	actor.bonus_stamina += bonus_stamina
	
