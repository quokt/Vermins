extends Item

export var damage_coef : float = 1.02
var count : float = 0.00

var game_description : String

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_output_coef_modif *= damage_coef
	count += damage_coef
	description = "+" + str(count*100) + "% damage"
		
	

func _get_custom_apply() -> String:
	return "turn_passed"
