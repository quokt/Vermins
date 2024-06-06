extends Buff

export var base_effect := 1.15
export var crit_effect := 1.2

var healing_input_coef_modif := base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.healing_input_coef_modif *= healing_input_coef_modif


remotesync func _remove_buff(actor ) -> void:
	actor.healing_input_coef_modif /= healing_input_coef_modif
	pass
