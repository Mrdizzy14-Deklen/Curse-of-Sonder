extends Node2D


class_name LevelBase


signal spawn

# Enable later
signal level_end


# Preload required scenes
const CHARACTER = preload("res://Scenes/character.tscn")
const LEVEL_BASE = preload("res://level_base.tscn")


@export var level_num: int = 2
@export var level: int = 0


# Define required children
@onready var camera_2d: Camera2D = $CameraTarget/Camera2D
@onready var camera_target: Node2D = $CameraTarget
@onready var hud: Control = $CanvasLayer/HUD
@onready var player_pos: Node2D = $PlayerPos
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var easter_egg: RichTextLabel = $EasterEgg


# Set required variables
var current_character: Character = null
var character_health
var curse_health
var room_character_amounts = []
var rooms = []
var room_enter_triggers = []
var room_exit_triggers = []
var room_exit_enabled = []
var current_room = 0


static func new_level(num: int, lvl: int):
	
	# Create new level instance
	var _new_level = LEVEL_BASE.instantiate()
	
	# Set new level values
	_new_level.level_num = num
	_new_level.level = lvl
	
	return _new_level


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Create characters
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	# Connect attack button to attack function
	hud.attack_button_pressed.connect(_attack)
	
	Global.game_lose.connect(_game_end)
	
	# Spawns the level rooms
	_spawn_rooms()
	spawn.emit()
	
	pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Check if character exists
	if current_character:
		
		# Check each room enter
		for i in room_enter_triggers:
			
			# If close enough to enter trigger
			if i.global_position.distance_to(current_character.global_position) < 200:
				
				# Get rid of check node
				i.queue_free()
				room_enter_triggers.erase(i)
				
				# Start battle
				_start_room(current_room)
				
		
		# Check each room exit
		for i in room_exit_triggers:
			
			# If close enough to exit trigger
			if i.global_position.distance_to(current_character.global_position) < 200:
				
				# Get rid of check node
				i.queue_free()
				room_exit_triggers.erase(i)
				
				# Check if last level
				if current_room >= level_num - 1:
					
					# Level cleared
					_next_level()
				
		# Set enemy ai target
		player_pos.global_position = current_character.global_position
		
		# Have camera follow player
		camera_target.position = current_character.position
		
		# Connect player input to character
		var direction = Input.get_vector("action_left", "action_right", "action_up", "action_down")
		
		if direction:
			current_character.sprite.play()
			current_character.sprite.animation = "cursed_walking"
			if current_character.velocity.x >= 0:
				current_character.sprite.speed_scale = 1
			else:
				current_character.sprite.speed_scale = -1
			current_character.velocity.x = direction.x * current_character.SPEED * 100 * delta
			current_character.velocity.y = direction.y * current_character.SPEED * 100 * delta
		else:
			current_character.sprite.play()
			current_character.sprite.animation = "cursed_default"
			current_character.velocity.x = move_toward(current_character.velocity.x, 0.0, current_character.SPEED * 200 * delta)
			current_character.velocity.y = move_toward(current_character.velocity.y, 0.0, current_character.SPEED * 200 * delta)
		
		# Point weapon at mouse
		if (OS.has_feature("web_android") or OS.has_feature("web_ios")):
			
			# Look left and right on mobile
			if direction.x > 0 and !current_character.looking_right:
				current_character.sprite.scale.x *= -1
				current_character.looking_right = true
			elif direction.x < 0 and current_character.looking_right:
				current_character.sprite.scale.x *= -1
				current_character.looking_right = false
			
			# Point weapon on mobile
			current_character.weapon.look_at(current_character.position + hud.joystick.output)
			if hud.joystick.output != Vector2.ZERO:
				current_character.aim_dir = hud.joystick.output
		else:
			
			# Point weapon on PC
			current_character.weapon.look_at(get_global_mouse_position())
			if current_character.position.direction_to(get_global_mouse_position()).x > 0 and !current_character.looking_right:
				current_character.sprite.scale.x *= -1
				current_character.looking_right = true
			elif current_character.position.direction_to(get_global_mouse_position()).x < 0 and current_character.looking_right:
				current_character.sprite.scale.x *= -1
				current_character.looking_right = false
		
		current_character.move_and_slide()
	
	pass


## Handle other player inputs
func _input(event: InputEvent) -> void:
	
	# Attack
	if event.is_pressed():
		
		# Handle attacks
		if !(OS.has_feature("web_android") or OS.has_feature("web_ios")) and Input.is_action_just_pressed("attack"):
			_attack()
	
	pass


func _set_character(old_body: Character, new_body: Character):
	
	if old_body:
		old_body.controlled = false
		old_body._kill()

	# Gives control to new character
	new_body.controlled = true
	new_body._set_character()
	current_character = new_body
	Global.transfer_up = false
	
	pass


## Create a new character in the level
func _new_character(new_guy: Character, pos: Vector2):
	
	# Add character to the scene
	add_child(new_guy)
	new_guy.global_position = pos
	
	# Connect to the new character's signals
	if new_guy.weapon:
		new_guy.weapon.transfer.connect(_transfer_hit)
	
	new_guy.game_end.connect(_game_end)
	
	# Transfer the player if needed
	if new_guy.controlled:
		_set_character(current_character, new_guy)
	
	pass

## Transfers the player to the hit enemy
func _transfer_hit(character_hit: Character) -> void:
	
	# Set new character
	_set_character(current_character, character_hit)
	Global.transfer_up = false
	
	pass


## Starts an attack
func _attack():
	
	# Play attack animation
	current_character.animation.play("Attack")
	current_character.sword.play("attack")
	
	pass


## Next level
func _next_level():
	
	animation_player.play("game_end")
	# Enable later
	#queue_free()
	#level_end.emit(current_character)
	
	pass


## Change the direction a character is facing
func _change_direction():
	
	# Flip scale
	current_character.sprite.scale.x *= 1
	
	pass


func _complete_room():
	rooms[current_room]._room_complete()
	Global.room_complete = true
	Global.curse_health = Global.curse_health_base
	current_character.set_health(current_character.character_health_value)
	easter_egg.visible = true
	pass


func _start_room(level: int):
	
	if current_room < level_num - 2:
		Global.room_complete = false
	
	current_room += 1
	rooms[current_room]._spawn_guys(level)
	room_character_amounts.append(rooms[current_room].character_amount)
	
	pass


## Deals damage to the player every second
func _on_curse_damage_timer_timeout() -> void:
	
	# Damage player on damage tick if fighting
	if !Global.room_complete:
		if current_character:
			current_character.health_component._curse_timer_damage()
	
	pass


## Spawns all characters in a given room
func _room_character_setup(i: Node2D):
	
	# Placeholder variables
	var new_guy 
	var type = i.type
	
	# Determine what to spawn
	match type:
		"Player":
			new_guy = Character.new_character(Global.BASE_CHARACTER_HEALTH, Global.BASE_CHARACTER_DAMAGE, Global.BASE_CHARACTER_SPEED, 0.5, true)
		"Runt":
			new_guy = CharacterRunt.new_character()
		"Tank":
			new_guy = CharacterTank.new_character()
		_:
			new_guy = Character.new_character(Global.BASE_CHARACTER_HEALTH, Global.BASE_CHARACTER_DAMAGE, Global.BASE_CHARACTER_SPEED, 0.5, false)
	
	# Add new character to scene
	_new_character(new_guy, i.global_position)
	
	new_guy.character_killed.connect(_character_killed)
	new_guy.transfer.connect(_transfer_hit)
	
	pass


func _character_killed():
	room_character_amounts[current_room] -= 1
	if room_character_amounts[current_room] <= 0 and !Global.room_complete:
		_complete_room()


## Spawns all rooms
func _spawn_rooms():
	
	# Define a placeholder
	var prev_room
	
	# Check what level is being loaded
	match level:
		0:
			
			# Spawn an amount of rooms for the designated level
			for i in level_num:
				
				# Define placeholders
				var room
				var hallway
				
				# Check what type of room it is
				if i == 0:
					room = RoomLayoutHandler.SPAWN_ROOM_0[Global.rng.randi() % RoomLayoutHandler.SPAWN_ROOM_0.size()].instantiate()
					if room.exit == "up":
						hallway = RoomLayoutHandler.HALLWAY_UP_0[Global.rng.randi() % RoomLayoutHandler.HALLWAY_UP_0.size()].instantiate()
					elif room.exit == "right":
						hallway = RoomLayoutHandler.HALLWAY_RIGHT_0[Global.rng.randi() % RoomLayoutHandler.HALLWAY_RIGHT_0.size()].instantiate()
					elif room.exit == "left":
						hallway = RoomLayoutHandler.HALLWAY_LEFT_0[Global.rng.randi() % RoomLayoutHandler.HALLWAY_LEFT_0.size()].instantiate()
				elif i == level_num - 1:
					room = RoomLayoutHandler.END_ROOM_0[Global.rng.randi() % RoomLayoutHandler.END_ROOM_0.size()].instantiate()
				else:
					room = RoomLayoutHandler.MIDDLE_ROOM_0[Global.rng.randi() % RoomLayoutHandler.MIDDLE_ROOM_0.size()].instantiate()
					if room.exit == "up":
						hallway = RoomLayoutHandler.HALLWAY_UP_0[Global.rng.randi() % RoomLayoutHandler.HALLWAY_UP_0.size()].instantiate()
					elif room.exit == "right":
						hallway = RoomLayoutHandler.HALLWAY_RIGHT_0[Global.rng.randi() % RoomLayoutHandler.HALLWAY_RIGHT_0.size()].instantiate()
					elif room.exit == "left":
						hallway = RoomLayoutHandler.HALLWAY_LEFT_0[Global.rng.randi() % RoomLayoutHandler.HALLWAY_LEFT_0.size()].instantiate()
				
				# Add room onto last room
				if prev_room:
					room.global_position = prev_room.get_node("Exit").global_position
				
				
				
				# Add room to level
				add_child(room)
				
				# Check if a hallway is needed
				if hallway:
					hallway.global_position = room.get_node("Exit").global_position
				add_child(hallway)
				
				# Use hallway as new base
				prev_room = hallway
				
				if i == 0:
					if get_tree().root.get_child(2).level_num == 0:
						room._spawn_guys(i)
					room_character_amounts.append(room.character_amount)
				rooms.append(room)
				var enter_trigger = Node2D.new()
				enter_trigger.global_position = room.global_position
				add_child(enter_trigger)
				room_enter_triggers.append(enter_trigger)
				room_exit_triggers.append(room.get_node("Exit"))
				room_exit_enabled.append(false)
				


func _game_end():
	
	animation_player.play("game_lose")
	
	pass


func _exit_game():
	
	get_tree().change_scene_to_file("res://Scenes/opening_animation.tscn")
	
	pass
