extends Node


signal game_lose


# Character constants
const BASE_CHARACTER_HEALTH = 2
const BASE_CHARACTER_DAMAGE = 1
const BASE_CHARACTER_SPEED = 450
const CURSE_TIMER_DAMAGE = 1


# Keep track of player properties
var transfer_up = false
var room_complete = true
var curse_health_base = 6
var curse_health = 6
var rng = RandomNumberGenerator.new()


func _ready():
	var temp_rng = RandomNumberGenerator.new()
	rng.seed = temp_rng.randi()
	
	pass


func _game_end():
	
	game_lose.emit()
	
	pass
