extends Control


func _ready():
	$music.play()
func _on_Restart_pressed():
	get_tree().change_scene("res://src/Main.tscn")
func _on_Button_pressed():
	get_tree().quit()
