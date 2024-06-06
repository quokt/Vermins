extends Item

export var crit_chance_debuff : float = 0.04
export var bonus_energy : int = 1


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_energy += bonus_energy
	actor.crit_chance_bonus -= crit_chance_debuff
	
