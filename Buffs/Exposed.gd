extends Buff

export var damage_input_flat = 5

export var size_coef = 2.0

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_input_flat_modif += damage_input_flat
	actor.sprite.scale *= size_coef


remotesync func _remove_buff(actor ) -> void:
	actor.damage_input_coef_modif -= damage_input_flat
	actor.sprite.scale /= size_coef
	pass
