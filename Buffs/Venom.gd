extends Buff

export var base_effect : int = 8
export var crit_effect : int = 10

var damage = base_effect if not critical else crit_effect

export (float) var poison_modif_coef = 1.0

export (String) var damage_type = "Physic"

export var lethality := true


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	#if not singleplayer:
		#actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	#else:
	actor.take_damage([damage, damage_type], caster.get_path(), lethality)
	damage *= poison_modif_coef
	#actor.take_damage([damage, damage_type], lethality)

remotesync func _remove_buff(actor = target ) -> void:
	pass
