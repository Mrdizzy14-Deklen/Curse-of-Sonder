extends Node


class_name HealthComponent


signal update_health(character_health: int, curse_health: int)




@export var MAX_HEALTH: int
@export var curse_component: CurseComponent


var health: int


func damage(attack: Attack) -> bool:
	
	
	# Apply damage
	if health <= 0:
		if curse_component and get_parent().controlled:
				curse_component.damage(attack)
	health -= attack.attack_damage
	
	# Update healthbar
	update_health.emit(health)
	
	if health <= 0 and get_parent().controlled:
		Global.transfer_up = true
	
	# Return if enemy is killed
	return health > 0

func _curse_timer_damage():
	health -= Global.CURSE_TIMER_DAMAGE
	if health < 0:
		curse_component.damage(Attack.attack(Global.CURSE_TIMER_DAMAGE))
		if Global.curse_health <= 0:
			Global._game_end()
	
	if health <= 0:
		Global.transfer_up = true
	
	update_health.emit(health)
