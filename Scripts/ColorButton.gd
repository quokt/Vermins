extends OptionButton

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


var index : int = 0

func _ready():
	set_colors()


func set_colors():
	var i : int = 0
	for color in COLORS:
		var color_name : String = COLORS_NAMES[i].get_slice(".", 1)
		add_item(color_name)
		i += 1
