extends Item

export var range_bonus : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.range_modif += 1
	
