extends Resource
class_name SpawnData

@export var time: float ## 出現までの秒数
@export var enemy: PackedScene ## 敵シーン
@export var position: Vector2 ## 登場位置

@export var path: Curve2D ## 敵が進むルート
@export var duration: float ## ルートの完走にかかる時間
