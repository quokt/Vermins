extends Spell

const WORKER_ANT_SCENE = preload("res://Puppets/WorkerAnt/WorkerAnt.tscn")


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
	if not singleplayer:
		rpc("_summon", target_dict["origin"], crit)
	else:
		_summon(target_dict["origin"], crit)



remotesync func _summon(pos : Vector2, crit : bool = false):
	var new_puppet = WORKER_ANT_SCENE.instance()
	summon(pos, new_puppet, caster)
	
	if caster.puppets.has("worker_ant"):
		caster.puppets["worker_ant"].append(new_puppet)
	else:
		caster.puppets["worker_ant"] = [new_puppet]
