extends Panel

signal team_pressed

var SAVE_PATH = "user://game_data.tres"
var game_data_script = "res://Data/game_data.gd"

var actor_icon = preload("res://Scenes/ActorIcon.tscn")
var actor_icon_scale = Vector2(1.4, 1.4)


onready var outline = $Outline
onready var actors_preview = $ActorsPreview
onready var label = $TeamName
export var team_index : int
var teams_list
var team
var team_name : String
var team_save_name : String = "team" + str(team_index)




func update_team_list():
	
	team_save_name = "team" + team_index as String
	teams_list = ResourceLoader.load(SAVE_PATH)
	if teams_list == null:
		print("Data file is missing or corrupted : building new save_file...")
		var game_data = Resource.new()
		game_data.set_script(load(game_data_script))
		var result = ResourceSaver.save(SAVE_PATH, game_data)
		print(result)
		teams_list = ResourceLoader.load(SAVE_PATH)
	team = teams_list.get(team_save_name)
	team_name = teams_list.get(str(team_save_name + "_name"))
	set_team(team)


func _ready():
	actors_preview.rect_size = self.rect_size
	update_team_list()
#	print(str(team))


func set_team(new_team : Dictionary):
	
	for child in actors_preview.get_node("YSort").get_children():
		child.free()
	
	for actor in new_team:
		var flip_h = randi()%2 == 0
		var new_actor_icon = actor_icon.instance()
		new_actor_icon.set_character(new_team[actor]["class"], flip_h)
		if new_team[actor]["class"][0] in new_actor_icon.giants:
			new_actor_icon.get_node("AnimatedSprite").scale = Vector2(2,2)
		actors_preview.get_node("YSort").add_child(new_actor_icon)
		actors_preview.place_characters()
		new_actor_icon.rect_scale = actor_icon_scale
		
	label.text = team_name
		
	team = new_team.duplicate(true)


func _on_Button_pressed():
	emit_signal("team_pressed", self)
	print("sent signal")
