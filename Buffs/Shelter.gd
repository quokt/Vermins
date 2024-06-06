extends Buff

 #TODO : test this buff
export (float) var coef = 0.2

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.reflection_coef += coef

remotesync func _remove_buff(actor ) -> void:
	actor.reflection_coef -= coef

