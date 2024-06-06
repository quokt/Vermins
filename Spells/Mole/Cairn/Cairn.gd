extends Spell

const DIRT_PILE_SCENE = preload("res://Puppets/DirtPile/DirtPile.tscn")


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
	if not singleplayer:
		rpc("_summon", target_dict["origin"], crit)
	else:
		_summon(target_dict["origin"], crit)



remotesync func _summon(pos : Vector2, crit : bool = false):
	var new_puppet = DIRT_PILE_SCENE.instance()
	summon(pos, new_puppet, caster)
	
	if caster.puppets.has("dirt_pile"):
		caster.puppets["dirt_pile"].append(new_puppet)
	else:
		caster.puppets["dirt_pile"] = [new_puppet]

