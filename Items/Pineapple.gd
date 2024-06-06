extends Item

export var damage_input_flat : int = -2
export var damage_type : String

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.resistances[damage_type]["Flat"] += damage_input_flat
	
