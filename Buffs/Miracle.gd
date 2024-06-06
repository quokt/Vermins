extends Buff

#TODO : test this buff


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.invulnerable = true

remotesync func _remove_buff(actor : Actor) -> void:
	actor.invulnerable = false
