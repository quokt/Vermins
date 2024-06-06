extends Buff


export (int) var stamina_debuff = -3


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.add_stamina(stamina_debuff)


remotesync func _remove_buff(actor ) -> void:
	actor.add_stamina(-stamina_debuff)
