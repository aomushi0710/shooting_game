弾丸の種類　それぞれの弾丸には個性があり、ステータスの上限または下限が異なります。更に固有ステータスを持つものもあります。
・マシンガン...連射力が非常に高い。
・ショットガン...1発のショットで拡散する弾を発射できる。固有ステータス:拡散力(拡散する弾数増加、攻撃力減少)
・ミサイル...連射力は低いが、敵に命中すると爆発し周囲を巻き込む。固有ステータス:爆発力(爆発半径増加、攻撃力減少)
・ホーミング...自動で敵を追尾できるが、攻撃力が低い。固有ステータス:追尾力(追尾の強さ増加)
・レーザー...連射力は低いが、敵を貫通する光線は持続が長く連続ヒット。
など

タイトル画面に表示するもの
・タイトル
・ステージセレクトボタン
・スタッフクレジットボタン

ステージに表示するもの
・

func _spawn_enemy(data: SpawnData) -> void:
	if not data.enemy:
		printerr("敵シーンが設定されていません！")
		return
	
	var enemy = data.enemy.instantiate() ## シーンから生成された敵ノード
	
	# パスデータが存在しない場合は、指定された座標に出現だけさせて終了する。
	if not data.path:
		enemy.global_position = data.position
		enemies_node.add_child(enemy)
		return
	
	## 敵ノードの通り道
	var path_node = Path2D.new()
	path_node.curve = data.path
	path_node.global_position = data.position
	
	## [param path_node]を通る土台
	var follow_node = PathFollow2D.new()
	follow_node.loop = false
	follow_node.rotates = false
	
	# 敵ノードをパス通りに動かすための親子関係を作る。
	enemies_node.add_child(path_node)
	path_node.add_child(follow_node)
	follow_node.add_child(enemy)
	
	# 敵ノードは[param follow_node]の子として追従するため、本体の位置は(0, 0)。
	enemy.position = Vector2.ZERO
	
	## 敵ノードが動くアニメーション
	var tween = follow_node.create_tween()
	tween.tween_property(follow_node, "progress_ratio", 1.0, data.duration)
	tween.tween_callback(path_node.queue_free)
