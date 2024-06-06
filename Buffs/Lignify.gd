extends Buff


var energy_buff : int = 2
var damage_input_coef : float = 0.8


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_input_coef_modif *= damage_input_coef
	actor.add_energy(energy_buff)


remotesync func _remove_buff(actor ) -> void:
	actor.damage_input_coef_modif /= damage_input_coef
	actor.add_energy(-energy_buff)
