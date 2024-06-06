extends Label

signal display_ended

var label = self

const colors = {
	"Magic" : Color.purple,
	"Physic" : Color.orangered,
	#"Psychic" : Color.purple ,
	"shield" : Color.lightblue,
	"energy_points" : Color.gold,
	"energy" : Color.orange,
	"crit" : Color.red
}

var value = 0
var damage_type : String = ""
var type : String = ""

func show_value(direction : Vector2 = Vector2.UP, duration : float = 1.8, spread : float = 4.0):
	var prefix := ""
	var suffix := ""
	match type:
		"damage" : prefix = "-"
		"healing" : prefix = "+"
		"shield" : 
			prefix = "["
			suffix = "]"
			modulate = colors["shield"]
		"energy_points":
			modulate = colors["energy_points"]
		"energy":
			modulate = colors["energy"]
		"crit":
			modulate = colors["crit"]
	
	var string = prefix + str(value) + suffix
	text = string as String
	
	var movement = direction.rotated(rand_range(-spread/2, spread/2))
	rect_pivot_offset = rect_size / 2
	
	$Tween.interpolate_property(label, "rect_position", 
	rect_position, rect_position + movement, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(label, "modulate:a",
	1.0, 0.0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	if damage_type != "":
		modulate = colors[damage_type]
	
	if type != "":
		#modulate = Color.red
		$Tween.interpolate_property(label, "rect_scale",
		rect_scale *2, rect_scale, 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
		
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("display_ended", self)
	#queue_free()
