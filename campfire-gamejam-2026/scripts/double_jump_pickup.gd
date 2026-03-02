extends Area2D
# Double Jump Powerup Pickup this lets the player jump once in mid-air.

func _ready():
	$AnimatedSprite2D.play("jump_powerup")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("enable_double_jump"):
		body.enable_double_jump()
		queue_free()
