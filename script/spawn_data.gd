@tool
extends Resource
class_name SpawnData

## インスペクタで上下左右のみを選択させるためのenum。[br]
## ([Vector2]には上下左右のみの定数で構成されたenumが存在しないため自作)[br]
## 内部では、それぞれに対応する[Vector2]の定数値として扱われます。[br]
## 関数[code]direction_to_vector2[/code]も参照してください。
enum Direction {
	NONE, ## デフォルト値。[member Vector2.ZERO]
	RIGHT, ## x座標を画面右端に合わせます。[member Vector2.RIGHT]
	LEFT, ## x座標を画面左端に合わせます。[member Vector2.LEFT]
	UP, ## y座標を画面上端に合わせます。[member Vector2.UP]
	DOWN, ## y座標を画面下端に合わせます。[member Vector2.DOWN]
}

@export var time: float ## 出現までの秒数
@export var enemy: PackedScene ## 敵シーン
@export var path: Curve2D ## 敵が進むルート
## [member SpawnData.path]に適用されるスケーリング
@export var path_scale: Vector2 = Vector2(1.0, 1.0)
@export var duration: float ## ルートの完走にかかる時間

@export_category("生成座標")
## 生成位置はgetterによって、マージンで自動補正されます。[br]
## 補正に失敗した場合は元の値が渡されます。
@export var spawn_position: Vector2:
	get:
		if enemy:
			var instance := enemy.instantiate()
			
			if instance and instance is Enemy:
				return Global.calculate_offscreen_position(
					instance as Enemy,
					direction_to_vector2(spawn_direction),
					spawn_position
				)
		
		return spawn_position

## 生成する方向。[br]
## [enum Direction.NONE]以外に設定した場合、生成位置は対応する座標に一部置き換えられます。
@export var spawn_direction := Direction.NONE

@export_category("消滅座標")
## 消滅位置はgetterによって、マージンで自動補正されます。[br]
## 補正に失敗した場合は元の値が渡されます。
@export var despawn_position: Vector2:
	get:
		if enemy:
			var instance := enemy.instantiate()
			
			if instance and instance is Enemy:
				return Global.calculate_offscreen_position(
					instance as Enemy,
					direction_to_vector2(despawn_direction),
					despawn_position
				)
		
		return spawn_position

## 消滅する方向。[br]
## [enum Direction.NONE]以外に設定した場合、生成位置は対応する座標に一部置き換えられます。
@export var despawn_direction := Direction.NONE

## [enum Direction]を引数として、それぞれに対応する[Vector2]を返す関数。[br]
func direction_to_vector2(direction: Direction) -> Vector2:
	match direction:
		Direction.RIGHT: return Vector2.RIGHT
		Direction.LEFT: return Vector2.LEFT
		Direction.UP: return Vector2.UP
		Direction.DOWN: return Vector2.DOWN
		_: return Vector2.ZERO
