extends Area2D

func _ready():
	$AnimatedSprite2D.play()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("enable_dash"):
		body.enable_dash()
		queue_free()
