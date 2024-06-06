extends Control

const SAVE_PATH = "user://game_data.tres"


func _ready():
	lock_regions()


func lock_regions() -> void:
	$GridContainer/VBoxContainer2/TextureRect.modulate = Color.white
	$GridContainer/VBoxContainer2/Desert.modulate = Color.white
	$GridContainer/VBoxContainer2/Desert.disabled = false
	
	$GridContainer/VBoxContainer3/TextureRect.modulate = Color.white
	$GridContainer/VBoxContainer3/Caves.modulate = Color.white
	$GridContainer/VBoxContainer3/Caves.disabled = false
	
	$GridContainer/VBoxContainer4/TextureRect.modulate = Color.white
	$GridContainer/VBoxContainer4/City.modulate = Color.white
	$GridContainer/VBoxContainer4/City.disabled = false
	
	var game_data = load(SAVE_PATH)
	for region in game_data.regions_unlock:
		if game_data.regions_unlock[region] == false:
			lock(region)
			

func lock(region : String):
	match region:
		"desert":
			$GridContainer/VBoxContainer2/TextureRect.modulate = Color.black
			$GridContainer/VBoxContainer2/Desert.modulate = Color.black
			$GridContainer/VBoxContainer2/Desert.disabled = true
		"caves":
			$GridContainer/VBoxContainer3/TextureRect.modulate = Color.black
			$GridContainer/VBoxContainer3/Caves.modulate = Color.black
			$GridContainer/VBoxContainer3/Caves.disabled = true
		"city":
			$GridContainer/VBoxContainer4/TextureRect.modulate = Color.black
			$GridContainer/VBoxContainer4/City.modulate = Color.black
			$GridContainer/VBoxContainer4/City.disabled = true
