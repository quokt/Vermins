extends Buff

export var base_effect : float = 0.20
export var crit_effect : float = 0.30

var damage_reduction_coef = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_input_coef_modif *= 1-damage_reduction_coef


remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_input_coef_modif /= 1-damage_reduction_coef
