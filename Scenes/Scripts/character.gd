extends CharacterBody2D


class_name Character


signal character_killed
signal transfer
signal game_end


const CHARACTER = preload("res://Scenes/character.tscn")


@onready var weapon: WeaponAttack = $Weapon
@onready var sword: AnimatedSprite2D = $Weapon/Sword
@onready var weapon_collider: CollisionShape2D = $Weapon/WeaponCollider
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var curse_component: CurseComponent = $CurseComponent
@onready var curse_bar: ProgressBar = $CurseBar
@onready var health_bar: ProgressBar = $HealthBar

@onready var surround_timer: Timer = $SurroundTimer
@onready var stagger_timer: Timer = $StaggerTimer
@onready var aftershock_timer: Timer = $AftershockTimer
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var enemy_vision: RayCast2D = $EnemyVision


@export var MAX_HEALTH = Global.BASE_CHARACTER_HEALTH
@export var SPEED = Global.BASE_CHARACTER_SPEED
@export var ATTACK_DAMAGE = Global.BASE_CHARACTER_DAMAGE


# Core variables
var character_health_value = MAX_HEALTH
var controlled = false
var total_health
var looking_right = true


# Enemy ai variables
enum{SURROUND, IDLE, RETREAT, ATTACK}
var actions = [SURROUND, RETREAT, ATTACK]
var state = IDLE
var enemy_speed_modifier
var player_pos: Node2D
var direction
var staggered = false
var vision_radius = 4000
var circle_radius = 640
var retreat_distance = 1280
var base: Vector2
var enabled = false
var angle_speed = 1.0
var current_angle = 0
var seen_player = false
var transfer_range = false

## Creates a new basic character
static func new_character(
					max_health: int = Global.BASE_CHARACTER_HEALTH, 
					attack_damage: int = Global.BASE_CHARACTER_DAMAGE, 
					speed: int = Global.BASE_CHARACTER_SPEED,
					enemy_speed_mod: float = 0.5,
					player_character: bool = false):
	
	# Create new character instance
	var new_guy = CHARACTER.instantiate()
	
	# Set new characters values
	new_guy.MAX_HEALTH = max_health
	new_guy.character_health_value = max_health
	new_guy.ATTACK_DAMAGE = attack_damage
	new_guy.SPEED = speed
	new_guy.enemy_speed_modifier = enemy_speed_mod
	new_guy.controlled = player_character
	
	# Return new character
	return new_guy


func _ready() -> void:
	
	# Set character values
	character_health_value = MAX_HEALTH
	health_component.health = MAX_HEALTH
	weapon.attack_damage = ATTACK_DAMAGE
	
	# Connect to necessary signals 
	health_component.update_health.connect(set_health)
	
	# Get current player position
	player_pos = get_parent().get_node("PlayerPos")
	

func _physics_process(delta: float) -> void:
	
	if !controlled:
		
		enemy_vision.target_position = player_pos.global_position - global_position
		
		if !staggered and enabled:
			_direction_handling()
			_state_handling(delta)
		
		if direction:
			if staggered:
				velocity.x = direction.x * SPEED * 200 * delta
				velocity.y = direction.y * SPEED * 200 * delta
				sprite.stop()
			else:
				sprite.play()
				sprite.animation = "walking"
				velocity.x = direction.x * SPEED * 100 * delta * enemy_speed_modifier
				velocity.y = direction.y * SPEED * 100 * delta * enemy_speed_modifier
		else:
			sprite.play()
			sprite.animation = "default"
			velocity.x = move_toward(velocity.x, 0.0, SPEED * 2000 * delta)
			velocity.y = move_toward(velocity.y, 0.0, SPEED * 2000 * delta)
		
		move_and_slide()
	
	pass


func _state_handling(delta):
	
	if global_position.distance_to(player_pos.global_position) > vision_radius:
		state = IDLE
	
	match state:
		IDLE:
			idle_behavior()
		ATTACK:
			attack_behavior()
		RETREAT:
			retreat_behavior()
		SURROUND:
			surround_behavior(delta)


func idle_behavior():
	if ((!enemy_vision.is_colliding() and global_position.distance_to(player_pos.global_position) < vision_radius) or (seen_player and global_position.distance_to(player_pos.global_position) < 1000)) and enabled:
		
		seen_player = true
		
		match Global.rng.randi() % 1:
			0:
				_set_state(ATTACK)
			1:
				_set_state(RETREAT)
			2:
				_set_state(SURROUND)
		
		return

func attack_behavior():
	
	# Check if player is in range
	if ((!enemy_vision.is_colliding() and global_position.distance_to(player_pos.global_position) < vision_radius) or (seen_player and global_position.distance_to(player_pos.global_position) < 1000)):
		
		# Run up to player
		set_target_pos(player_pos.global_position + 300 * (global_position - player_pos.global_position).normalized())
		
		if global_position.distance_to(player_pos.global_position) <= 360:
			if !animation.is_playing():
				weapon.look_at(player_pos.global_position)
				animation.play("Attack")
				sword.play("attack")
		else:
			weapon.look_at(player_pos.global_position)


func retreat_behavior():
	
	# Return to idle if far enough
	if global_position.distance_to(player_pos.global_position) > retreat_distance:
		_set_state(IDLE)
	
	elif global_position.distance_to(player_pos.global_position) < 400:
		
		_set_state(ATTACK)
		
		return
		
	else:
		
		# Run from player
		var temp_dir = (global_position - player_pos.global_position).normalized()
		set_target_pos(global_position + temp_dir * retreat_distance)


func surround_behavior(delta):
	
	weapon.look_at(player_pos.global_position)
	 # Adjust the angle over time to create movement (e.g., rotate slowly)
	  # Speed at which the enemy orbits the player (radians per second)
	current_angle += angle_speed * delta

	# Keep the angle within a valid range (0 to 2 * PI)
	current_angle = wrapf(current_angle, 0, 2 * PI)

	# Calculate the target position based on the current angle
	var surround_point = player_pos.global_position + Vector2(
		cos(current_angle),
		sin(current_angle)
	) * circle_radius

	# Update the target position
	if nav.target_position.distance_to(surround_point) > 32:
		set_target_pos(surround_point)
	elif global_position.distance_to(player_pos.global_position) < 400:
		
		_set_state(ATTACK)
		
		return

func _set_state(new_state):
	match new_state:
		IDLE:
			state = IDLE
		ATTACK:
			state = ATTACK
		RETREAT:
			state = RETREAT
		SURROUND:
			state = SURROUND
			if Global.rng.randi() % 2 == 0:
				angle_speed = 1
			else:
				angle_speed = -1
			current_angle = 0
			surround_timer.start()


## Handles what direction to move in and where to look
func _direction_handling():
	
	# Check if player is in vision
	if ((!enemy_vision.is_colliding() and global_position.distance_to(player_pos.global_position) < vision_radius) or (seen_player and global_position.distance_to(player_pos.global_position) < 1000)) and enabled:
		
		# Look in correct direction
		if global_position.direction_to(player_pos.global_position).x > 0 and !looking_right:
			sprite.scale.x *= -1
			looking_right = true
		elif global_position.direction_to(player_pos.global_position).x < 0 and looking_right:
			sprite.scale.x *= -1
			looking_right = false


## Sets this character as the player controlled character
func _set_character():
	
	# Enable character functions
	controlled = true
	
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)
	
	hitbox_component.set_collision_layer_value(2, false)
	hitbox_component.set_collision_layer_value(6, true)
	
	weapon.set_collision_mask_value(6, false)
	weapon.set_collision_mask_value(2, true)
	
	sword.play("default")
	animation.play("RESET")
	sprite.play("cursed_default")
	
	# Set healthbar
	Global.curse_health = Global.curse_health_base
	set_health(character_health_value)
	
	pass


## Sets the health bar for the current character
func set_health(character: int) -> bool:
	
	# Set health
	character_health_value = character
	
	if controlled:
		
		# Define the increments for the health values
		var increment = 470.0 / (Global.curse_health_base + MAX_HEALTH)
		
		# Show curse bar if player
		curse_bar.visible = true
		
		# Set the curse bar value
		curse_bar.size.x = Global.curse_health_base * increment
		curse_bar.max_value = curse_bar.size.x
		curse_bar.value = Global.curse_health * increment
		
		# Set health bar value
		health_bar.value = health_component.health * increment + 10 + curse_bar.max_value
		
		# Check if player died
		if Global.curse_health <= 0:
			game_end.emit()
	else:
		
		# Hide curse bar if enemy
		curse_bar.visible = false
		
		# Set health bar value
		health_bar.value = (character_health_value * 480.0)/MAX_HEALTH
		
		if character_health_value <= MAX_HEALTH/2.0:
			transfer_range = true
			#if character_health_value <= 0:
				#transfer.emit(self)
		else:
			transfer_range = false
		
		# Check if enemy died
		if health_component.health <= 0:
			_kill()
	
	
	# Returns if character is alive
	return character_health_value > 0


func _kill():
	queue_free()
	character_killed.emit()


func _on_stagger_timer_timeout() -> void:
	direction = null
	aftershock_timer.start()


func _on_enable_timer_timeout() -> void:
	
	enabled = true
	base = global_position
	
	pass

## Sets new nav target
func set_target_pos(new_pos: Vector2):
	if global_position.distance_to(new_pos) > 320:
		nav.target_position = new_pos
	
	# Determine direction to target
	direction = nav.get_next_path_position() - global_position
	
	if direction.length_squared() > 1.0:
		direction = direction.normalized()


func _send_transfer(character):
	transfer.emit(character)


func _on_aftershock_timer_timeout() -> void:
	
	staggered = false
	
	pass
	


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	
	if state == ATTACK:
		
		# Change state
		if randi() % 2 == 0:
			_set_state(RETREAT)
		else:
			_set_state(SURROUND)


func _on_surround_timer_timeout() -> void:
	
	_set_state(IDLE)
	
	pass
