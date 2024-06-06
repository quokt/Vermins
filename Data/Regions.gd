extends Resource

#TODO : add list off possible maps for every singleplayer region
export var regions_maps : Dictionary = {
	"fields" : ["forest", "funtain", "field", "meadow"],
	"desert" : ["desert", "volcano", "temple", "island"],
	"caves" : ["lava", "icebridge", "crystals", "end"],
	"city" : ["crossroad", "platform", "building", "bazaar"]
}

export var regions_enemies : Dictionary = {
	"fields" : ["Widow", "Cockroach", "Slug", "Tick", "Wasp", "Spider"],
	"desert" : ["Mole", "Cobra", "Worm", "Fly", "Ants", "Earthworm"],
	"caves" : ["Snail", "Bats", "Beetle", "Dragonfly", "Viper", "Mantis"],
	"city" : ["Scorpion", "Moskito", "Bedbug", "Ladybug", "Bumblebee", "Rat"]
}


#export var enemies_spells : Dictionary = {
#	"Slug": [],
#	"Beetle": [],
#	"Snail": [],
#	"Mole": [],
#	"Cockroach": [],
#	"Moskito": [],
#	"Bumblebee": [],
#	"Dragonfly": [],
#	"Fly": [],
#	"Wasp": [],
#	"Scorpion": [],
#	"Widow": [],
#	"Ladybug": [],
#	"Viper": [],
#	"Bats": [],
#	"Tick": [],
#	"Cobra": [],
#	"Worm": [],
#	"Ants": [],
#	"Bedbug": []
#}
