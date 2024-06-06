extends Item

export var initiative : int = 2


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.initiative += initiative
	
