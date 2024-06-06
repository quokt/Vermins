extends Buff


export (int) var base_damage = 3
export (int) var crit_damage = 4

#TODO : test this
var damage = base_damage if not critical else crit_damage

#var base_description = "At the start of your turn, take "

export (int) var poison_modif_flat = 2

export (String) var damage_type = "Physic"

export var lethality := true


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	#if not singleplayer:
		#actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	#else:
	actor.take_damage([damage, damage_type], caster.get_path(), lethality)
	damage += poison_modif_flat
	description = "Take *%s* damage at the start of your turn"%damage
#	description = base_description + str(damage) + " damage"
	#actor.take_damage([damage, damage_type], lethality)

remotesync func _remove_buff(actor = target ) -> void:
	pass
