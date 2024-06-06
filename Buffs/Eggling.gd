extends Buff

const MAGGOT_SCENE = preload("res://Puppets/Maggot/Maggot.tscn")

onready var tilemap = get_tree().get_nodes_in_group("nav")[0]

var cell_size = Vector2(32, 16)

export var base_effect : int = 5
export var crit_effect : int = 8

var damage = base_effect if not critical else crit_effect


export (String) var damage_type = "Magic"

var lethality := true


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	
	#if not singleplayer:
		#actor.rpc("take_damage" , [damage, damage_type], caster.get_path(), lethality)
	#else:
	actor.take_damage([damage, damage_type], caster.get_path(), lethality)
	
	var next
	var pos
	for x in [0, 1]:
		for y in [0, 1]:
			next = tilemap.world_to_map(actor.position) + Vector2(x, y)
			if tilemap.get_occupied_cells().has(next):
				continue
			else:
				if not singleplayer:
					_summon(tilemap.map_to_world(next))
				else:
					_summon(tilemap.map_to_world(next))
				return
			

remotesync func _remove_buff(actor = target ) -> void:
	pass


remotesync func _summon(pos : Vector2):
	var new_puppet = MAGGOT_SCENE.instance()
	summon(pos, new_puppet, caster)
#	var new_puppet = MAGGOT_SCENE.instance()
#
#	var actors_list : Node2D = get_tree().get_nodes_in_group("actors_list")[0]
#	actors_list.add_child(new_puppet)
#
#	while actors_list.get_child(new_puppet.get_index() -1) != caster:
#		if actors_list.get_child(new_puppet.get_index() -1) is Puppet:
#			if actors_list.get_child(new_puppet.get_index() -1)._master == caster:
#				break
#		new_puppet.raise()
#
#	new_puppet.initialize_actor()
#
#	new_puppet.position = pos
#	new_puppet.set_outline_color(caster.outline_color)
#	new_puppet.team = caster.team
#	new_puppet.controlable = new_puppet.is_controlable
#	new_puppet.is_multiplayer = true
#	new_puppet._master = caster
#	new_puppet.set_network_master(caster.network_ID)
#
#	new_puppet.connect("died", level, "on_actor_died")
#	new_puppet.connect("actor_pressed", level, "on_actor_pressed")
#
	if caster.puppets.has("maggot"):
		caster.puppets["maggot"].append(new_puppet)
	else:
		caster.puppets["maggot"] = [new_puppet]
