extends Area2D

func _ready():
	$AnimatedSprite2D.play("downslam_powerup")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("enable_ground_slam"):
		body.enable_ground_slam()
		queue_free()
