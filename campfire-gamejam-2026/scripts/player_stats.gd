extends CharacterBody2D

@export var speed := 200
@export var jump_velocity := -365
@export var gravity := 400

@export var max_hp := 65
var hp := max_hp

var knockback_timer := 0.0
const KNOCKBACK_TIME := 0.2

var damage_cooldown := 0.0
const DAMAGE_COOLDOWN_TIME := 0.6

var kraken_hits := 0
var is_dead := false

@onready var health_label: Label = get_node_or_null("CanvasLayer/HPlabel")

func _ready():
	if health_label == null:
		push_error("HPLabel NOT FOUND — CHECK NODE PATH")
	else:
		update_health_ui()

func _physics_process(delta):
	
	if is_dead:
		velocity = Vector2.ZERO
		return
		
	if damage_cooldown > 0.0:
		damage_cooldown -= delta
	
	if knockback_timer > 0.0:
		knockback_timer -= delta
		move_and_slide()
		return

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

func take_kraken_hit(dir: Vector2):
	if damage_cooldown > 0.0:
		return

	kraken_hits += 1
	var damage := 5 + (kraken_hits - 1) * 5
	#damage_cooldown = DAMAGE_COOLDOWN_TIME
	take_damage(damage, dir)
	
func take_damage(amount: int, dir: Vector2):
	hp = max(hp - amount, 0)

	velocity.x = dir.normalized().x * 2000   # horizontal push
	velocity.y = -460                       # vertical pop
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
