@tool
extends CharacterBase
class_name Enemy

func _ready() -> void:
	super()
	global_rotation = 0.0
	# テクスチャの上下及び左右反転の防止
	if global_scale.x < 0.0:
		scale.x *= -1.0
	if global_scale.y < 0.0:
		scale.y *= -1.0
