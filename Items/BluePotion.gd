extends Item

export var bonus_energy : int = 1
export var damage_reduction : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_energy += bonus_energy
	actor.damage_input_flat_modif -= damage_reduction
	
