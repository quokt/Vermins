extends Item

export var bonus_health : int = 5


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_health_points += bonus_health
	
