extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("new_animation")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("enable_double_jump"):
		body.enable_double_jump()
		queue_free()
