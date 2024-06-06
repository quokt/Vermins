extends Buff

export var base_effect : int = 4
export var crit_effect : int = 5


var healing_bonus = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	caster.healing_output_flat_modif += healing_bonus

remotesync func _remove_buff(actor ) -> void:
	caster.healing_output_flat_modif -= healing_bonus
