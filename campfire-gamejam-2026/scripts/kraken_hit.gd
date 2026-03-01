extends Area2D

var damage_interval := 0.5  # seconds between damage ticks
var time_since_last_damage := 0.0
var players_in_area := []   # track players inside

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.has_method("take_kraken_hit") and body not in players_in_area:
		players_in_area.append(body)
		# Optionally apply immediate damage on entry
		apply_damage(body)

func _on_body_exited(body):
	if body in players_in_area:
		players_in_area.erase(body)

func _process(delta):
	if players_in_area.is_empty():
		return
	time_since_last_damage += delta
	if time_since_last_damage >= damage_interval:
		time_since_last_damage = 0.0
		for body in players_in_area:
			apply_damage(body)

func apply_damage(body):
	if body.has_method("take_kraken_hit"):
		var dir: Vector2 = body.global_position - global_position
		body.take_kraken_hit(dir)
