extends CharacterBody2D

@export var speed := 200
@export var jump_velocity := -365
@export var gravity := 400

const DROP_THROUGH_LAYER := 2

func _physics_process(delta):
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

	# Drop-through platforms
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		disable_drop_through()
		await get_tree().create_timer(0.2).timeout
		enable_drop_through()

	move_and_slide()

func disable_drop_through():
	collision_mask &= ~(1 << (DROP_THROUGH_LAYER - 1))

func enable_drop_through():
	collision_mask |= (1 << (DROP_THROUGH_LAYER - 1))
