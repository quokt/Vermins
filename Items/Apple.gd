extends Item

export var damage_reduction_flat : int = -1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_input_flat_modif += 1
	
