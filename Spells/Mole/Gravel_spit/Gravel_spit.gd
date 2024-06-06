extends Spell

#var aoe_modif : int


#func _process(_delta):
#	if aoe_modif < caster.range_modif:
#		aoe_modif = caster.range_modif
#		self.aoe += aoe_modif
#	elif aoe_modif > caster.range_modif:
#		self.aoe -= aoe_modif - caster.range_modif
#		aoe_modif = caster.range_modif
#
#func _cast_spell(target_dict):
#	for target in target_dict.values():
#		if target is Actor and is_instance_valid(target):
#			_deal_damage(target)
