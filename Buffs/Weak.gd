extends Buff

export var damage_input_coef : float = 1.25

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_input_coef_modif *= damage_input_coef
	if critical:
		turns += 1

remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_input_coef_modif /= damage_input_coef
