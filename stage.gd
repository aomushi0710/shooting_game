extends Node2D

@export var stage_data: StageData ## ステージの各種情報
@export var enemies_node: Node2D ## 敵ノードを追加する親ノード

var current_time: float = 0.0 ## 現在の経過秒数
var index: int = 0 ## 現在の[member StageData.spawn_data]配列のindex。

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
	
	var enemy = data.enemy.instantiate()
	enemy.global_position = data.position
	enemies_node.add_child(enemy)
