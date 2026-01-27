extends Node2D

const BASE_CURVE_LENGTH = 960.0 

@export var stage_data: StageData ## ステージの各種情報
@export var player_node: Player
@export var enemies_node: Node2D ## 敵ノードを追加する親ノード
@export var bullets_node: Node2D ## 弾ノードを追加する親ノード
@export var hud_node: Control ## HUDを管理する親ノード

var current_time: float = 0.0 ## 現在の経過秒数
var index: int = 0 ## 現在の[member StageData.spawn_data]配列のindex

func _ready() -> void:
	hud_node.hp_bar_node.max_value = player_node.hp
	hud_node.hp_bar_node.value = player_node.hp


func _physics_process(delta: float) -> void:
	if not stage_data:
		printerr("StageDataが存在しません！")
		return
	
	current_time += delta # 時間を進める
	
	# まだ敵が残っているかつ敵の出現時間になったら実行する
	var events := stage_data.spawn_data ## ステージが持つ敵の出現データ配列
	while index < events.size() and current_time >= events[index].time:
		_spawn_enemy(events[index])
		index += 1

## 実際に敵を生成する関数
func _spawn_enemy(data: SpawnData) -> void:
	if not data.enemy:
		printerr("敵シーンが設定されていません！")
		return
	
	var enemy: Enemy = data.enemy.instantiate() ## シーンから生成された敵ノード
	enemy.enemy_defeated.connect(func(value): hud_node.score += value)
	
	# パスデータが存在しない場合は、指定された座標に出現だけさせて終了する。
	if not data.path:
		enemy.global_position = data.spawn_position
		enemies_node.add_child(enemy)
		return
	
	_spawn_enemy_with_path(data, enemy)

## [member SpawnData.path]を用いて敵を生成する関数[br]
## [Path2D]及び[PathFollow]で設定された経路を完走後は自動で削除されます
func _spawn_enemy_with_path(data: SpawnData, enemy: Enemy) -> void:
	var path_node := Path2D.new() ## 敵が通る軌道
	path_node.curve = data.path
	path_node.global_position = data.spawn_position
	
	var vector_to_target = data.despawn_position - data.spawn_position
	path_node.rotation = vector_to_target.angle() - PI # 左向き固定
	
	# 軌道のスケーリング
	var base_scale := Vector2(
		vector_to_target.length() / BASE_CURVE_LENGTH, 1.0)
	path_node.scale = base_scale * data.path_scale
	
	var follow_node := PathFollow2D.new()
	follow_node.loop = false
	follow_node.rotates = false
	
	# Stage -> Path -> Follow -> Enemy
	enemies_node.add_child(path_node)
	path_node.add_child(follow_node)
	follow_node.add_child(enemy)
	
	enemy.position = Vector2.ZERO # enemyノードはfollow_nodeの子として追従するため、本体の位置は(0, 0)。
	enemy.scale /= path_node.scale # 親のscaleの影響を受けないように元に戻す
	
	var tween = create_tween().bind_node(path_node)
	tween.tween_property(follow_node, "progress_ratio", 1.0, data.duration)
	tween.tween_callback(path_node.queue_free) # 終わったらパスごと削除
