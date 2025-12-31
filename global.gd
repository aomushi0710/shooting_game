extends Node

const DAMAGE_LABEL = preload("res://damage_label.tscn")

enum Layer { ## プロジェクトに設定している物理レイヤーの名前に対応する番号
	PLAYER = 1,
	ENEMY,
	TERRAIN,
	PLAYER_BULLET,
	ENEMY_BULLET,
}
