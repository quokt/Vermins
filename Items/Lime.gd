extends Item

export var damage_output_flat : int = 1
#export var damage_type : String

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_output_flat_modif += damage_output_flat
	
