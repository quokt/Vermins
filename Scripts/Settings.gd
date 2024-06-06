extends Control

const COLORS = [
	Color.whitesmoke,
	Color.black,
	Color.peachpuff,
	Color.tan,
	Color.gold,
	Color.darkgoldenrod,
	Color.darkorange,
	Color.coral,
	Color.olivedrab,
	Color.darkolivegreen,
	Color.greenyellow,
	Color.limegreen,
	Color.mediumseagreen,
	Color.aquamarine,
	Color.lightseagreen,
	Color.aqua,
	Color.darkslategray,
	Color.paleturquoise,
	Color.deepskyblue,
	Color.slategray,
	Color.midnightblue,
	Color.rebeccapurple,
	Color.indigo,
	Color.darkviolet,
	Color.fuchsia,
	Color.plum,
	Color.orchid,
	Color.deeppink,
	Color.maroon,
	Color.crimson,
	Color.pink
]
const COLORS_NAMES = [
	"Color.whitesmoke",
	"Color.black",
	"Color.peachpuff",
	"Color.tan",
	"Color.gold",
	"Color.darkgoldenrod",
	"Color.darkorange",
	"Color.coral",
	"Color.olivedrab",
	"Color.darkolivegreen",
	"Color.greenyellow",
	"Color.limegreen",
	"Color.mediumseagreen",
	"Color.aquamarine",
	"Color.lightseagreen",
	"Color.aqua",
	"Color.darkslategray",
	"Color.paleturquoise",
	"Color.deepskyblue",
	"Color.slategray",
	"Color.midnightblue",
	"Color.rebeccapurple",
	"Color.indigo",
	"Color.darkviolet",
	"Color.fuchsia",
	"Color.plum",
	"Color.orchid",
	"Color.deeppink",
	"Color.maroon",
	"Color.crimson",
	"Color.pink"
]

const SET_FILE_PATH = "res://Data/Settings.tres"
const SAVE_FILE_PATH = "user://"

onready var light : Light2D = get_tree().get_nodes_in_group("light")[0]
onready var foreground = get_tree().get_nodes_in_group("foreground")[0]
onready var crt_filter = get_tree().get_nodes_in_group("crt_effect")[0]

onready var show_grid_button := $VBoxContainer/ShowGrid
onready var smooth_light_button := $VBoxContainer/SmoothLight
onready var foreground_button := $VBoxContainer/Foreground
onready var crt_filter_button := $VBoxContainer/CrtFilter

onready var color_picker_button : OptionButton = $VBoxContainer/GridColor/ColorsPicker

var color_picker_scale := Vector2(0.2, 0.2)

var smooth_light_energy : float = 0.9
var default_energy : float = 1.0

var grid_color : Color

var settings : Resource

var test

func _ready():
	
	set_colors()
	update_settings()
	apply_settings()
	
	foreground_button.visible = false
	show_grid_button.visible = false


func set_colors():
	var i : int = 0
	for color in COLORS:
		var color_name : String = COLORS_NAMES[i].get_slice(".", 1)
		color_picker_button.add_item(color_name)
		i += 1

	color_picker_button.get_popup().show_on_top = true
	test = color_picker_button.get_popup()._is_on_top()


func on_settings_button_pressed(_button_pressed):
#	update_settings()
	apply_settings()


func load_settings() -> Resource:
	return ResourceLoader.load(SET_FILE_PATH)


func update_settings():
	settings = load_settings()
	show_grid_button.pressed = settings.show_grid
	smooth_light_button.pressed = settings.smooth_light
	foreground_button.pressed = settings.foreground
	crt_filter_button.pressed = settings.crt_filter
	color_picker_button.selected = settings.color_index


func save_settings() :
	settings = load_settings()
	settings.show_grid = show_grid_button.pressed
	settings.smooth_light = smooth_light_button.pressed
	settings.foreground = foreground_button.pressed
	settings.crt_filter = crt_filter_button.pressed
	settings.grid_color = COLORS[color_picker_button.selected]
	settings.color_index = color_picker_button.selected
	return ResourceSaver.save(SET_FILE_PATH, settings)


func apply_settings():
	if settings.smooth_light == true :
		light.energy = smooth_light_energy
	else:
		light.energy = default_energy
		
	foreground.visible = settings.foreground
	crt_filter.visible = settings.crt_filter

func _on_Apply_pressed():
	save_settings()
	apply_settings()


func _on_open_save_file_pressed():
	OS.shell_open(ProjectSettings.globalize_path(SAVE_FILE_PATH))


func _on_Fullscreen_pressed():
	OS.set_window_fullscreen(not OS.is_window_fullscreen())
