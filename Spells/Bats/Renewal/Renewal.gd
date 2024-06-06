extends Spell


const PUPPET_BAT_SCENE = preload("res://Puppets/TerrorBat/TerrorBat.tscn")


#TODO : add crit effect


func _cast_spell(target_dict : Dictionary, crit : bool = false):
	if crit:
		set_cooldown(cooldown-1)
		
	if not singleplayer:
		rpc("_summon", target_dict["origin"])
	else:
		_summon(target_dict["origin"])



remotesync func _summon(pos : Vector2, crit : bool = false):
	var new_puppet = PUPPET_BAT_SCENE.instance()
	summon(pos, new_puppet, caster)

	
#	var actors_list = get_tree().get_nodes_in_group("actors_list")[0]
#	actors_list.add_child(new_puppet)
#	new_puppet.initialize_actor()
#
#	new_puppet.position = pos
#	new_puppet.set_outline_color(caster.outline_color)
#	new_puppet.team = caster.team
#	new_puppet.controlable = new_puppet.is_controlable
#	new_puppet._master = caster
#	new_puppet.set_network_master(caster.get_network_master())
#	new_puppet.is_multiplayer = true
#
#	new_puppet.connect("died", level, "on_actor_died")
#	new_puppet.connect("actor_pressed", level, "on_actor_pressed")
	
#	if caster.puppets.has("worker_ant"):
#		caster.puppets["worker_ant"].append(new_puppet)
#	else:
#		caster.puppets["worker_ant"] = [new_puppet]
