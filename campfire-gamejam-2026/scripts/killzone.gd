extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Player fell out of bounds – trigger death
		# You can either reload the level or show a death screen
		get_tree().reload_current_scene()  # quick restart
