extends Buff


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
	level.push_damage *= 2


remotesync func _remove_buff(actor ) -> void:
	level.push_damage /= 2
	pass
