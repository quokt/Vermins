extends TextureRect


onready var label = $MarginContainer/Label

func _ready():
	hide()


func show_label():
	show()
	

func hide_label():
	hide()
	

func set_text(text : String):
	label.text = text
