extends Buff

#TODO : delete this

#export var base_effect : int = 4
#export var crit_effect : int = 6
#
#var damage_input_flat = base_effect if not critical else crit_effect
#
#
#
#func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
#	actor.resistances["Magic"]["Flat"] -= damage_input_flat
#	#actor.resistances["Psychic"]["Flat"] -= damage_input_flat
#
#remotesync func _remove_buff(actor ) -> void:
#	actor.resistances["Magic"]["Flat"] += damage_input_flat
#	#actor.resistances["Psychic"]["Flat"] += damage_input_flat
