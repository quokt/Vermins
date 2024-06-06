extends Buff

#TODO : fix this spell

export var base_effect := -2
export var crit_effect := -3

var range_points_debuff = base_effect if not critical else crit_effect


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.range_modif += range_points_debuff


remotesync func _remove_buff(actor : Actor) -> void:
	actor.range_modif -= range_points_debuff
