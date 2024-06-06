extends Buff


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
	actor.rooted = true


remotesync func _remove_buff(actor ) -> void:
	actor.rooted = false
	pass
