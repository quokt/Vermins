extends Item

export (int) var damage_reduction_flat = 3


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.resistances["Physic"]["Flat"] += damage_reduction_flat
