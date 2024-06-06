extends Buff

export var stamina_buff : int = 2
#export var crit_effect : int = 3


#var stamina_buff = base_effect if not critical else crit_effect

#export var base_description : String
#export var crit_description : String


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
	actor.add_stamina(stamina_buff)


remotesync func _remove_buff(actor ) -> void:
	actor.add_stamina(-stamina_buff)
	pass
