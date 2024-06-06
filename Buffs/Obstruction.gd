extends Buff

export var base_effect : float = 0.5
export var crit_effect : float = 0.75

var damage_coef = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_input_coef_modif *= damage_coef
	actor.damage_output_coef_modif *= damage_coef

remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_input_coef_modif /= damage_coef
	actor.damage_output_coef_modif /= damage_coef
