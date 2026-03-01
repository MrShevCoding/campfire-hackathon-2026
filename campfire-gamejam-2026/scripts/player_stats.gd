extends CharacterBody2D

# =======================
# BASIC MOVEMENT
# =======================
@export var speed := 200.0
@export var jump_velocity := -365.0
@export var gravity := 900.0

# =======================
# DOUBLE JUMP
# =======================
var can_double_jump := false
var jump_count := 0

# =======================
# DASH
# =======================
var can_dash := false
var dash_used := false

@export var dash_speed := 800.0
@export var dash_time := 0.3
@export var dash_cooldown := 0.4
@export var double_tap_time := 0.25

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

var last_left_tap := 0.0
var last_right_tap := 0.0

# =======================
# SPRINT
# =======================
var can_sprint := false

@export var sprint_multiplier := 1.72
@export var sprint_duration := 5.0
@export var sprint_regen_time := 10.0

var sprint_stamina := sprint_duration
var is_sprinting := false

# =======================
# GROUND SLAM
# =======================
var can_ground_slam := false
var is_ground_slamming := false
var ground_slam_used := false

@export var slam_speed := 1400.0

# =======================
# HEALTH
# =======================
@export var max_hp := 65
var hp := max_hp

var knockback_timer := 0.0
const KNOCKBACK_TIME := 0.2

var damage_cooldown := 0.0
const DAMAGE_COOLDOWN_TIME := 0.6

var kraken_hits := 0
var is_dead := false

@onready var health_label: Label = get_node_or_null("CanvasLayer/HPlabel")

# ============================================================
# READY
# ============================================================
func _ready():
	if health_label:
		update_health_ui()

# ============================================================
# PHYSICS
# ============================================================
func _physics_process(delta):

	if is_dead:
		velocity = Vector2.ZERO
		return

	dash_cooldown_timer -= delta
	damage_cooldown -= delta

	# =======================
	# KNOCKBACK
	# =======================
	if knockback_timer > 0:
		knockback_timer -= delta
		move_and_slide()
		return

	# =======================
	# DASH INPUT
	# =======================
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

	# =======================
	# DASH MOVEMENT
	# =======================
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return

	# =======================
	# GROUND SLAM INPUT
	# =======================
	if can_ground_slam and not ground_slam_used and not is_on_floor():
		if Input.is_action_just_pressed("ui_down"):
			start_ground_slam()

	# =======================
	# GROUND SLAM MOVEMENT
	# =======================
	if is_ground_slamming:
		velocity.x = 0
		velocity.y = slam_speed

		if is_on_floor():
			is_ground_slamming = false
			ground_slam_used = true

		move_and_slide()
		return

	# =======================
	# NORMAL INPUT
	# =======================
	var input_dir := Input.get_axis("ui_left", "ui_right")

	# =======================
	# SPRINT SYSTEM
	# =======================
	if can_sprint and Input.is_action_pressed("sprint") and sprint_stamina > 0 and input_dir != 0:
		is_sprinting = true
		sprint_stamina = max(sprint_stamina - delta, 0)
	else:
		is_sprinting = false
		if sprint_stamina < sprint_duration:
			sprint_stamina += delta * (sprint_duration / sprint_regen_time)
			sprint_stamina = min(sprint_stamina, sprint_duration)

	var current_speed = speed
	if is_sprinting:
		current_speed *= sprint_multiplier

	velocity.x = input_dir * current_speed

	# =======================
	# GRAVITY + RESET
	# =======================
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		jump_count = 0
		dash_used = false
		ground_slam_used = false

	# =======================
	# JUMP / DOUBLE JUMP
	# =======================
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_velocity
			jump_count = 1
		elif can_double_jump and jump_count < 2:
			velocity.y = jump_velocity
			jump_count += 1

	move_and_slide()

# ============================================================
# DASH FUNCTION
# ============================================================
func start_dash(direction: int):
	is_dashing = true
	dash_timer = dash_time
	dash_cooldown_timer = dash_cooldown
	dash_used = true
	velocity.y = 0
	velocity.x = direction * dash_speed

# ============================================================
# GROUND SLAM FUNCTION
# ============================================================
func start_ground_slam():
	is_ground_slamming = true
	ground_slam_used = true
	velocity.y = slam_speed

# ============================================================
# POWERUPS
# ============================================================
func enable_double_jump():
	can_double_jump = true

func enable_dash():
	can_dash = true

func enable_sprint():
	can_sprint = true

func enable_ground_slam():
	can_ground_slam = true

# ============================================================
# DAMAGE SYSTEM
# ============================================================
func take_kraken_hit(dir: Vector2):
	if damage_cooldown > 0:
		return

	kraken_hits += 1
	var damage := 5 + (kraken_hits - 1) * 5
	take_damage(damage, dir)

func take_damage(amount: int, dir: Vector2):
	hp = max(hp - amount, 0)

	velocity.x = dir.normalized().x * 2000
	velocity.y = -460
	knockback_timer = KNOCKBACK_TIME

	update_health_ui()

	if hp <= 0:
		die()

func update_health_ui():
	if health_label:
		health_label.text = str(hp) + "/" + str(max_hp)

func die():
	is_dead = true
	velocity = Vector2.ZERO
	print("PLAYER DIED")
