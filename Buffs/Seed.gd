extends Buff

export var min_damage : int = 4
export var max_damage : int = 6
export var lifesteal_amount : float = 1.0 

export var damage_type : String = "Physic"

export var lethality : bool = true

var damage = Vector2(min_damage, max_damage)

func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	if critical:
		turns += 1
		
	var _damage = int(min_damage + randi()% int((max_damage-min_damage) + 1))
		
	#if not singleplayer:
		#actor.rpc("take_damage" , [_damage, damage_type], caster.get_path(), lethality)
		#caster.rpc("heal", [_damage*lifesteal_amount, damage_type])
	#else:
	actor.take_damage([_damage, damage_type], caster.get_path(), lethality)
	caster.heal([_damage*lifesteal_amount, damage_type])

remotesync func _remove_buff(actor ) -> void:
	pass
