extends Buff

export var caster_base_effect : float = 0.95
export var caster_crit_effect : float = 0.92

var damage_input_coef = caster_base_effect if not critical else caster_crit_effect

export var target_base_effect : float = 0.85
export var target_crit_effect : float = 0.80

var damage_output_coef = target_base_effect if not critical else target_crit_effect

export (String, MULTILINE) var caster_description
export (String, MULTILINE) var caster_crit_description
export (String, MULTILINE) var target_description
export (String, MULTILINE) var target_crit_description

export (int, 0, 10, 1) var caster_max_stack
export (int, 0, 10, 1) var target_max_stack

func _initialize_buff(_target) -> void:
	if _target.team != caster.team:
		max_stack = target_max_stack
	elif _target == caster:
		max_stack = caster_max_stack


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	
	if actor == caster:
		#max_stack = caster_max_stack
		actor.damage_input_coef_modif *= damage_input_coef
		description = caster_description if not critical else caster_crit_description
		
	elif actor.team != caster.team:
		#max_stack = target_max_stack
		actor.damage_output_coef_modif *= damage_output_coef
		description = target_description if not critical else target_crit_description

remotesync func _remove_buff(actor ) -> void:
	
	if actor == caster:
		actor.damage_input_coef_modif /= damage_input_coef
		
	elif actor.team != caster.team:
		actor.damage_output_coef_modif /= damage_output_coef
