extends Player
class_name Puppet

export (bool) var is_controlable = false

export var ai_controled : bool = false

var _master = null


func _ready():
	controlable = is_controlable
	is_puppet = true
