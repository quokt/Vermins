extends Item

export var initiative_debuff : int = 6
export var damage_reduction : int = 2


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.initiative -= initiative_debuff
	actor.damage_input_flat_modif -= damage_reduction
	
