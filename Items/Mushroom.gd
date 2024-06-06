extends Item

export (int) var bonus_energy = 2


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_energy += bonus_energy
