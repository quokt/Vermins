extends Buff
#TODO : test if the buff is correctly removed after preventing damage
#		and test if critical works

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.avoid_next_damage += 1
	if critical:
		actor.avoid_next_damage += 1
	
	
remotesync func _remove_buff(actor : Actor) -> void:
	pass
	
	
func _get_custom_remove() -> String:
	return "damage_prevented"

