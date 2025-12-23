@tool
extends CharacterBase
class_name Player
## プレイヤー

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var input_direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = input_direction * bullet.move_speed * bullet.MOVE_SPEED_SCALE
	move_and_slide()
	
	super._physics_process(delta)
