extends Button

export var click_y_offset : float = 2.0


func _ready() -> void:
	connect("button_down", self, "on_button_down")
	connect("button_up", self, "on_button_up")


func on_button_down() -> void:
	if has_node("Label"):
		$Label.position.y += click_y_offset
		
		
func on_button_up() -> void:
	if has_node("Label"):
		$Label.position.y -= click_y_offset
