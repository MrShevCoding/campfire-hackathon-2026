extends CharacterBody2D
# 1 MAIN PLAYER SCRIPT, not best to have everything in 1 scipt, but worked for the jam
# Handles movement, health, knockback, power-ups, camera shake,
# and death. God script

# Movement and Health
@export var speed := 240
@export var jump_velocity := -215
@export var gravity := 300

@export var max_hp := 65
var hp := max_hp

var knockback_timer := 0.0
const KNOCKBACK_TIME := 0.2

var damage_cooldown := 0.0
const DAMAGE_COOLDOWN_TIME := 0.6

var kraken_hits := 0
var is_dead := false

@onready var health_label: Label = get_node_or_null("CanvasLayer/HPlabel")
@onready var anim: AnimatedSprite2D = $Player_anim
@onready var camera: Camera2D = $Camera2D
var shake_strength := 0.0
var shake_duration := 0.0
var original_shake_duration := 0.0

# Powerup stats 
var can_double_jump := false
var jump_count := 0

var can_dash := false
var dash_used := false
@export var dash_speed := 800.0
@export var dash_time := 0.2
@export var dash_cooldown := 0.4
@export var double_tap_time := 0.25
var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var last_left_tap := 0.0
var last_right_tap := 0.0

var can_sprint := false
@export var sprint_multiplier := 1.7

var can_ground_slam := false
var is_ground_slamming := false
@export var slam_speed := 1400.0

# _ready() – runs once when the scene loads
func _ready():
	# Load health from GameManager (saves across all levels/scenes)
	hp = GameManager.player_hp
	max_hp = GameManager.player_max_hp
	
	# If this level isn't the tutorial, give a +20 heal (safe room effect)
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path != "res://scenes/tutorial.tscn":
		hp = min(hp + 20, max_hp)
		GameManager.player_hp = hp   # save the healed value
	
	# Check that the health label is there
	if health_label == null:
		push_error("HPLabel NOT FOUND — CHECK NODE PATH")
	else:
		update_health_ui()


# _physics_process(delta) – runs every physics frame (60fps)
# This is where all the action happens for the script.
func _physics_process(delta):
	# Death	
	if is_dead:
		velocity.y += gravity * delta * 2
		move_and_slide()
		if anim.sprite_frames.has_animation("fall"):
			anim.play("fall")
		else:
			anim.stop()
		return
	
	# Dmg cooldwon
	if damage_cooldown > 0.0:
		damage_cooldown -= delta
	
	# Knocback (takes priority)
	if knockback_timer > 0.0:
		knockback_timer -= delta
		move_and_slide()
		if anim.sprite_frames.has_animation("fall"):
			anim.play("fall")
		else:
			anim.stop()
		return
	
	# Dash cooldown
	dash_cooldown_timer -= delta

	# Dash input double arrow key
	if can_dash and not dash_used:
		var current_time = Time.get_ticks_msec() / 1000.0

		if Input.is_action_just_pressed("ui_left"):
			if current_time - last_left_tap <= double_tap_time and dash_cooldown_timer <= 0:
				start_dash(-1)
			last_left_tap = current_time

		if Input.is_action_just_pressed("ui_right"):
			if current_time - last_right_tap <= double_tap_time and dash_cooldown_timer <= 0:
				start_dash(1)
			last_right_tap = current_time

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return

	# Ground slam
	if can_ground_slam and not is_on_floor():
		if Input.is_action_just_pressed("ui_down"):
			is_ground_slamming = true

	if is_ground_slamming:
		velocity.x = 0
		velocity.y = slam_speed
		if is_on_floor():
			is_ground_slamming = false
		move_and_slide()
		return

	# Normal movements, for this jam we did arrow keys but
	# You can easily make it to wasd and others
	var input_dir := 0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1

	var current_speed = speed
	if can_sprint and Input.is_action_pressed("sprint") and input_dir != 0:
		current_speed *= sprint_multiplier

	velocity.x = input_dir * current_speed

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		jump_count = 0
		dash_used = false

	# Jump and Double Jump
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_velocity
			jump_count = 1
		elif can_double_jump and jump_count < 2:
			velocity.y = jump_velocity
			jump_count += 1

	move_and_slide()

	# Update animation based on state
	update_animation()

	# Camera shake effect
	if shake_duration > 0:
		shake_duration -= delta
		var current_strength = shake_strength * (shake_duration / original_shake_duration)
		camera.offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
	else:
		camera.offset = Vector2.ZERO


# Helper: start_dash(direction)
# Called when double‑tap is detected, which helps sets up dash state.

func start_dash(direction: int):
	is_dashing = true
	dash_timer = dash_time
	dash_cooldown_timer = dash_cooldown
	dash_used = true
	velocity.y = 0
	velocity.x = direction * dash_speed


# Damage and Death func

# Called by Kraken's hitbox when it touches us
func take_kraken_hit(dir: Vector2):
	if damage_cooldown > 0.0:
		return
	start_shake(12.0, 0.25)
	kraken_hits += 1
	var damage := 10 + (kraken_hits - 1) * 5   # scales: 10, 15, 20...etc
	damage_cooldown = DAMAGE_COOLDOWN_TIME
	take_damage(damage, dir)

# General damage function
func take_damage(amount: int, dir: Vector2):
	hp = max(hp - amount, 0)
	GameManager.player_hp = hp   # save to GameManager
	
	velocity.x = dir.normalized().x * 2000
	velocity.y = -460
	knockback_timer = KNOCKBACK_TIME
	update_health_ui()
	if hp <= 0:
		die()

# Start camera shake
func start_shake(strength: float = 10.0, duration: float = 0.3):
	shake_strength = strength
	shake_duration = duration
	original_shake_duration = duration  

# Update the health label on screen
func update_health_ui():
	if health_label:
		health_label.text = str(hp) + "/" + str(max_hp)

# Player death
func die():
	is_dead = true
	velocity = Vector2.ZERO
	print("PLAYER DIED")
	# For now we just restart the level (temporary until we add a death screen)
	GameManager.reset_game()
	get_tree().reload_current_scene()
	
# Animation state machine
func update_animation():
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
	else:
		if abs(velocity.x) > 5:
			anim.play("walk")
		else:
			anim.play("idle")
	if abs(velocity.x) > 10:
		anim.flip_h = velocity.x < 0


# power-up unlock func (called by pickup scripts)
func enable_double_jump():
	can_double_jump = true

func enable_dash():
	can_dash = true

func enable_sprint():
	can_sprint = true

func enable_ground_slam():
	can_ground_slam = true
