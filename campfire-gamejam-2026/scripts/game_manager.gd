extends Node

# Player stats to persist between levels
var player_hp: int = 65
var player_max_hp: int = 65
var kraken_hits: int = 0   # tracks how many times Kraken hit (for scaling damage)
var current_level: int = 1  # start at level 1

# Optional: upgrades (you can expand later)
var has_double_jump: bool = false
var has_dash: bool = false

# Called when switching scenes
func reset_for_new_level():
	# Any per-level reset (like Kraken speed factor) can go here
	pass
