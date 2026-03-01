extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.has_method("take_kraken_hit"):
		var dir: Vector2 = body.global_position - global_position
		body.take_kraken_hit(dir)
