extends Node2D

func _ready() -> void:
	randomize()
	
	while true:
		_spawn_enemy()
		await get_tree().create_timer(randf_range(0.5, 5.0)).timeout

## タイトル画面にランダムな種類の敵を出現させ、泳がせる関数
func _spawn_enemy() -> void:
	var id := randi_range(1, Global.enemy_data.size())
	var enemy := Global.enemy_data[id].instantiate() as Enemy
	
	var y_pos := randi_range(0, int(Global.SCREEN_HEIGHT))
	var left_pos := Vector2(0, y_pos)
	var right_pos := Vector2(Global.SCREEN_WIDTH, y_pos)
	var spawn_sides: Array[Vector2] = [ ## 左側と右側の生成位置及び消滅位置
		Global.calculate_offscreen_position(enemy, Vector2.RIGHT, left_pos),
		Global.calculate_offscreen_position(enemy, Vector2.LEFT, right_pos)
		]
	
	spawn_sides.shuffle() # 生成位置を左右ランダムに切り替える
	var spawn_pos := spawn_sides[0]
	var despawn_pos := spawn_sides[1]
	
	enemy.position = spawn_pos
	enemy.can_shoot = false
	enemy.scale.x *= signf(spawn_pos.x - despawn_pos.x) # 座標に応じて向きを反転
	add_child(enemy)
	
	var tween: Tween = self.create_tween()
	tween.tween_property(enemy, "position", despawn_pos, 5)
	tween.tween_callback(func(): enemy.queue_free())
