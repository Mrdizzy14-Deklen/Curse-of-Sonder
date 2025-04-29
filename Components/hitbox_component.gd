extends Area2D


class_name HitboxComponent


@export var health_component: HealthComponent


func damage(attack: Attack) -> bool:
	if health_component:
		return health_component.damage(attack)
	
	return false
