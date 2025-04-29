extends Character


class_name CharacterRunt


const RUNT = preload("res://Scenes/runt.tscn")


## Creates a runt character
static func new_character(
					max_health: int = Global.BASE_CHARACTER_HEALTH, 
					attack_damage: int = Global.BASE_CHARACTER_DAMAGE, 
					speed: int = 550,
					enemy_speed_mod: float = 0.5,
					player_character: bool = false):
	
	# Create new character instance
	var new_guy = RUNT.instantiate()
	
	# Set new characters values
	new_guy.MAX_HEALTH = max_health
	new_guy.character_health_value = max_health
	new_guy.ATTACK_DAMAGE = attack_damage
	new_guy.SPEED = speed
	new_guy.enemy_speed_modifier = enemy_speed_mod
	new_guy.controlled = player_character
	
	# Return new character
	return new_guy
