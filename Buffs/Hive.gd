extends Buff

export var damage_output_flat = 5



func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
	actor.damage_output_flat_modif += damage_output_flat


remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_output_flat_modif -= damage_output_flat

