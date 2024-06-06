extends Buff

export var base_effect : float = 0.75
export var crit_effect : float = 0.60

var damage_output_coef_modif = base_effect if not critical else crit_effect

export (int) var stamina_debuff = -1


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_output_coef_modif *= damage_output_coef_modif
	actor.add_energy(stamina_debuff)


remotesync func _remove_buff(actor ) -> void:
	actor.damage_output_coef_modif /= damage_output_coef_modif
	actor.add_energy(-stamina_debuff)
