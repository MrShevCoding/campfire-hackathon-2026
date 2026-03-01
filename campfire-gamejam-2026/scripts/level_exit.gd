extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Body entered: ", body.name)
	if body.is_in_group("player"):
		print("Player detected! Changing scene...")
		go_to_next_scene()

func go_to_next_scene():
	var current = get_tree().current_scene.scene_file_path
	print("Current scene: ", current)
	# Defer the actual scene change
	call_deferred("_change_scene", current)

func _change_scene(current: String):
	match current:
		"res://scenes/tutorial.tscn":
			get_tree().change_scene_to_file("res://scenes/level1.tscn")
		"res://scenes/level1.tscn":
			get_tree().change_scene_to_file("res://scenes/level2.tscn")
		"res://scenes/level2.tscn":
			get_tree().change_scene_to_file("res://scenes/level3.tscn")
		"res://scenes/level3.tscn":
			get_tree().change_scene_to_file("res://scenes/level4.tscn")
		"res://scenes/level4.tscn":
			get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
		"res://scenes/win_screen.tscn":
			print("You beat all levels!")
		_:
			print("Unknown level, can't transition.")
