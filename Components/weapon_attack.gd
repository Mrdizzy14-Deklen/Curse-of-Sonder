extends Area2D


class_name WeaponAttack


signal transfer


@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"


@export var attack_damage: int


## Deals damage on hit
func _on_area_entered(area: Area2D) -> void:
	
	# Check if can do damage
	if area.has_method("damage"):
		if audio_stream_player:
			audio_stream_player.play()
		
		# Check if enemy
		if area.get_parent().controlled:
			
			# If player, deal damage
			area.damage(Attack.attack(attack_damage))
			area.get_parent().direction = ( area.get_parent().global_position - global_position).normalized()
			
			return
			
		elif Global.transfer_up and area.get_parent().transfer_range:
			
			# If not player and can transfer is up, transfer
			transfer.emit(area.get_parent())
			
			return
			
		else:
			
			# If enemy and can't transfer, do damage
			area.damage(Attack.attack(attack_damage))
			area.get_parent().direction = ( area.get_parent().global_position - global_position).normalized()
			area.get_parent().staggered = true
			area.get_parent().stagger_timer.start()
			area.get_parent().animation.stop()
			area.get_parent().weapon_collider.disabled = true
			
			return
