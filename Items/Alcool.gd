extends Item

export var damage_reduction : int = 2
export var bonus_damage_output_flat : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_input_flat_modif -= damage_reduction
	actor.damage_output_flat_modif += bonus_damage_output_flat
	
