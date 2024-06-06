extends Item

export var bonus_healing : int = 2
export var health_debuff : int = 10

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_health_points -= health_debuff
	actor.healing_output_flat_modif += bonus_healing
	
