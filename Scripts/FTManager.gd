extends Node2D

const FLOAT_TEXT_SCENE = preload("res://Scenes/FloatingText.tscn")


export var direction = Vector2(0, -28)
export var duration = 1.2
export var spread = 0.0

export var delay = 0.4

var queue : Array = []

var displaying : bool = false





func show_value(value, damage_type : String = "", type : String = ""):#type can be "damage", "healing", "crit" or "energy"
	
	if str(value) == "!" or (not displaying and queue.empty()):
		displaying = true
		var floating_text = FLOAT_TEXT_SCENE.instance()
		floating_text.value = value 
		floating_text.damage_type = damage_type
		floating_text.type = type
		self.add_child(floating_text)
		display(floating_text)
	else:
		add_to_queue(value, damage_type, type)
#	if get_child_count() == 1:
#		display(floating_text)
#	elif get_child_count() > 1:
#		return


func display(scene) -> void:
#	displaying = true
	scene.show_value(direction, duration, spread)
	yield(scene, "display_ended")
	
	displaying = false
	
	on_display_ended(scene)
	

func add_to_queue(value, damage_type, type) ->void:
	queue.append([value, damage_type, type])
	

func on_display_ended(scene) -> void:
#	scene.disconnect("display_ended", self ,"on_display_ended")
	scene.queue_free()
	
	yield(get_tree().create_timer(delay),"timeout")
	
	if not queue.empty():
		var next = queue.pop_front()
		show_value(next[0], next[1], next[2])
#	if get_child_count() != 0:
#		display(get_child(0))
#	else:
#		pass





