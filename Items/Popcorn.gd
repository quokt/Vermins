extends Item

export var bonus_damage : int = 3
export var energy_debuff : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_output_flat_modif += bonus_damage
	actor.bonus_energy -= energy_debuff
	
