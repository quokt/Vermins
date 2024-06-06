extends Buff

 #TODO : test this buff
export (float) var coef = 0.5

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1 
	actor.reflection_coef += coef

remotesync func _remove_buff(actor ) -> void:
	actor.reflection_coef -= coef

