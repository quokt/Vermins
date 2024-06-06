extends Control

const RECORDS_PATH = "user://records.tres"
var SAVE_PATH = "user://game_data.tres"


func _ready():
	compute_stats()


func compute_stats() -> void:
	var records = load(RECORDS_PATH)
	var game_data = load(SAVE_PATH)
	
	if not records or not game_data:
		return
	if records.game_records.empty():
		return
	#TODO : this function
	
	var levels_played : int = 0
	var victories : int = 0
	var regions_count : Dictionary = {
		"fields": 0,
		"desert": 0,
		"caves": 0,
		"city": 0
	}
	for game in records.game_records:
		levels_played += game["level_count"]
		if game["victory"]:
			victories += 1
		regions_count[game["region"]] += 1
	
	var games_played : int = records.game_records.size()
	
	$VBoxContainer/Levels.text = "Levels played : %s" %[levels_played]
	$VBoxContainer/Games.text = "games played : %s" %[games_played]
	$VBoxContainer/Victories.text = 'Victories : %s' %[victories]
	$VBoxContainer/Fields.text = "    Fields : %s" %[regions_count["fields"]]
	$VBoxContainer/Desert.text = "    Desert : %s" %[regions_count["desert"]] if game_data.regions_unlock["desert"] else ""
	$VBoxContainer/Caves.text = "    Caves : %s" %[regions_count["caves"]] if game_data.regions_unlock["caves"] else ""
	$VBoxContainer/City.text = "    City : %s" %[regions_count["city"]] if game_data.regions_unlock["city"] else ""
	
	
