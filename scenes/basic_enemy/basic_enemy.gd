extends CharacterBody2D


const MAX_SPEED: int = 75

func _ready():
	pass

func _process(_delta):
	var direction = get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()

func get_direction_to_player() -> Vector2:
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO
