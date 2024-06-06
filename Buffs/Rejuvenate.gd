extends Buff

export var base_effect : int = 4
export var crit_effect : int = 5

var healing = base_effect if not critical else crit_effect

export (float) var healing_modif_coef = 2.0

export (String) var healing_type = "Physic"



func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	#if not singleplayer:
		#actor.rpc("heal" , [healing, healing_type])
	#else:
	actor.heal([healing, healing_type])
	healing *= healing_modif_coef
	description = "Heal *%s* at the start of your turn (doubled every turn)"%healing

func _remove_buff(actor = target ) -> void:
	pass
