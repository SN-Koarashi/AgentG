extends Actor
onready var tween = get_node("Tween")
onready var tween_kb = get_node("Tween")
onready var EvArea = get_node("/root/LevelTemplete/Area2D")
onready var BossArea = get_node("/root/LevelTemplete/Boss/Area2D")
onready var Music: = get_node("/root/LevelTemplete/Music")
onready var MusicBoss: = get_node("/root/LevelTemplete/MusicBoss")
onready var BULLET = preload("Bullet.tscn")

onready var _animated_sprite = $Player
onready var _fire_light = $Light2D


# hit from left
var left_hit = false
# hit from right
var right_hit = false
var knockback_hit_started = false
# player health
var health = 3
var time = 0
# resting time (count per 1/60 seconds, maybe? that mean FPS but my screen is too suck)
var AFK_counter = 0
var onWallHIt = "none"
var fire_dir_left = true
var fire_cooldown = 0
var fire_cooldown_started = false

func _ready():
	Globals.eScore = 0
	Globals.score = 0
	Globals.time_bonus = 0
	get_node("Timer").start(1)

func _physics_process(delta: float) -> void:
	var dir: = get_dir()
	vel = calcu_move_vel(vel,dir,speed)
	vel = move_and_slide(vel, Vector2.UP)

func _process(delta):
	if fire_cooldown_started:
		fire_cooldown += 1
	
	if Input.is_action_pressed("move_right"):
		_animated_sprite.play()
		_animated_sprite.set_flip_h(false)
		_animated_sprite.set_offset(Vector2(0,0))
		_fire_light.offset.x = 0
		fire_dir_left = true
	elif Input.is_action_pressed("move_left"):
		_animated_sprite.play()
		_animated_sprite.set_flip_h(true)
		_animated_sprite.set_offset(Vector2(-550,0))
		_fire_light.offset.x = -6100
		fire_dir_left = false
	else:
		_animated_sprite.stop()
		_animated_sprite.set_frame(0)
		
	if Input.is_action_pressed("on_fire"):
		if !fire_cooldown_started:
			fire_cooldown_started = true
			_fire_light.enabled = true
			$onFire.play()
			
			var bullet =  BULLET.instance()
			get_node("/root/LevelTemplete").add_child(bullet)
			bullet.global_position.y = $Player.global_position.y-20
			if fire_dir_left:
				bullet.global_position.x = $Player.global_position.x+65
				bullet.apply_impulse(Vector2(),Vector2(1025,0.0015))
			else:
				bullet.global_position.x = $Player.global_position.x-155
				bullet.apply_impulse(Vector2(),Vector2(-1025,0.0015))
	
	if fire_cooldown >= 20:
		fire_cooldown_started = false
		fire_cooldown = 0
	
	if fire_cooldown >=3:
		_fire_light.enabled = false
	
	# when player resting
	if vel == Vector2.ZERO:
		AFK_counter += 1
	else:
		AFK_counter = 0
	# Unstock, Restart game
	if Input.get_action_strength("Reflash") and AFK_counter > 30:
		AFK_counter = 0
		get_node("CollisionShape2D").disabled = true
		queue_free()
		get_tree().reload_current_scene()
	

	# Player Knockback by Enemy
	if knockback_hit_started:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider is TileMap:
				if collision.normal.x > 0 and collision.normal.y == 0:
					onWallHIt = "left"
				elif collision.normal.x < 0 and collision.normal.y == 0:
					onWallHIt = "right"
				else:
					onWallHIt = "none"
		if(left_hit):
			tween.interpolate_property(self, "position",
					position, Vector2(position.x+150 ,position.y-25), 0.25,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
			get_node("Knockback").play()
			left_hit = false
		if(right_hit):
			tween.interpolate_property(self, "position",
					position, Vector2(position.x-150 ,position.y-25), 0.25,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
			get_node("Knockback").play()
			right_hit = false
			
		if onWallHIt != "none":
			tween.stop(self)
		if not tween.is_active():
			knockback_hit_started = false
	
	# when counter more than 600, it need to reset to 0 because ...?
	if(AFK_counter > 600):
		AFK_counter = 0
func _on_Area2D_body_entered(body: PhysicsBody2D):
	# HITBOX, my love!
	if body.name == "Boss":
		minusHP(body.global_position.x, get_node("Area2D"), "Boss")
	else:
		minusHP(body.global_position.x, get_node("Area2D"), "Enemy")

func _on_TrapArea_body_entered(body: PhysicsBody2D):
	vel = calcu_stomp_vel(vel,500.0)
	get_node("StompTrap").play()
	minusHP(body.global_position.x, get_node("Area2D"), "Trap")

func _on_BossArea_body_entered(body: PhysicsBody2D):
	Music.stop()
	MusicBoss.play()
	speed = Vector2(375.0,1050.0)

# idk
func minusHP(entity_x: float, PArea2D: Node2D, DamagedFrom: String) -> void:
	# oh sad, the health minus one
	
	if DamagedFrom == "Boss":
		health -= 3
	else:
		health -= 1
	
	if DamagedFrom != "Trap":
		# Call player knockback func
		if(entity_x < PArea2D.global_position.x):
			left_hit = true
			knockback_hit_started = true
		else:
			right_hit = true
			knockback_hit_started = true
	
	# when health less than 0, restarting game
	# hide health images?
	if(health <= 0):
		get_node("Camera2D/VBoxContainer/hp1").hide()
		get_node("Knockback").play()
		get_node("CollisionShape2D").disabled = true
		queue_free()
		get_tree().change_scene("res://src/GameOver.tscn")
	elif health == 2:
		get_node("Camera2D/VBoxContainer/hp3").hide()
	elif health == 1:
		get_node("Camera2D/VBoxContainer/hp2").hide()
				
func get_dir() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.get_action_strength("move_top") and is_on_floor() else 1.0
	)
func calcu_move_vel(liner_vel: Vector2,dir: Vector2,speed: Vector2) -> Vector2:
	var new_vel: = liner_vel
	new_vel.x = speed.x * dir.x
	new_vel.y += gra * get_physics_process_delta_time()
	if dir.y == -1.0:
		new_vel.y = speed.y * dir.y
	return new_vel

func calcu_stomp_vel(liner_vel: Vector2, imm: float) -> Vector2:
	var out: = liner_vel
	out.y = -imm
	return out

func calcu_throw_vel(liner_vel: Vector2, imm: float) -> Vector2:
	var out: = liner_vel
	out.y = -imm
	out.angle_to(liner_vel)
	return out
func get_which_wall_collided():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return "left"
		elif collision.normal.x < 0:
			return "right"
	return "none"

func _on_Timer_timeout():
	time += 1
	var time_min = floor(time/60)
	var time_min_format = "0" + str(time_min) if time_min < 10 else str(time_min)
	
	var time_sec = time - floor(time/60)*60
	var time_sec_format = "0" + str(time_sec) if time_sec < 10 else str(time_sec)
	

	$Camera2D/Label2.text = time_min_format + ":" + time_sec_format
	$Camera2D/Label4.text = str(Globals.eScore)
	
	if get_node("/root/LevelTemplete/Boss") == null:
		get_node("Timer").stop()
		var time_bonus = Globals.base_score - time
		var score = Globals.eScore + time_bonus

		Globals.score = score
		Globals.time_format = $Camera2D/Label2.text
		Globals.time_bonus = time_bonus
		
		get_tree().change_scene("res://src/GameWin.tscn")
		


func _on_PortalA_body_entered(body):
	self.global_position.x = 6124
	self.global_position.y = 3431
