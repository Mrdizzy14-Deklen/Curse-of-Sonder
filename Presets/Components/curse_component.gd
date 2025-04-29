extends HealthComponent


class_name CurseComponent


func _ready() -> void:
	Global.curse_health = Global.curse_health_base

func damage(attack: Attack) -> bool:
	
	# Apply damage
	Global.curse_health -= attack.attack_damage
	
	# Enable transfer
	Global.transfer_up = true
	
	return health > 0
