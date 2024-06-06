extends Item

export var bonus_energy : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_energy += bonus_energy
	
