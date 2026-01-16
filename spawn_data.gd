@tool
extends Resource
class_name SpawnData

enum Direction {
	NONE, ## デフォルト値。無補正。
	RIGHT, ## x座標を画面右端に合わせます。
	LEFT, ## x座標を画面左端に合わせます。
	UP,
	DOWN,
}

var screen_w: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_h: float = ProjectSettings.get_setting("display/window/size/viewport_height")

@export var time: float ## 出現までの秒数
@export var enemy: PackedScene ## 敵シーン
@export var path: Curve2D ## 敵が進むルート
## [member SpawnData.path]に適用されるスケーリング
@export var path_scale: Vector2 = Vector2(1.0, 1.0)
@export var duration: float ## ルートの完走にかかる時間

@export_category("登場座標")
@export var spawn_position: Vector2 ## 登場位置
## 出現する方向。[br]
## [member SpawnData.spawn_position][b]を入力してから操作すること。[b]
@export var spawn_direction := Direction.NONE:
	set(value):
		spawn_direction = value
		spawn_position = _calculate_offscreen_position(value, spawn_position)

@export_category("消滅座標")
@export var despawn_position: Vector2 ## 消滅位置
## 消滅する方向。[br]
## [member SpawnData.despawn_position][b]を入力してから操作すること。[b]
@export var despawn_direction := Direction.NONE:
	set(value):
		despawn_direction = value
		despawn_position = _calculate_offscreen_position(value, despawn_position)

## [member SpawnData.enemy]シーンの[code]get_margin()[/code]を呼び出し、
##キャラクターのテクスチャサイズを取得する関数。
func _get_margin() -> Vector2:
	if not enemy:
		printerr("敵シーンが設定されていません！")
		return Vector2.ZERO

	var instance = enemy.instantiate()
	var margin = Vector2.ZERO
	
	if instance is CharacterBase:
		margin = instance.get_margin()
	
	instance.free()
	return margin

## [member SpawnData.spawn_direction]及び[member SpawnData.despawn_direction]
##に応じたマージンを、それぞれ[member SpawnData.spawn_direction]・
##[member SpawnData.despawn_direction]に適用した後の値を返す関数。
func _calculate_offscreen_position(direction: Direction, position: Vector2) -> Vector2:
	var result_position := position ## 返り値
	var margins := _get_margin() ## 
	
	match direction:
		Direction.RIGHT:
			result_position.x = screen_w + margins.x
			
		Direction.LEFT:
			result_position.x = -margins.x
			
		Direction.UP:
			result_position.y = -margins.y
			
		Direction.DOWN:
			result_position.y = screen_h + margins.y
	
	return result_position
