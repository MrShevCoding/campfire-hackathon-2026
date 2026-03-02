extends Node
# GameManager (Autoload)
# This script lives across all scenes and stores data that
# needs to persist between levels, for like HP.
# It's always accessible from anywhere as "GameManager".


# Player stats that don't get erased across scenes
var player_hp: int = 65
var player_max_hp: int = 65
# kraken_hits and current_level are optional – you can use them
# if you want damage scaling or level-specific tweaks to carry over.
var kraken_hits: int = 0
var current_level: int = 1

# Call this when the player dies or restarts the game to reset everything
# But for the sake of the game jam we never trully got to implement it...
func reset_game():
	player_hp = player_max_hp
	kraken_hits = 0
	current_level = 1
