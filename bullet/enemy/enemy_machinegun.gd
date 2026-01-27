@tool
extends BulletMachinegun

func _ready() -> void:
	super()
	base_direction = Vector2.LEFT

## 敵の弾ノードはポイント数上限を無視するため、上書きしてこの関数を無効化
func _on_param_changed(param: BulletParameter):
	pass
