extends CanvasLayer


func _ready():
	$UnlockPopup.show_on_top = true


func set_actor(_name : String) -> void:
	if not _name:
		return
	
	$UnlockPopup/TextureRect/ActorIcon.set_character([_name, 0])
	$UnlockPopup/TextureRect/Label2.text = _name

func _on_Button3D_pressed():
	queue_free()
