extends "res://src/Actor/Actor.gd"
# Oh , this is a boss code
onready var Player = get_node("/root/LevelTemplete/Player")
# boss was hit times
var hit_counter = 0
var test: = 0
var light_counter = 0
var light = false
var position_counter = 0
var last_position = 0

func _ready() -> void:
	# Starting move when game ready
	vel.x = -speed.x
	$boss2.play()

func _on_Area2D_body_entered(body: PhysicsBody2D):
	# Hitbox
	if body.name != "Player":
		hit_counter += 1
		HitBossSound.play()
		
		get_node("Light2D").energy = 1.25
		light = true
		# hit from top
		
		if abs(vel.x) < 900:
			vel.x = -speed.x * hit_counter * 1.05
		
		body.queue_free()
		if(hit_counter > 9):
			Globals.eScore += 350
			get_node("KillSucceed").play()
			get_node("CollisionShape2D").disabled = true
			queue_free()
		
func _process(delta):
	if light:
		light_counter += 1
		if light_counter > 30:
			get_node("Light2D").energy = 1
			light = false
	

func _physics_process(delta: float) -> void:
	position_counter += 1
	if position_counter >= 30:
		last_position = global_position.x
		position_counter = 0
	vel.y += gra * delta
	if is_on_wall():
		vel.x *= -1.0
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if(collision.collider.name == "Player"):
				vel.x *= -1.0
				if Player.vel == Vector2.ZERO and Player.is_on_wall():
					vel.x *= -1.0
	vel.y = move_and_slide(vel, Vector2.UP).y

func onMoveDir(PlayerVX: Vector2, BossVX: Vector2) -> bool:
	if PlayerVX.x > 0 and BossVX.x > 0:
		return true
	if PlayerVX.x < 0 and BossVX.x < 0:
		return true
	return false
