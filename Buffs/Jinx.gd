extends Buff

export var crit_debuff : float = 0.10

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
	actor.crit_chance_bonus -= crit_debuff
	actor.jinx = true

remotesync func _remove_buff(actor) -> void:
	actor.jinx = false
	actor.crit_chance_bonus += crit_debuff
