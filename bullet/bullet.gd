@tool
class_name Bullet
extends CharacterBody2D
## 弾丸の基底クラス

const BULLET_SPEED_SCALE := 10
const MOVE_SPEED_SCALE := 10
const MAX_POINT := 100 ## 割り振り可能な合計ポイント数

enum ParamID { ## パラメータの一覧とそのID
	NONE = -1,
	# 以下、基礎パラメータ
	HP, ## 体力
	DAMAGE, ## 攻撃力
	MOVE_SPEED, ## 移動速度
	PENETRATION, ## 貫通力
	BULLET_SPEED, ## 弾速
	FIRE_RATE, ## 連射力
	LIFE_TIME, ## 持続時間
	# 以下、固有パラメータ
	PELLET_COUNT = 100, ## 散弾数(ショットガン専用)
	EXPLOSION_RADIUS, ## 爆発半径(ミサイル専用)
	HOMING_STRENGTH, ## 追尾力(ホーミング専用)
	LASER_WIDTH, ## レーザー幅(レーザー専用)
}

var hp: int:
	get: return get_param_value(ParamID.HP)
var damage: int:
	get: return get_param_value(ParamID.DAMAGE)
var move_speed: int:
	get: return get_param_value(ParamID.MOVE_SPEED)
var penetration: int:
	get: return get_param_value(ParamID.PENETRATION)
var bullet_speed: int:
	get: return get_param_value(ParamID.BULLET_SPEED)
var fire_rate: float:
	get: return get_param_value(ParamID.FIRE_RATE)
var life_time: float:
	get: return get_param_value(ParamID.LIFE_TIME)

## 敵を貫通できる残り回数。この値が0の状態で弾が衝突すると弾が消滅する。
var penetration_count: int

@export var parameters: Array[BulletParameter]

## [enum ParamID]を指定して、該当するパラメータが存在していればその
##[BulletParametr]を返し、そうでなければ[code]null[/code]を返す関数。
func get_param(id: Bullet.ParamID) -> BulletParameter:
	var param_ids := parameters.map(func(p: BulletParameter): return p.id)
	var index := param_ids.find(id)
	
	if index == -1:
		printerr(id, " はparameters配列内に存在しません！")
		return null
	else:
		return parameters[index]

## [enum ParamID]を指定して、該当するパラメータが存在していればその
##[b][BulletParametr]の[member BulletParameter.value]を返し[/b]、
##[BulletParameter]が存在していなければ[code]null[/code]を返す関数。
func get_param_value(id: Bullet.ParamID) -> Variant:
	var param := get_param(id)
	
	if param == null:
		return null
	else:
		return param.value

## [member Bullet.parameters]に含まれる全ての[BulletParameter]に対して、
##[signal BulletParameter.value_changed]シグナルを接続する関数
func _update_connections():
	for param in parameters:
		if param and not param.value_changed.is_connected(_on_param_changed):
			param.value_changed.connect(_on_param_changed)

## [signal BulletParameter.value_changed]シグナルが発行された時、
##変更された[member BulletParameter.value]がポイント上限を越えていないか
##確認し、越えていた場合上限値に戻す関数
func _on_param_changed(param: BulletParameter):
	if not param.use_point:
		return

	## [param param]を除いた、現在使用中の合計ポイント
	var current_total_points := _calculate_used_points(param)
	
	## 現在利用可能な残りポイント
	var remaining_points := MAX_POINT - current_total_points
	## [param remaining_point]から算出した、現在設定可能な上限値
	var max_allowed_value := remaining_points / param.point_per_val
	
	if param.value > max_allowed_value:
		param.value = max_allowed_value
		printerr(
			"「%s」には %d より大きな値を入力できません！" % 
			[param.name, max_allowed_value]
		)
		notify_property_list_changed()

## 現在使用中のポイント数の合計値を返す関数。[br]引数を指定すると、
##そのパラメータに割り当てられれているポイント数を除いた合計値を返します。
func _calculate_used_points(exclude_param: BulletParameter = null) -> int:
	var current_points := 0 
	for p in parameters:
		if p.use_point and p != exclude_param:
			# 基本的にポイントを要するのは[int]のみなので警告は無視。
			@warning_ignore("narrowing_conversion")
			current_points += p.value * p.point_per_val
	
	return current_points

## 弾が発射(インスタンスがシーンツリーに追加)されてから時間が経つと消滅させる処理
func _ready() -> void:
	_update_connections()
	if not Engine.is_editor_hint():
		penetration_count = penetration
		get_tree().create_timer(life_time).timeout.connect(queue_free)

## 各パラメータに振り分けられるポイント数についてインスペクタ上に表示する関数
func _get_property_list() -> Array:
	var points = {
		"name": "使用中 ∕ 最大値",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_EDITOR
	}
	return [points]

## ポイント数を再計算し、表示を更新する関数。
func _get(property):
	if property.begins_with("使用中 ∕ 最大値"):
		var used = _calculate_used_points()
		return "%d / %d" % [used, MAX_POINT]
	
	return null
