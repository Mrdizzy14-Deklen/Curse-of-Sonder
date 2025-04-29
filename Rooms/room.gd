extends Node2D

@onready var character_spawns: Node = $CharacterSpawns
@onready var door: Node2D = $Door


@export var exit: String = "up"


var character_amount = 0
const CHARACTERTYPES = ["Character", "Runt", "Tank"]


## Spawns all characters in a room
func _spawn_guys(level: int):
	
	# Calls for a new character at every spawn location
	for i in character_spawns.get_children():
		if level > 0:
			i.type = CHARACTERTYPES[Global.rng.randi_range(0, CHARACTERTYPES.size() - 1)]
		get_parent()._room_character_setup(i)
		character_amount += 1
	
	pass

func _room_complete():
	if door:
		door.door_closed.queue_free()
	pass
