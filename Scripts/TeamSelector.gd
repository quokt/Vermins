extends HBoxContainer

var selected_team_node : Node
var selected_team = null
var selected_team_index : int
var highlight

var disabled : bool = false

var rect_color := Color.royalblue
var rect_width : float = 10.0

func _ready():
	for child in get_children():
		child.connect("team_pressed", self, "on_team_pressed")
		
		
		
func on_team_pressed(team_node):
	if disabled : return
	
	selected_team_node = team_node
	selected_team = team_node.team
	selected_team_index = team_node.team_index
#	update()
	for child in get_children():
		child.outline.visible = false

	team_node.outline.visible = true
	
	print(team_node.name, " pressed")


func on_team_changed():
	for child in get_children():
		child.update_team_list()
	selected_team = selected_team_node.team


#func _draw():
#	if not selected_team_node:
#		return
#
#	var rect = Rect2(selected_team_node.rect_position, selected_team_node.rect_size)
#
#	draw_rect(rect, rect_color, false, rect_width)
