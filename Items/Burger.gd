extends Item

export var damage_debuff : int = 1
export var bonus_energy : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_output_flat_modif -= damage_debuff
	actor.bonus_energy += bonus_energy
	
