extends Buff

export var damage_output_flat = 4

export var base_effect : int = 2
export var crit_effect : int = 3

var range_bonus = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.range_modif += range_bonus
	actor.damage_type_modif["Magic"]["Flat"] += damage_output_flat
	#actor.damage_type_modif["Psychic"]["Flat"] += damage_output_flat

remotesync func _remove_buff(actor : Actor) -> void:
	actor.range_modif -= range_bonus
	actor.damage_type_modif["Magic"]["Flat"] -= damage_output_flat
	#actor.damage_type_modif["Psychic"]["Flat"] -= damage_output_flat
