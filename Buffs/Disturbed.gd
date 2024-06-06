extends Buff

export var base_effect : int = -2
export var crit_effect : int = -3

var energy_debuff = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.add_energy(energy_debuff)


remotesync func _remove_buff(actor ) -> void:
	actor.add_energy(-energy_debuff)
	pass
