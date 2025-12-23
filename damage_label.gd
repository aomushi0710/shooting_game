extends RichTextLabel
class_name DamageLabel

var amount: int
var from_player: bool

var color_name: String
var count: int:
	set(value):
		count = value
		text = "[color=%s]%d[/color]" % [color_name, count]
	

func _ready() -> void:
	if from_player:
		color_name = "orange"
	else:
		color_name = "red"
	
	count = 0
	
	var pos := position
	var tween := create_tween()
	tween.tween_property(
		self, "position:y", pos.y - 100, 0.2
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(self, "count", amount, 0.2)
	tween.tween_interval(0.6)
	tween.tween_property(self, "modulate:a", 0, 0.2)
	
	tween.tween_callback(queue_free)
