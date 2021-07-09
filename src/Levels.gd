extends Node2D

onready var ENslime = preload("Actor/enemy.tscn")
onready var ENzombie = preload("Actor/SZombie.tscn")
var slime = 1
var zombie = 1

func _ready():
	while(slime < 24):
		slime += 1
		var enemySl =  ENslime.instance()
		get_node("/root/LevelTemplete").add_child(enemySl)
		enemySl.global_position.y = $Enemy.global_position.y
		enemySl.global_position.x = $Enemy.global_position.x + (slime * 100)
	while(zombie < 36):
		zombie += 1
		var enemyZo =  ENzombie.instance()
		get_node("/root/LevelTemplete").add_child(enemyZo)
		enemyZo.global_position.y = $SZombie.global_position.y
		enemyZo.global_position.x = $SZombie.global_position.x + (zombie * 100)
