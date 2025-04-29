extends Node


class_name Attack


var attack_damage


## Generates a new attack
static func attack(damage: int) -> Attack:
	var new_attack = Attack.new()
	new_attack.attack_damage = damage
	return new_attack
	
