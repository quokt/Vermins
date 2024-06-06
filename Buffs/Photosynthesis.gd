extends Buff


var stamina_buff = 2

#export var base_description : String
#export var crit_description : String

#func _ready() -> void:
#	description = base_description if not critical else crit_description


func _apply_buff(actor : Actor, opt_array : Array = []) -> void:
	actor.add_stamina(stamina_buff)


remotesync func _remove_buff(actor ) -> void:
	actor.add_stamina(-stamina_buff)
	pass
