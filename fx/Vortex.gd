extends Node2D

var spell_duration : float = 2.0

onready var main_player : AnimationPlayer = $AnimationPlayer
onready var second_player : AnimationPlayer = $AnimationPlayer2

signal animation_ended

func start_animation():
	
	second_player.play("Grow")
	
	main_player.play("Spell")
	
	yield(get_tree().create_timer(spell_duration),"timeout")
	
	second_player.play_backwards("Grow")
	
	yield(second_player,"animation_finished")
	
	emit_signal("animation_ended")

#func _on_AnimationPlayer_animation_finished(anim_name):
	#emit_signal("animation_ended")
