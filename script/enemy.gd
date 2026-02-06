@tool
extends CharacterBase
class_name Enemy

signal enemy_defeated(score: int) ## 敵が倒された時にスコアを送るシグナル

@export var id: int
@export var base_score: int ## 敵が倒された時に得られるスコアの基礎値

func defeat() -> void:
	super()
	enemy_defeated.emit(base_score * bullet.hp)
