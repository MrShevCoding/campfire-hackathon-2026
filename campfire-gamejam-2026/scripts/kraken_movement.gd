extends CharacterBody2D

@export var acceleration := 12
@export var max_speed := 300  # optional cap

var velocity_x := 0.0

@onready var kraken_anim: AnimatedSprite2D = $Kraken_anim

func _ready():
	# START THE ANIMATION!
	if kraken_anim:
		kraken_anim.play("kraken_anim")
		print("Animation playing: ", kraken_anim.is_playing())  # debug
	else:
		print("ERROR: Kraken_anim not found!")

func _physics_process(delta):
	# Increase speed over time
	velocity_x += acceleration * delta
	velocity_x = min(velocity_x, max_speed)  # cap if you want
	velocity.x = velocity_x
	
	move_and_slide()
