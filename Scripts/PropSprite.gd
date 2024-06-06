extends Node2D
class_name PropSprite

const TEXTURES_REGIONS : Dictionary = {
	Rect2(3,0,59,96) : "pine",
	Rect2(64,0,62,96) : "tree",
	Rect2(128,97,32,29) : "plant",
	Rect2(64,96,32,30) : "plant",
	Rect2(96,96,32,31) : "plant",
	Rect2(32,96,32,34) : "plant",
	Rect2(1,96,31,30) : "plant",
	Rect2(159, 65, 30,29): "rock",
	Rect2(127,65,32,28): "rock",
	Rect2(128,36,32,25): "rock"
}

signal area_entered()
signal area_exited()

const positions = {
	"tree" : Vector2(0, -30),
	"pine" : Vector2(0, -30),
	"plant": Vector2(0,0),
	"rock": Vector2(0,4)
}

onready var sprite = $PropSprite
onready var tween = $Tween


func make_transparent(value : bool = true) -> void:
	
	if not tween.is_inside_tree():
		return
	
	var color = Color(1,1,1,0.3) if value else Color(1,1,1,1)

	
	tween.interpolate_property(sprite, "modulate", 
	null, color, 
	0.2,
	Tween.TRANS_LINEAR,
	Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_completed")



func set_texture(_texture : AtlasTexture) -> void:
	var _name : String = ""
	sprite.texture = _texture
	if _texture.region in TEXTURES_REGIONS.keys():
		_name = TEXTURES_REGIONS[_texture.region]
	
	for shape in $HideArea.get_children():
		shape.set_deferred("disabled", true)
		
	match _name:
		"tree": 
			$HideArea/TreeShape.set_deferred("disabled", false)
			$HideArea/TreeShape2.set_deferred("disabled", false)
		"pine":
			$HideArea/PineShape.set_deferred("disabled", false)
		"plant":
			$HideArea/PlantShape.set_deferred("disabled", false)
		"rock":
			$HideArea/RockShape.set_deferred("disabled", false)
	
	if _name:
		sprite.position = positions[_name]
		sprite.material.set_shader_param("offset", randi()%16)
	
	yield(get_tree().create_timer(1.0),"timeout")
	
	for shape in $HideArea.get_children():
		if shape.disabled:
#			if shape == $Area2D/PineShape:
#				pass
			shape.call_deferred("queue_free")
	


func _on_Area2D_area_entered(area):
	emit_signal("area_entered", self, $HideArea, area)


func _on_Area2D_area_exited(area):
	emit_signal("area_exited", self, $HideArea, area)
