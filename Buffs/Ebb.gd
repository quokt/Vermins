extends Buff

export var damage_output_coef = 0.75


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
	actor.damage_type_modif["Magic"]["Coef"] *= damage_output_coef
	actor.damage_type_modif["Physic"]["Coef"] *= damage_output_coef

remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_type_modif["Magic"]["Coef"] /= damage_output_coef
	actor.damage_type_modif["Physic"]["Coef"] /= damage_output_coef
