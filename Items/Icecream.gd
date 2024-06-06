extends Item

export var damage_debuff : int = 1
export var damage_reduction : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_output_flat_modif -= damage_debuff
	actor.damage_input_flat_modif -= damage_reduction
	
