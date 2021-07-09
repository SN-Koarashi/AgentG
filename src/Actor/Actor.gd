extends KinematicBody2D
class_name Actor
# Main entity variable
export var speed: = Vector2(300.0,750.0)
export var gra: = 1500.0


# Main velocity
var vel: = Vector2.ZERO

onready var StompSound: = get_node("/root/LevelTemplete/Stomp")
onready var HitBossSound: = get_node("/root/LevelTemplete/HitBoss")

onready var NTime: = get_node("/root/LevelTemplete/Player/VBoxContainer2/NTime")
onready var NSc: = get_node("/root/LevelTemplete/Player/VBoxContainer2/NSc")
onready var NTot: = get_node("/root/LevelTemplete/Player/VBoxContainer2/NTot")

onready var Globals = get_node("/root/Globals")
