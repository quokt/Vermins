extends Player

enum MODE {FAMISHED, ENGORGED}
var current_mode = MODE.FAMISHED setget set_current_mode

func _init():
	string_class = CLASS


remotesync func set_current_mode(value) -> void:
	current_mode = value
	match current_mode:
		MODE.FAMISHED:
			sprite.animation = "Default"
		MODE.ENGORGED:
			sprite.animation = "Engorged"
