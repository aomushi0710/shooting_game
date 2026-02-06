extends Control

@export var stage_node: Node2D
@export var hp_bar_node: TextureProgressBar
@export var hp_text_node: RichTextLabel
@export var score_node: RichTextLabel

var score_tween: Tween ## スコア増加アニメーション
var _visual_score: int = 0 ## 画面上に表示されている見かけ上のスコア
var score: int = 0: ## 実際のスコア
	set(value):
		score = value
		_score_changed()

## プレイヤーがダメージを受けた時、
##HPバーの[member TextureProgressBar.value]を変化させる関数
func _on_player_damaged(amount: int) -> void:
	var final_hp := hp_bar_node.value - amount
	var tween := (
		create_tween()
		.bind_node(hp_bar_node)
		.set_ease(Tween.EASE_OUT)
		.set_trans(Tween.TRANS_EXPO)
	)
	tween.tween_property(hp_bar_node, "value", final_hp, 1)

## HPバーの[member TextureProgressBar.value]が変化した時テキスト表記も変化させる関数
func _on_hp_bar_value_changed(value: float) -> void:
	hp_text_node.text = "HP %3d/%3d" % [
		int(value), int(hp_bar_node.max_value)]

## スコアが変化した時、アニメーションを再生する関数
func _score_changed() -> void:
	if score_tween:
		score_tween.kill()
	
	score_tween = create_tween().bind_node(score_node)
	score_tween.tween_method(
		func(value: int):
			score_node.text = "SCORE:%06d" % value
			_visual_score = value,
		_visual_score, score, 0.5
	)
