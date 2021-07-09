extends RigidBody2D

func _ready():
	get_node("Timer").start(2)

func _on_Timer_timeout():
	queue_free()
