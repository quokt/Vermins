extends Buff

export var damage_output_flat = 4


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
#	actor.damage_type_modif["Magic"]["Flat"] -= damage_output_flat
	actor.damage_type_modif["Physic"]["Flat"] -= damage_output_flat
	if critical:
		turns += 1

remotesync func _remove_buff(actor : Actor) -> void:
#	actor.damage_type_modif["Magic"]["Flat"] += damage_output_flat
	actor.damage_type_modif["Physic"]["Flat"] += damage_output_flat
