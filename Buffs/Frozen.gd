extends Buff


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.frozen = true


remotesync func _remove_buff(actor ) -> void:
	actor.frozen = false
