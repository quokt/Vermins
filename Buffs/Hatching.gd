extends Buff

#TODO : change this buff and spell

const TAWNY_SPIDER_SCENE = preload("res://Puppets/TawnySpider/TawnySpider.tscn")


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	var pos := actor.position
	
	if not singleplayer:
		actor.die()
		#rpc("_summon", pos)
		_summon(pos)
	else:
		actor.die()
		_summon(pos)
	


remotesync func _summon(pos : Vector2):
	var new_puppet = TAWNY_SPIDER_SCENE.instance()
	
	level.summon(pos, new_puppet, caster)
	
	
	if caster.puppets.has("tawny_spider"):
		caster.puppets["tawny_spider"].append(new_puppet)
	else:
		caster.puppets["tawny_spider"] = [new_puppet]
