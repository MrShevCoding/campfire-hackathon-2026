extends CharacterBody2D

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

@onready var anim: AnimatedSprite2D = $Player_anim  # adjust node name if different

# Camera shake
@onready var camera: Camera2D = $Camera2D
var shake_strength := 0.0
var shake_duration := 0.0
var original_shake_duration := 0.0

func _ready():
	if health_label == null:
		push_error("HPLabel NOT FOUND — CHECK NODE PATH")
	else:
		update_health_ui()

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta * 2
		move_and_slide()
		# Use fall for death (as requested)
		if anim.sprite_frames.has_animation("fall"):
			anim.play("fall")
		else:
			anim.stop()
		return
	
	if damage_cooldown > 0.0:
		damage_cooldown -= delta
	
	if knockback_timer > 0.0:
		knockback_timer -= delta
		move_and_slide()
		# During knockback, play fall (hurt)
		if anim.sprite_frames.has_animation("fall"):
			anim.play("fall")
		else:
			anim.stop()
		return

	# Normal movement (same as before)
	var input_dir := 0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1

	velocity.x = input_dir * speed

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
	
	# NOW update animation with correct ground state
	update_animation()
	
	# Camera shake (unchanged)
	if shake_duration > 0:
		shake_duration -= delta
		var current_strength = shake_strength * (shake_duration / original_shake_duration)
		camera.offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
	else:
		camera.offset = Vector2.ZERO
		
func take_kraken_hit(dir: Vector2):
	if damage_cooldown > 0.0:
		return
	
	# SCREEN SHAKE ON HIT!
	start_shake(12.0, 0.25)  # Strength 12, duration 0.25 seconds

	kraken_hits += 1
	var damage := 10 + (kraken_hits - 1) * 5
	damage_cooldown = DAMAGE_COOLDOWN_TIME
	take_damage(damage, dir)
	
func take_damage(amount: int, dir: Vector2):
	hp = max(hp - amount, 0)

	velocity.x = dir.normalized().x * 2000   # horizontal push
	velocity.y = -460                       # vertical pop
	knockback_timer = KNOCKBACK_TIME

	update_health_ui()

	if hp <= 0:
		die()

func start_shake(strength: float = 10.0, duration: float = 0.3):
	shake_strength = strength
	shake_duration = duration
	original_shake_duration = duration  

func update_health_ui():
	if health_label:
		health_label.text = str(hp) + "/" + str(max_hp)

func die():
	is_dead = true
	velocity = Vector2.ZERO
	print("PLAYER DIED")
	
func update_animation():
	# Only called when alive and not in knockback
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
	
	# Flip sprite (only when moving horizontally)
	if abs(velocity.x) > 10:
		anim.flip_h = velocity.x < 0
	
