extends Buff

export var base_damage : int = 5
export var crit_damage : int = 8

var damage : int


func _get_custom_remove() -> String:
	return "damage_taken"


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	damage = base_damage if not critical else crit_damage
	actor.damage_output_flat_modif += damage


remotesync func _remove_buff(actor ) -> void:
	actor.damage_output_flat_modif -= damage


#
#func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
#	if critical:
#		turns += 1
#	if not singleplayer:
#		actor.rpc("make_visible", false)
#	else:
#		actor.make_visible(false)
#
#
#remotesync func _remove_buff(actor ) -> void:
#	if not singleplayer:
#		actor.rpc("make_visible", true)
#	else:
#		actor.make_visible(true)
