extends Item

export (int) var damage_reduction_flat = 2



func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_input_flat_modif -= damage_reduction_flat
