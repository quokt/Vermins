extends Spell

#enum MODE {SUMMON, ACTIVATE}
#var current_mode = MODE.SUMMON
#
#const DIRT_PILE_SCENE = preload("res://Puppets/DirtPile/DirtPile.tscn")
#
#var dirt_pile = null
#
#onready var base_max_range = self.max_range
#onready var base_min_range = self.min_range
#
#
#
#func _process(_delta):
#	if caster == null or not is_instance_valid(caster):
#		return
#
#	if caster.puppets.has("dirt_pile"):
#		dirt_pile = caster.puppets["dirt_pile"][0]
#		current_mode = MODE.ACTIVATE
#	else:
#		dirt_pile = null
#		current_mode = MODE.SUMMON
#
#	match current_mode:
#		MODE.SUMMON:
#			self.cast_mode = CAST_MODE.ORIGIN
#			self.cell_mode = CELL_MODE.EMPTY
#			self.min_range = base_min_range
#			self.max_range = base_max_range
#			self.range_modif = true
#		MODE.ACTIVATE:
#			self.cast_mode = CAST_MODE.CUSTOM
#			self.cell_mode = CELL_MODE.BOTH
#			self.min_range = 0
#			self.max_range = 0
#			self.range_modif = false
#
#
#func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
#	if crit:
#		set_cooldown(cooldown-1)
#
#	match current_mode:
#		MODE.SUMMON:
#			if not singleplayer:
#				rpc("_summon", target_dict["origin"])
#			else:
#				_summon(target_dict["origin"])
#
#		MODE.ACTIVATE:
#			if dirt_pile == null or not is_instance_valid(dirt_pile):
#				dirt_pile = caster.puppets["dirt_pile"][0]
#
#			request_jump(dirt_pile.position)
#			#dirt_pile.queue_free()
#			caster.puppets.erase("dirt_pile")
#			for target in target_dict.values():
#				if target is Actor and is_instance_valid(target) and not target == caster and not target == dirt_pile:
#					_deal_damage(target)
#
#			dirt_pile.die()
#			dirt_pile = null
#
#func get_custom_origin() -> Vector2:
#	return dirt_pile.position
#
#
#remotesync func _summon(pos : Vector2, crit : bool = false):
#	var new_puppet = DIRT_PILE_SCENE.instance()
#	summon(pos, new_puppet, caster)
#
#	caster.puppets["dirt_pile"] = [new_puppet]
#	dirt_pile = new_puppet
#
