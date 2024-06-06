extends Node2D

const SAVE_PATH = "user://game_data.tres"
const RECORDS_PATH = "user://records.tres"

enum SUB {BASE, PLAY, STATS, TEAMEDIT, GAMEMODE, MULTI, SINGLE, MAP_SELECTOR, SETTINGS, CREDITS, QUIT}
var current = SUB.BASE

onready var camera := $Camera2D
onready var tween := $Camera2D/Tween
onready var buttons_list := $Layer1/ButtonsList
#onready var teams_list = $Layer1/Play/TeamsList
onready var light := $Camera2D/Layer2/Light2D
onready var edit_button := $Layer1/Play/EditTeam
onready var play_button := $Layer1/Play/Play
onready var team_selector := $Layer1/Play/TeamSelector
onready var team_builder := $Layer1/TeamBuilder
onready var lobby := $Layer1/Multiplayer/Lobby
onready var settings := $Layer1/Settings
onready var map_selector := $Layer1/MapSelector
onready var stats := $Layer1/Stats/Control

var default_light_scale := Vector2(0.616, 0.975)
var team_edit_light_scale := Vector2(1.5, 0.75)
var gamemode_light_scale := Vector2(0.6, 0.9)

var selected_team = null

var camera_positions := {
	"base" : Vector2(259, 151) ,
	"play" : Vector2(576, 49) ,
	"stats" : Vector2(-66, 261) ,
	"teambuilder" : Vector2(656, -220) ,
	"gamemode" : Vector2(946, 56) ,
	"multi" : Vector2(894, 336) ,
	"single" : Vector2(1230, 32) ,
	"map_selector" : Vector2(1192, 340) ,
	"settings" : Vector2(-63, 14) ,
	"credits" : Vector2(575, 306) ,
	"quit" : Vector2(255, 346)
}
var camera_speed = 0.4


func _process(_delta):
	if current == SUB.PLAY:
		selected_team = team_selector.selected_team
	make_active(current)
	edit_button.disabled = selected_team == null
	if selected_team is Dictionary:
		edit_button.get_node("Label").text = "new" if selected_team.empty() else "EDIT"
	play_button.disabled = selected_team == null or selected_team.empty()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("escape"):
			match current:
				SUB.TEAMEDIT:
					move_camera(camera_positions["play"])
					current = SUB.PLAY
				SUB.BASE:
					move_camera(camera_positions["quit"])
					current = SUB.QUIT
				SUB.QUIT:
					_on_YesQuit_pressed()
				_:
					move_camera(camera_positions["base"])
					current = SUB.BASE


func make_active(current_ = current):
	team_builder.team_preview_bg.light_mask = 1
	team_selector.disabled = true
	map_selector.disabled = true
	light.scale = default_light_scale
	var current_name
	match current_:
		SUB.BASE: current_name = "ButtonsList"
		SUB.QUIT: current_name = "QuitConfirm"
		SUB.CREDITS : current_name = "Credits"
		SUB.STATS : current_name = "Stats"
		SUB.SETTINGS : current_name = "Settings"
		SUB.PLAY : current_name = "Play"
		SUB.TEAMEDIT : current_name = "TeamBuilder"
		SUB.GAMEMODE : current_name = "Gamemode"
		SUB.MULTI : current_name = "Multiplayer"
		SUB.SINGLE : current_name = "Singleplayer"
		SUB.MAP_SELECTOR : current_name = "MapSelector"
	
	if current_ == SUB.TEAMEDIT:
		light.scale = team_edit_light_scale
		team_builder.disable_confirm_button = false
		team_builder.team_preview_bg.light_mask = 0
		#camera.zoom = Vector2(1.3, 1.3)
		team_builder.confirm_button.disabled = false
	else:
		team_builder.confirm_button.disabled = true
		
	if current_ == SUB.GAMEMODE or current_ == SUB.SINGLE:
		light.scale = gamemode_light_scale
	if current_ == SUB.PLAY:
		team_selector.disabled = false
	if current_ == SUB.MAP_SELECTOR:
		map_selector.disabled = false
#	else:
#		light.scale = default_light_scale
	
	for menu in get_tree().get_nodes_in_group("menus"):

		for child in menu.get_children():
			if child is Button:
				child.disabled = not child.get_parent().name == current_name
			else:
				for sub_child in child.get_children():
					if sub_child is Button and not sub_child is CheckBox:
						if sub_child.name == "Stats" or sub_child.name == "Credits":
							sub_child.disabled = not child.get_parent().name == current_name
						else:
							var test = child.get_parent().name == current_name
							sub_child.visible = test

			if child.is_in_group("back"):
				child.visible = child.get_parent().name == current_name or child.get_parent().name == "Play"


func _ready():
	$TileMap.visible = false
	$Layer1.visible = false
	
	var image = load("res://Assets/UI/Complete_GUI_Essential_Pack_v2.1/Cursors/Sprites/Custom_Cursor.png")
	Input.set_custom_mouse_cursor(image, 0, Vector2(6,6))
	camera.position = camera_positions["base"]
	light.visible = true
	
	for button in get_tree().get_nodes_in_group("back"):
		button.connect("pressed", self, "on_back_pressed", [button])
		
	team_builder.connect("team_changed", team_selector, "on_team_changed")
	team_builder.connect("confirm_pressed", self,"on_confirm_pressed")
	
	lobby.connect("host_connection_found", self, "_on_host_connection_found")
	
	yield(get_tree().create_timer(0.1),"timeout")
	
	$AnimationPlayer.play("FadeIn")


func _on_Play_pressed():
	match current:
		SUB.BASE:
			move_camera(camera_positions["play"])
			current = SUB.PLAY
		SUB.PLAY:
			move_camera(camera_positions["gamemode"])
			current = SUB.GAMEMODE
			selected_team = team_selector.selected_team


func _on_Settings_pressed():
	settings.update_settings()
	move_camera(camera_positions["settings"])
	current = SUB.SETTINGS


func _on_Quit_pressed():
	move_camera(camera_positions["quit"])
	current = SUB.QUIT


func on_back_pressed(_button):
	if current == SUB.TEAMEDIT or current == SUB.GAMEMODE:
		if current == SUB.TEAMEDIT:
			team_builder.disable_confirm_button = true
		move_camera(camera_positions["play"])
		current = SUB.PLAY
		
	elif current == SUB.MULTI or current == SUB.SINGLE:
		move_camera(camera_positions["gamemode"])
		current = SUB.GAMEMODE
	else:
		move_camera(camera_positions["base"])
		current = SUB.BASE


func _on_NoQuit_pressed():
	move_camera(camera_positions["base"])
	current = SUB.BASE


func _on_YesQuit_pressed():
	get_tree().quit()


func move_camera(new_position : Vector2):
	#var crt_effect = get_tree().get_nodes_in_group("crt_effect")[0]
	tween.interpolate_property(camera, "position", null, new_position, camera_speed, Tween.TRANS_CIRC, Tween.EASE_OUT )
	#tween.interpolate_property(crt_effect, "position", null, new_position, camera_speed, Tween.TRANS_CIRC,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")


func _on_EditTeam_pressed():
	move_camera(camera_positions["teambuilder"])
	current = SUB.TEAMEDIT
	team_builder.team_save_index = team_selector.selected_team_index
	team_builder.load_team(team_selector.selected_team)


func on_confirm_pressed():
	move_camera(camera_positions["play"])
	current = SUB.PLAY


func _on_Stats_pressed():
	move_camera(camera_positions["stats"])
	current = SUB.STATS


func _on_Credits_pressed():
	
	var game_data_res = ResourceLoader.load(SAVE_PATH)
	
	#TODO : make a singleton for character unlock screen
	
	if game_data_res.characters_unlock["Dragonfly"] == false:
		game_data_res.characters_unlock["Dragonfly"] = true
		ResourceSaver.save(SAVE_PATH, game_data_res)
		team_builder.place_characters()
	
	move_camera(camera_positions["credits"])
	current = SUB.CREDITS


func start_game(region : String) -> void:
	
	CombatPrinter.singleplayer = true
	
	visible = false
	set_process(false)
	get_tree().get_nodes_in_group("spell_info")[0].remove_from_group("spell_info")
	get_tree().get_nodes_in_group("item_info")[0].remove_from_group("item_info")
	
	start_level(0, region)
	#root.call_deferred("queue_free")


func start_level(level_count : int, region : String) -> void:
	randomize()
	var regions_resource = preload("res://Data/Regions.tres")
	var level  = load("res://Scenes/Singleplayer.tscn").instance()
	
	var spell_amount : int = 3  #1, 2, 3
	var enemies_amount : int = 3+level_count
	
	var enemies : Array = []
	var enemies_spells : Array = []
	
	level.region = region
	level.level_count = level_count
	
	for i in range(enemies_amount):
		enemies_spells.append({})
		if level_count == 2 and i == 0:
			enemies.append(regions_resource.regions_enemies[region][regions_resource.regions_enemies[region].size()-1])
		else:
			enemies.append(regions_resource.regions_enemies[region][randi()%(regions_resource.regions_enemies[region].size()-1)])
		var spells_list_resource = preload("res://Spells/SpellsList.tres")
		var spells_list = spells_list_resource.get(enemies[i]).duplicate()#regions_resource.enemies_spells[enemies[i]].duplicate()
		spells_list.shuffle()
		for e in range(spell_amount):
			if spells_list.empty():
				break
			var spell_name = spells_list.pop_back()
			if not spell_name in spells_list_resource.ai_excluded:
				enemies_spells[i][e] = [spell_name]
	
#	level.teams = {
#		"Server" : selected_team,
#		"Client" : {
#			"1" : {
#				"class" : [enemies[0], 12],
#				"color" : [Color.red, "Color.red"],
#				"items" : [],
#				"spells" : enemies_spells[0]
#			} ,
#			"2" : {
#				"class" : [enemies[1], 12],
#				"color" : [Color.red, "Color.red"],
#				"items" : [],
#				"spells" : enemies_spells[1]
#			} ,
#			"3" : {
#				"class" : [enemies[2], 12],
#				"color" : [Color.red, "Color.red"],
#				"items" : [],
#				"spells" : enemies_spells[2]
#			} 
#		}
#	}
	
	level.teams = {
		"Server" : selected_team,
		"Client" : {}
	}
	
	var i : int = 1
	for enemy in enemies:
		level.teams["Client"][str(i)] = {
			"class" : [enemy, 12],
			"color" : [Color.red, "Color.red"],
			"items" : [],
			"spells" : enemies_spells[i-1]
		}
		i += 1
		
	level.selected_map = regions_resource.regions_maps[region][randi()%regions_resource.regions_maps[region].size()]
	
	# Connect deferred so we can safely erase it from the callback.
	level.connect("game_finished", self, "on_continue_pressed", [level])
	
	get_tree().get_root().add_child(level)


func on_continue_pressed(victory : bool, level_ref : Singleplayer) -> void:
	if not victory or level_ref.level_count == 3:
		if victory and level_ref.level_count == 3:
			var game_data = load(SAVE_PATH)
			var region_unlock : String
			var items_unlock : String
			match level_ref.region:
				"fields": 
					region_unlock = "desert"
					items_unlock = "veggies"
				"desert": 
					region_unlock = "caves"
					items_unlock = "drinks"
				"caves" : 
					region_unlock = "city"
					items_unlock = "junk"
				"city" : 
					region_unlock = ""
					items_unlock = "gold"
			if region_unlock != "":
				game_data.regions_unlock[region_unlock] = true
			game_data.items_unlock[items_unlock] = true
			var err = ResourceSaver.save(SAVE_PATH, game_data)
				
		add_game_record(victory, level_ref)
		call_deferred("_end_game")
	elif victory:
		var level_count = level_ref.level_count
		var region = level_ref.region

		level_ref.fade_out()
		yield(get_tree().create_timer(2.2),"timeout")
		level_ref.call_deferred("free")
		yield(get_tree().create_timer(1.0),"timeout")
		start_level(level_count, region)


func _on_Single_pressed():
	move_camera(camera_positions["single"])
	current = SUB.SINGLE
	pass


func _end_game():
	if has_node("/root/Level"):
		# Erase immediately, otherwise network might show
		# errors (this is why we connected deferred above).
		get_node("/root/Level").free()
		var root = self
		root.get_node("Camera2D").make_current()
		var spell_info = $Layer1/TeamBuilder/TeamPreview/SpellInfo
		spell_info.add_to_group("spell_info")
		var item_info = $Layer1/TeamBuilder/TeamPreview/ItemInfo
		item_info.add_to_group("item_info")
		
		root.move_camera(root.camera_positions["base"])
		root.current = root.SUB.BASE
		
		team_builder.place_characters()
		
		stats.compute_stats()
		
		set_process(true)
		
		yield(get_tree().create_timer(0.2),"timeout")
		
		root.show()


func add_game_record(victory : bool, level_ref : Node) -> void:

	var res = ResourceLoader.load(RECORDS_PATH)
	if res == null:
		var records = Resource.new()
		records.set_script(preload("res://Data/records.gd"))
		var result = ResourceSaver.save(RECORDS_PATH, records)
		if result == 0:
			print("Successfully created game record file")
		
		res = ResourceLoader.load(RECORDS_PATH)
		
	var team := []
	if level_ref is Singleplayer:
		for actor_dict in level_ref.teams["Server"].values():
			team.append(actor_dict["class"][0])
#		team = level_ref.teams["Server"]
#	elif level_ref is Multiplayer:
#		team = level_ref.teams
	
	var game_dict : Dictionary = {
		"team" : team,
		"victory" : victory,
		"level_count" : level_ref.level_count,
		"region" : level_ref.region
	}
	
	res.game_records.append(game_dict)
	
	var result = ResourceSaver.save(RECORDS_PATH, res)
	if result ==0:
		print("Saved game successfully")


func _on_Multi_pressed():
	lobby.selected_team = selected_team
	move_camera(camera_positions["multi"])
	current = SUB.MULTI


func _on_host_connection_found():
	move_camera(camera_positions["map_selector"])
	current = SUB.MAP_SELECTOR


func _on_Fields_pressed():
	start_game("fields")


func _on_Desert_pressed():
	start_game("desert")


func _on_Caves_pressed():
	start_game("caves")


func _on_City_pressed():
	start_game("city")


