extends Spell

const LEECH_SCENE = preload("res://Puppets/Leech/Leech.tscn")


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
	if not singleplayer:
		rpc("_summon", target_dict["origin"], crit)
	else:
		_summon(target_dict["origin"], crit)



remotesync func _summon(pos : Vector2, crit : bool = false):
	var new_puppet = LEECH_SCENE.instance()
	summon(pos, new_puppet, caster)
	
	if caster.puppets.has("leech"):
		caster.puppets["leech"].append(new_puppet)
	else:
		caster.puppets["leech"] = [new_puppet]
