@tool
extends CharacterBody2D
class_name CharacterBase
## プレイヤーや敵などの全てのキャラクターの基底クラス

## キャラクターの分類。[br]
## 選択することでこのキャラクターが発射する弾のレイヤーとマスクが自動で設定される。
enum CharacterType {
	CUSTOM, ## いずれにも該当しない場合。手動でレイヤーとマスクを設定すること。
	PLAYER, ## プレイヤー
	ENEMY, ## 敵
}

@export_category("Layer & Mask")
## キャラクターの分類。値によって、レイヤーとマスクがテンプレート通りに設定されます。
@export var character_type: CharacterType = CharacterType.CUSTOM:
	set(type):
		character_type = type
		match type:
			CharacterType.CUSTOM:
				bullet_layer = 0
				bullet_mask = 0
			
			CharacterType.PLAYER:
				bullet_layer = 8
				bullet_mask = 6
			
			CharacterType.ENEMY:
				bullet_layer = 16
				bullet_mask = 5
		
		notify_property_list_changed()

## キャラクターが発射した弾のレイヤー
@export_flags_2d_physics var bullet_layer: int
## キャラクターが発射した弾のマスク
@export_flags_2d_physics var bullet_mask: int

@export_category("Bullet")
@export var bullet_scene = Global.MACHINEGUN ## 発射される弾のシーン

var bullet: Bullet ## シーンツリーには追加されず、プロパティの参照先となるだけの弾
var can_shoot: bool = true ## 弾が発射可能かどうかのフラグ

var hp: int = 10 ## キャラクターのHPの現在値。0になると機能を停止する。

func _ready() -> void:
	bullet = _create_bullet_instance(bullet_scene)
	hp = bullet.hp

## 弾が発射可能になった時、[code]shoot()[/code]関数を呼び、弾を発射する関数。
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if can_shoot:
		_shoot()

## 弾を発射する関数。[br]発射後の弾の挙動は弾自身のシーンで定義されている。
func _shoot() -> void:
	can_shoot = false
	
	var instance := _create_bullet_instance(bullet_scene)
	if instance == null:
		return
	
	# 同じBullet型のインスタンスを敵味方問わず使い回せるように、
	# 弾のレイヤーとマスクは発射したキャラクター側で指定する。
	instance.collision_layer = bullet_layer
	instance.collision_mask = bullet_mask
	instance.global_position = global_position
	get_parent().add_child(instance)
	await get_tree().create_timer(instance.fire_rate).timeout
	can_shoot = true

## [member CharacterBase.bullet_scene]が存在しなかった場合や、
##Bullet型でなかった場合は[code]null[/code]を返し、
##そうでなければ複製された[Bullet]を返す関数。
func _create_bullet_instance(scene: PackedScene) -> Bullet:
	if scene == null:
		printerr("bullet_sceneが未設定です。")
		return null
	
	var instance := scene.instantiate()
	if not instance is Bullet:
		printerr("引数に設定されているシーンがBulletクラスではありません。")
		instance.queue_free()
		return null
		
	return instance as Bullet

## ダメージを受けた時に呼ばれる関数。[br]
## [param amount]:受けたダメージ数。[br]
## [param from_player]:プレイヤーから敵へ与えられたダメージかどうか
func take_damage(amount: int, from_player: bool = true) -> void:
	hp -= amount
	
	# ダメージ表示
	var label = Global.DAMAGE_LABEL.instantiate()
	# Control系ノードをNode2D系ノードに追加するため、positionを微調整する
	label.position = global_position - (label.size / 2)
	label.amount = amount
	label.from_player = from_player
	get_tree().current_scene.add_child(label)
	
	if hp <= 0:
		queue_free()
