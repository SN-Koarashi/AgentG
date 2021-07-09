extends Control


func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	get_node("music").play()

func _on_Start_pressed():
	get_tree().change_scene("res://src/Levels.tscn")
