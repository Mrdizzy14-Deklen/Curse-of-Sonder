extends Character


class_name CharacterGrunt


const GRUNT = preload("res://Presets/Characters/grunt.tscn")


## Creates a new character of type grunt
static func new_character(
					max_health: int = Global.BASE_CHARACTER_HEALTH, 
					attack_damage: int = Global.BASE_CHARACTER_DAMAGE, 
					speed: int = Global.BASE_CHARACTER_SPEED,
					enemy_speed_mod: float = 0.5,
					projectile = false,
					_shoot_c = 1,
					player_character: bool = false):
	
	# Create new character instance
	var new_guy = GRUNT.instantiate()
	
	# Set new characters values
	new_guy.MAX_HEALTH = max_health
	new_guy.character_health_value = max_health
	new_guy.ATTACK_DAMAGE = attack_damage
	new_guy.SPEED = speed
	new_guy.enemy_speed_modifier = enemy_speed_mod
	new_guy.shoots_projectile = projectile
	new_guy.controlled = player_character
	
	# Return new character
	return new_guy
