extends Node2D


func set_spell(spell) -> void:
	
	var string : String
	if spell is SpellResource:
		match spell.spell_type:
			SpellResource.SPELL_TYPE.PHYSIC:
				string = "PHYSIC"
			SpellResource.SPELL_TYPE.MAGIC:
				string = "MAGIC"
	elif spell is Spell:
		string = spell.spell_type
	$TileMap6/TileMap8/Type/Label.text = str(string)
	$TileMap6/TileMap8/Type/Label/Shadow.text = $TileMap6/TileMap8/Type/Label.text
	
	$TileMap6/TileMap8/Energy/Label.text = str(spell.energy_cost)
	$TileMap6/TileMap8/Energy/Label/Shadow.text = $TileMap6/TileMap8/Energy/Label.text
	
	$TileMap6/TileMap8/VBoxContainer/Range.text = "range: " + str(spell.min_range) + "-" + str(spell.max_range)
	$TileMap6/TileMap8/VBoxContainer/Range/Shadow.text = $TileMap6/TileMap8/VBoxContainer/Range.text
	
	$TileMap6/TileMap8/VBoxContainer/Damage.text = "damage: " + str(spell.min_power) + "-" + str(spell.max_power)
	$TileMap6/TileMap8/VBoxContainer/Damage/Shadow.text = $TileMap6/TileMap8/VBoxContainer/Damage.text
