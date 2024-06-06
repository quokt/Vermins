extends Buff

var crit_bonus

export var critical_crit_bonus : float = 0.08

export var base_crit_bonus : float = 0.05


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	crit_bonus = base_crit_bonus if not critical else critical_crit_bonus
	actor.crit_chance_bonus += crit_bonus


remotesync func _remove_buff(actor ) -> void:
	actor.crit_chance_bonus -= crit_bonus
	pass
