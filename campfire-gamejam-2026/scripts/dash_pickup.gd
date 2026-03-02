extends Area2D
# Dash Powerup Pickup, when player touches this, they get the dash ability.
# The dash -> double-tap a direction to dash horizontaly.

func _ready():
	# Play the specific animation for this powerup (named "dash_powerup")
	$AnimatedSprite2D.play("dash_powerup")
	# Connect the signal so we know when something (hopefully the player) enters
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the thing that entered has the method we want to call
	if body.has_method("enable_dash"):
		# Tell the player to enable dash
		body.enable_dash()
		# Remove the pickup so it can't be collected again
		queue_free()
