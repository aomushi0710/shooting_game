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

@export var texture: AnimatedSprite2D ## キャラクターの見た目
@export var bullet: Bullet ## 発射される弾のノード

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

var can_shoot: bool = true ## 弾が発射可能かどうかのフラグ
## キャラクターのHPの現在値。[br]
## HPの最大値は[member CharacterBase.bullet]の[member Bullet.hp]を参照
var hp: int = 10

func _ready() -> void:
	# キャラクターが所持している弾の処理を止める
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.hide()
	
	hp = bullet.hp
	
	# 同じBullet型のインスタンスを敵味方問わず使い回せるように、
	# 弾のレイヤーとマスクは発射したキャラクター側で指定する。
	bullet.collision_layer = bullet_layer
	bullet.collision_mask = bullet_mask
	
	texture.play()

## 弾が発射可能になった時、[code]shoot()[/code]関数を呼び、弾を発射する関数。
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if can_shoot:
		_shoot()

## 弾を発射する関数。[br]発射後の弾の挙動は弾自身のシーンで定義されている。
func _shoot() -> void:
	can_shoot = false
	
	if bullet == null:
		return
	
	var shot := bullet.duplicate() ## 複製されて実際に発射する弾のノード
	# 発射された弾の処理は再開させる
	shot.process_mode = Node.PROCESS_MODE_INHERIT
	shot.show()
	
	# 弾の追加場所はStage -> Bulletsの中
	## 弾の生存時間を過ぎると削除する[Tween]
	var tween := shot.create_tween()
	tween.tween_interval(shot.life_time)
	tween.tween_callback(shot.queue_free)
	shot.global_position = global_position
	get_tree().current_scene.bullets_node.add_child(shot)
	
	await get_tree().create_timer(shot.fire_rate).timeout
	can_shoot = true

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
		defeat()

## キャラクターが倒された時に呼ばれる関数
func defeat() -> void:
	queue_free()

## キャラクターの[member CharacterBase.texture]のテクスチャサイズから、
##マージンを計算し取得する関数
func get_margin() -> Vector2:
	if texture and texture.sprite_frames:
		var frame := texture.sprite_frames.get_frame_texture(texture.animation, 0)
		if frame:
			return frame.get_size() * texture.scale / 2.0
		else:
			printerr("このAnimatedSprite2Dにはアニメーションがありません！")
			return Vector2.ZERO
	else:
		printerr("このキャラクターにはAnimatedSprite2Dがありません！")
		return Vector2.ZERO
