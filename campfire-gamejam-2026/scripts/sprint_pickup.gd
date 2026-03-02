extends Area2D
# Sprint Powerup Pickup
# Unlocks the ability to hold Shift and run faster. zoom

func _ready():
	$AnimatedSprite2D.play("sprint_powerup")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("enable_sprint"):
		body.enable_sprint()
		queue_free()
