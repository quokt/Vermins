extends Buff


export var base_effect : int = -2
export var crit_effect : int = -3


var stamina_debuff = base_effect if not critical else crit_effect

#export var base_description : String
#export var crit_description : String
#
#
#func _ready():
#	description = base_description if not critical else crit_description


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.add_stamina(stamina_debuff)


remotesync func _remove_buff(actor ) -> void:
	actor.add_stamina(-stamina_debuff)
	pass
