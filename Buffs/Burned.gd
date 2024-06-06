extends Buff

export var base_effect : int = 3
export var crit_effect : int = 5

var damage = base_effect if not critical else crit_effect


export (String) var damage_type

var lethality := true


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if not singleplayer:
		actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	else:
		actor.take_damage([damage, damage_type], caster.get_path(), lethality)


remotesync func _remove_buff(actor = target ) -> void:
	pass
