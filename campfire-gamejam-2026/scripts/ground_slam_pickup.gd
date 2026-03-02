extends Area2D
# Ground Slam Powerup Pickup
# Unlocks the ability to slam straight down while in the air.
# Dash but downards

func _ready():
	$AnimatedSprite2D.play("downslam_powerup")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("enable_ground_slam"):
		body.enable_ground_slam()
		queue_free()
