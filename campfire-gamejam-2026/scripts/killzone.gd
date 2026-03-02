extends Area2D

# Kill Zone –> big rect that is placed at the bottom of every level.
# If the player falls into it, they die and what we did was level restarts, but you could do something different.

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player fell to death!")
		# Quick restart: reload the current scene
		get_tree().reload_current_scene()
