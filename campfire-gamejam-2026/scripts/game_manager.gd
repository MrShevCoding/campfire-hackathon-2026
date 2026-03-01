extends Node

# Player stats that persist across levels
var player_hp: int = 65
var player_max_hp: int = 65
var kraken_hits: int = 0      # optional – if you want damage scaling per level reset
var current_level: int = 1    # optional – for level‑specific adjustments

# Called when the game starts (or after a game over)
func reset_game():
	player_hp = player_max_hp
	kraken_hits = 0
	current_level = 1
