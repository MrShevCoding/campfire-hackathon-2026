extends Node
# MusicManager (Autoload also like the GameManager)
# Handles switching background music based on the current scene.
# It's an autoload so music continues between levels.


var music_player: AudioStreamPlayer
var current_track_path: String = ""

# Map scene file paths to their corresponding music files
const SCENE_MUSIC_MAP = {
	"res://scenes/tutorial.tscn": "res://assets/music/merchants_and_sea_salt.wav",
	"res://scenes/level1.tscn": "res://assets/music/pirate.mp3",
	"res://scenes/level2.tscn": "res://assets/music/oho_yarr.mp3",
	"res://scenes/level3.tscn": "res://assets/music/spring_-_mere_baubles.ogg",
	"res://scenes/level4.tscn": "res://assets/music/chest_of_adventure.mp3",
	"res://scenes/win_screen.tscn": "res://assets/music/abeautifuldayver2.ogg"
}

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	# _process will handle the first check

func _process(_delta):
	check_scene_and_play_music()

func check_scene_and_play_music():
	# Prevent errors if the scene isn't fully loaded yet
	if not get_tree() or not get_tree().current_scene:
		return
	
	var current_scene_path = get_tree().current_scene.scene_file_path
	var expected_track = SCENE_MUSIC_MAP.get(current_scene_path, "")
	
	if expected_track and expected_track != current_track_path:
		play_music(expected_track)

func play_music(path: String):
	var stream = load(path) as AudioStream
	if stream:
		music_player.stream = stream
		music_player.play()
		current_track_path = path
		print("Now playing: ", path)

func stop_music():
	music_player.stop()
	current_track_path = ""
