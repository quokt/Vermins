extends Buff


export var crit_bonus : float = 0.25



func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.third_eye = true
	actor.crit_chance_bonus += crit_bonus

remotesync func _remove_buff(actor ) -> void:
	actor.third_eye = false
	actor.crit_chance_bonus -= crit_bonus
