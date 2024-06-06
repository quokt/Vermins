extends Node

var array : Array = range(9)

onready var starting_stream := $AudioStreamPlayer11
onready var ending_stream := $AudioStreamPlayer10


#func _ready() -> void:
#	array.shuffle()
#
#	for child in get_children():
#		if child == ending_stream:
#			continue
#		child.connect("finished", self, "on_audio_stream_player_finished")
		

func mute(value : bool = true) -> void:
	var bus_index = AudioServer.get_bus_index("Percussions")
	var volume_db = 0.0 if not value else -60.0
	AudioServer.set_bus_volume_db(0, volume_db)


func on_audio_stream_player_finished() -> void:
	#code to play music bits randomly
	if randi()%2 == 0:
		yield(get_tree().create_timer(randf()+randi()%3),"timeout")
	
	get_child(array.pop_back()).playing = true
	
	if array.empty():
		array = range(9)
		array.shuffle()


func play_random() -> void:
	array = range(9)
	array.shuffle()
	get_child(array.pop_back()).playing = true


func start() -> void:
	starting_stream.playing = true


func end() -> void:
	for child in get_children():
		child.playing = false
		
	ending_stream.playing = true
	
