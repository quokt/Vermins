extends Node2D

signal title_screen_pressed()

export(String, MULTILINE) var victory_bb_text = "[rainbow freq=0.5 sat=1 val=1][center][wave amp=40 freq=3]Victory"
export(String, MULTILINE) var defeat_bb_text = "[center][tornado radius=4 freq=2]DEFEAT"

onready var victory_label := $Sprite/VictoryLabel
onready var defeat_label := $Sprite/DefeatLabel
onready var winner_team_preview := $HBoxContainer/TeamPreview
onready var looser_team_preview := $HBoxContainer/TeamPreview2

onready var title_screen_button := $TitleScreenButton
onready var title_screen_button_label := $TitleScreenButton/Label

var victory : bool = true


func set_winner_team(team : Dictionary) -> void:
	winner_team_preview.set_team(team)
	
	
func set_looser_team(team : Dictionary) -> void:
	looser_team_preview.set_team(team)


func set_status(level_count : int, _victory : bool = true) -> void:
	if level_count == 1 or level_count == 2:
		title_screen_button_label.text = "continue"
	else:
		title_screen_button_label.text = "title screen"
		
	victory = _victory
	victory_label.visible = _victory
	defeat_label.visible = not _victory
	


func _on_TitleScreenButton_pressed():
	emit_signal("title_screen_pressed", victory)
	self.visible = false
