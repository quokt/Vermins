extends Buff

export var damage_coef : float = 2.0
#export var crit_effect : float = 3.0
#
#var damage_coef = base_effect if not critical else crit_effect


#func _pass_turn() -> void:
#	#TODO : not working : damage output isnt removed
#	if turns == 1:
#		target.damage_output_coef_modif /= damage_coef
#		if critical:
#			pass_turn()


##prevents turns from being added to this buff
#remotesync func add_turn(_amount : int) -> void:
#	return


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if not critical:
		actor.damage_input_coef_modif *= damage_coef
	actor.damage_output_coef_modif *= damage_coef
	

remotesync func _remove_buff(actor ) -> void:
	if not critical:
		actor.damage_input_coef_modif /= damage_coef
	actor.damage_output_coef_modif /= damage_coef
