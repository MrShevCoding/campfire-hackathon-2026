extends CharacterBody2D
# Kraken's movement script –> attached to the Kraken root.
# It moves faster over time, chases the main player.

@export var acceleration := 12       # how fast it speeds up
@export var max_speed := 300          # optional top speed

var velocity_x := 0.0

@onready var kraken_anim: AnimatedSprite2D = $Kraken_anim

func _ready():
	# Start the animation 
	if kraken_anim:
		kraken_anim.play("kraken_anim")
		print("Animation playing: ", kraken_anim.is_playing())
	else:
		print("ERROR: Kraken_anim not found!")

func _physics_process(delta):
	# Increase speed over time (helps make the chase gets harder)
	velocity_x += acceleration * delta
	velocity_x = min(velocity_x, max_speed)   # cap if we set a max
	velocity.x = velocity_x
	
	move_and_slide()
