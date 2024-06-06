extends Item

export (int) var bonus_range = 2


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.range_modif += bonus_range
