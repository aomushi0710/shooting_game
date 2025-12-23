@tool
extends Resource
class_name BulletParameter
## エディタのインスペクタ上で、編集可能な名前と値を持つパラメータ変数の設定項目

## [member BulletParameter.value]が変更された時、
##パラメータ自身を引数として発行されるシグナル。
signal value_changed(param: BulletParameter)

## [member BulletParameter.name]に入力すると、
##プレイヤーが編集可能ではない設定項目を表示できるパスワード
const PASSWORD = "doichulab"

## 内部で対応する変数を一意に識別するためのid。
@export var id: Bullet.ParamID = Bullet.ParamID.NONE

## プレイヤーが編集可能な変数名。
@export var name: String:
	set(value):
		## [b]既に、[/b]正しいパスワードが入力されていたかどうか
		var was_unlocked := (name == PASSWORD)
		
		name = value
		resource_name = value
		
		## [b]たった今、[/b]正しいパスワードが入力されたかどうか
		var is_unlocked := (name == PASSWORD)
		
		if was_unlocked != is_unlocked:
			notify_property_list_changed()

## プレイヤーが編集可能な値。[br]
## [member BulletParameter.type]の型において[float]または[int]の
##両方に対応するために、この変数の型は[float]に統一して設定されています。
@export var value: float = 1.0:
	set(val):
		if val == value:
			return
		
		value = val
		value_changed.emit(self)


@export var min_value: float = 0.0

## パラメータに設定できる変数の型。
@export var type: Variant.Type = TYPE_FLOAT

## [code]true[/code]の時、そのパラメータは割り当て時にポイントを使用します。
@export var use_point: bool = false

## [member BulletParameter.use_point]が[code]true[/code]の時、
##パラメータを1増やすごとに必要なポイント数。
@export var point_per_val: int = 1

## [member BulletParameter.name]に[member BulletParameter.password]を入力すると、
## [member BulletParameter.name]・[member BulletParameter.value]以外の
##プレイヤーが本来いじれない設定項目を表示させる関数。
func _validate_property(property: Dictionary) -> void:
	if name != PASSWORD:
		if property.name not in ["name", "value"]:
			property.usage = PROPERTY_USAGE_STORAGE
