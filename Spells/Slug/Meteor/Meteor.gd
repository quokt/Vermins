extends Spell

var aoe_modif : int

var power : Vector2


func _process(_delta):
	if aoe_modif < caster.range_modif:
		aoe_modif = caster.range_modif
		self.aoe += aoe_modif
	elif aoe_modif > caster.range_modif:
		self.aoe -= aoe_modif - caster.range_modif
		aoe_modif = caster.range_modif
		
func _cast_spell(target_dict : Dictionary, crit : bool = false):
	power = Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target, power.x, power.y)
			_add_buff(target, buff_name, crit)
