extends Buff

export var base_range_debuff : int = -2
export var crit_range_debuff : int = -3

var range_debuff = base_range_debuff if not critical else crit_range_debuff


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.range_modif += range_debuff


remotesync func _remove_buff(actor ) -> void:
	actor.range_modif -= range_debuff
