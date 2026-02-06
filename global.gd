extends Node

const SCREEN_WIDTH := 960.0 ## 画面の横幅
const SCREEN_HEIGHT := 540.0 ## 画面の縦幅

const DAMAGE_LABEL = preload("res://component/damage_label.tscn")

enum Layer { ## プロジェクトに設定している物理レイヤーの名前に対応する番号
	PLAYER = 1,
	ENEMY,
	TERRAIN,
	PLAYER_BULLET,
	ENEMY_BULLET,
}

var main_scene := preload("res://scene/main.tscn")
var stage_select_scene := preload("res://scene/stage_select.tscn")
var stage_scene := preload("res://scene/stage.tscn")

var enemy_data: Dictionary[int, PackedScene] ## 敵シーンの一覧

func _ready() -> void:
	enemy_data = load_scene_from_folder("res://component/enemy/")


## フォルダパスを引数として、フォルダ内のシーンを全て読み込み、敵シーンの一覧を返す関数
func load_scene_from_folder(path: String) -> Dictionary[int, PackedScene]:
	var scene_dict: Dictionary[int, PackedScene] ## 返り値
	var dir = DirAccess.open(path)
	
	if not dir:
		printerr("不明なフォルダパス: ", path)
		return scene_dict
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			var full_path := path.path_join(file_name)
			var scene = load(full_path) as PackedScene
			
			if scene:
				var instance = scene.instantiate()
				
				if instance is Enemy:
					scene_dict[instance.id] = scene
			
			else:
				printerr(full_path, " のロードに失敗しました")
		
		file_name = dir.get_next()
		
	return scene_dict

## 引数[param chara]に応じたマージンを取得し、
##引数[param direction](上下左右)の各方向に応じたマージンを
##引数[position]に適用した後の値を返す関数。
func calculate_offscreen_position(
	chara: CharacterBase, direction: Vector2, position: Vector2) -> Vector2:
	var result_position := position ## 返り値
	var margin := chara.get_margin()
	
	match direction:
		Vector2.RIGHT:
			result_position.x = SCREEN_WIDTH + margin.x
			
		Vector2.LEFT:
			result_position.x = -margin.x
			
		Vector2.UP:
			result_position.y = -margin.y
			
		Vector2.DOWN:
			result_position.y = SCREEN_HEIGHT + margin.y
	
	return result_position
