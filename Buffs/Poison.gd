extends Buff


#TODO : find which spell uses that buff
export (int) var base_damage = 4
var damage = base_damage

export var base_effect : int = 2
export var crit_effect : int = 4

var poison_modif_flat = base_effect if not critical else crit_effect

export (String) var damage_type = "Physic"

var lethality := true


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	#if not singleplayer:
		#actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	#else:
	actor.take_damage([damage, damage_type], caster.get_path(), lethality)
	damage += poison_modif_flat
	description = "At the start of your turn, take *%s* damage"%damage
	#actor.take_damage([damage, damage_type], lethality)

remotesync func _remove_buff(actor = target ) -> void:
	pass
