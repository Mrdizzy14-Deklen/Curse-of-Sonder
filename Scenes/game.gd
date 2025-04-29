extends Node2D


var level_num = 0
var current_character: Character


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_next_level()

func _next_level(current_character = null):
	var new_level = LevelBase.new_level(Global.rng.randi_range(12, 14), 0)
	if current_character:
		new_level.add_child(current_character)
		new_level.current_character = current_character
	
	new_level.level_end.connect(_next_level)
	add_child(new_level)
	level_num += 1
