extends Buff

export var base_effect : int = -2
export var crit_effect : int = -4

var damage_output_flat : int = base_effect if not critical else crit_effect

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_output_flat_modif += damage_output_flat

remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_output_flat_modif -= damage_output_flat
