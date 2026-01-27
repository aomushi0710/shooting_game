@tool
extends CharacterBase
class_name Player

signal damaged(amount: int)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return # @toolを用いたエディタ上での演算を行わない
	
	var input_direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = input_direction * bullet.move_speed * bullet.MOVE_SPEED_SCALE
	move_and_slide()
	
	super(delta)

func take_damage(amount: int, from_player: bool = true) -> void:
	super(amount, from_player)
	damaged.emit(amount)

func defeat() -> void:
	super()
