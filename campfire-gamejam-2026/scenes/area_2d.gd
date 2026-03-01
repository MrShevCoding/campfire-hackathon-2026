extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.has_method("enable_ground_slam"):
		body.enable_ground_slam()
		queue_free()  # disappears when picked up
