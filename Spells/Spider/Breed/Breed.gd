extends Spell

const SPIDER_EGG_SCENE = preload("res://Puppets/SpiderEgg/SpiderEgg.tscn")

#TODO : this spell should summon an egg and give it the "hatching" status


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	if not singleplayer:
		rpc("_summon", target_dict["origin"])
	else:
		_summon(target_dict["origin"])


remotesync func _summon(pos : Vector2, crit : bool = false):
	var new_puppet = SPIDER_EGG_SCENE.instance()
	summon(pos, new_puppet, caster)
	
	
	if singleplayer or is_network_master():
		_add_buff(new_puppet, buff_name)
	
	if caster.puppets.has("spider_egg"):
		caster.puppets["spider_egg"].append(new_puppet)
	else:
		caster.puppets["spider_egg"] = [new_puppet]
