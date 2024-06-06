extends Buff

export var base_effect : int = 20
export var crit_effect : int = 30

var healing = base_effect if not critical else crit_effect

export (float) var damage_input_coef = 0.5



func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.damage_input_coef_modif *= damage_input_coef


remotesync func _remove_buff(actor : Actor) -> void:
	actor.damage_input_coef_modif /= damage_input_coef
	actor.heal([healing, "Magic"])

