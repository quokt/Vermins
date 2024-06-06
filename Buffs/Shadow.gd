extends Buff
#TODO : re-test this buff

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if actor == caster:
		return
	if critical:
		turns += 1
		
	actor.shadow_actor = caster

remotesync func _remove_buff(actor : Actor) -> void:
	actor.shadow_actor = null

