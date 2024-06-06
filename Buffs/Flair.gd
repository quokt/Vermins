extends Buff

export var damage_output_coef : float = 1.05

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_output_coef_modif *= damage_output_coef

remotesync func _remove_buff(actor ) -> void:
	actor.damage_output_coef_modif /= damage_output_coef
