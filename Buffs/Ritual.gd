extends Buff

export var base_effect : int = 4
export var crit_effect : int = 6

export (float) var delay = 0.9

var healing = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	yield(get_tree().create_timer(delay),"timeout")
	actor.heal([healing, "Physic"])


remotesync func _remove_buff(actor ) -> void:
	pass


func _get_custom_apply() -> String:
	return "damage_taken"
