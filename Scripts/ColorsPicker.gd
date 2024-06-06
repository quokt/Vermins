extends OptionButton

const flat_texture_path = "res://Theme/flat_texture.tres"

const COLORS = [
#	Color.whitesmoke,
#	Color.black,
	Color.peachpuff,
	Color.tan,
	Color.gold,
	Color.darkgoldenrod,
#	Color.darkorange,
	Color.coral,
	Color.olivedrab,
	Color.darkolivegreen,
#	Color.greenyellow,
	Color.limegreen,
	Color.mediumseagreen,
#	Color.aquamarine,
	Color.lightseagreen,
	Color.aqua,
#	Color.darkslategray,
#	Color.paleturquoise,
	Color.deepskyblue,
	Color.slategray,
#	Color.midnightblue,
	Color.rebeccapurple,
#	Color.indigo,
	Color.darkviolet,
	Color.fuchsia,
#	Color.plum,
	Color.orchid,
	Color.deeppink,
	Color.maroon,
	Color.crimson,
	Color.pink
]

const COLORS_NAMES = [
#	"Color.whitesmoke",
#	"Color.black",
	"Color.peachpuff",
	"Color.tan",
	"Color.gold",
	"Color.darkgoldenrod",
#	"Color.darkorange",
	"Color.coral",
	"Color.olivedrab",
	"Color.darkolivegreen",
#	"Color.greenyellow",
	"Color.limegreen",
	"Color.mediumseagreen",
#	"Color.aquamarine",
	"Color.lightseagreen",
	"Color.aqua",
#	"Color.darkslategray",
#	"Color.paleturquoise",
	"Color.deepskyblue",
	"Color.slategray",
#	"Color.midnightblue",
	"Color.rebeccapurple",
#	"Color.indigo",
	"Color.darkviolet",
	"Color.fuchsia",
#	"Color.plum",
	"Color.orchid",
	"Color.deeppink",
	"Color.maroon",
	"Color.crimson",
	"Color.pink"
]

var index : int = 0
var test

func _ready():
	self.set_colors()


#void add_icon_item(texture: Texture, label: String, id: int = -1, accel: int = 0)
#
#Adds a new item with text label and icon texture.


func set_colors() -> void:
	var i : int = 0
	for color in COLORS:
		var color_name : String = COLORS_NAMES[i].get_slice(".", 1)
		#add_item(color_name)
		var texture = GradientTexture2D.new()
		var gradient = Gradient.new()
		gradient.colors = PoolColorArray([COLORS[i]])
		texture.gradient = gradient
		texture.width = 12
		texture.height = 12
		add_icon_item(texture, color_name)
		
		
		i += 1
	
	var popup = get_popup()
	
	popup.show_on_top = true
	popup.rect_scale = Vector2(2,2)
	test = popup._is_on_top()
