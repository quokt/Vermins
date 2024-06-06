extends Buff

export var base_effect : int = 6
export var crit_effect : int = 8

var damage = base_effect if not critical else crit_effect

#var base_description = "At the end of your turn, take %s damage"

export (float) var poison_modif_coef = 2.0

export (String) var damage_type = "Physic"

export var lethality := true


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	#if not singleplayer:
		#actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	#else:
	actor.take_damage([damage, damage_type], caster.get_path(), lethality)
	damage *= poison_modif_coef
	
	#TODO : test this description model and apply to other spells
	description = "At the end of your turn, take *%s* damage"%damage
	#description = base_description + str(damage) + " damage"
	#actor.take_damage([damage, damage_type], lethality)

remotesync func _remove_buff(actor = target ) -> void:
	pass
