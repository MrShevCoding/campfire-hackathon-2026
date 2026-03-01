extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("enable_sprint"):
		body.enable_sprint()
		queue_free()
