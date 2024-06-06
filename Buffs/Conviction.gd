extends Buff

#export var base_description : String
#export var crit_description : String

export var base_damage : int = 2
export var crit_damage : int = 3

export var damage_type : String = "Magic"

export var lethality : bool = true

var damage = base_damage if not critical else crit_damage

func _get_custom_apply() -> String:
	return "stamina_spent"


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	var energy_spent = opt_array[0]
	if not singleplayer:
		actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	else:
		actor.take_damage([damage, damage_type], caster.get_path(), lethality)
