extends Buff

 #TODO : test this buff

export var base_effect : int = 3
export var crit_effect : int = 5

var amount = base_effect if not critical else crit_effect

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.spine += amount

remotesync func _remove_buff(actor ) -> void:
	actor.spine -= amount

