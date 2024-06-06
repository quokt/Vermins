extends SpellFX

var colors := {
	"" : Color.white,
	"Magic" : Color.purple,
	"Physic" : Color.orangered
}

func _start_animation(type : String):
	$AnimatedSprite.process_material.color = colors[type]
