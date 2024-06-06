extends Player

var current_summon : String

func _init():
	string_class = CLASS
	#ai_type = AI_TYPES.MELEE
	

func _take_damage(_base_damage : Array) -> Array:
	var base_damage := []
	
	if not puppets.has("tawny_spider"):
		return _base_damage
	
	var damage = int( round( _base_damage[0]/ (puppets["tawny_spider"].size() + 1) ) )
	
	for _puppet in puppets["tawny_spider"]:
		if _puppet != null and is_instance_valid(_puppet):
			_puppet.take_damage([damage, _base_damage[1]], self.get_path())
	
	base_damage = [damage, _base_damage[1]]
	
	return base_damage
