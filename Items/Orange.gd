extends Item

export var damage_output_flat : int = 1
export var damage_type : String

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_type_modif[damage_type]["Flat"] += damage_output_flat
	
