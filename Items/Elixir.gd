extends Item

export var bonus_initiative : int = 4
export var bonus_damage : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.initiative += bonus_initiative
	actor.damage_output_flat_modif += bonus_damage
	
