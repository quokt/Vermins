extends Buff

 #TODO : test this buff


var amount = 4

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.spine += amount

remotesync func _remove_buff(actor ) -> void:
	actor.spine -= amount

