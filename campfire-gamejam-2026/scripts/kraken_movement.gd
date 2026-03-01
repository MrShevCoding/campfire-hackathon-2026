# kraken_movement.gd
extends CharacterBody2D

@export var acceleration := 12
var velocity_x := 0.0

func _physics_process(delta):
	velocity_x += acceleration * delta
	velocity.x = velocity_x
	move_and_slide()
